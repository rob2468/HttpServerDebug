//
//  HSDGCDWebSocket.m
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/4/17.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import "HSDGCDWebSocket.h"
#import "GCDWebServer.h"
#import "GCDWebServerPrivate.h"
#import <CommonCrypto/CommonDigest.h>

#define TIMEOUT_NONE          -1
#define TIMEOUT_REQUEST_BODY  10

#define TAG_HTTP_REQUEST_BODY      100
#define TAG_HTTP_RESPONSE_HEADERS  200
#define TAG_HTTP_RESPONSE_BODY     201

#define TAG_PREFIX                 300
#define TAG_MSG_PLUS_SUFFIX        301
#define TAG_MSG_WITH_LENGTH        302
#define TAG_MSG_MASKING_KEY        303
#define TAG_PAYLOAD_PREFIX         304
#define TAG_PAYLOAD_LENGTH         305
#define TAG_PAYLOAD_LENGTH16       306
#define TAG_PAYLOAD_LENGTH64       307

#define WS_OP_CONTINUATION_FRAME   0
#define WS_OP_TEXT_FRAME           1
#define WS_OP_BINARY_FRAME         2
#define WS_OP_CONNECTION_CLOSE     8
#define WS_OP_PING                 9
#define WS_OP_PONG                 10

static inline BOOL WS_PAYLOAD_IS_MASKED(UInt8 frame) {
    return (frame & 0x80) ? YES : NO;
}

static inline NSUInteger WS_PAYLOAD_LENGTH(UInt8 frame) {
    return frame & 0x7F;
}

@interface NSData (DDData)

- (NSData *)md5Digest;

- (NSData *)sha1Digest;

- (NSString *)hexStringValue;

- (NSString *)base64Encoded;
- (NSData *)base64Decoded;

@end

@interface HSDGCDWebSocket ()

@property (nonatomic, weak) GCDWebServer *server;               // web server
@property (nonatomic, assign) CFSocketNativeHandle socket;      // the socket
@property (nonatomic, assign) CFHTTPMessageRef requestMessage;
@property (nonatomic, strong) dispatch_source_t readSource;
@property (nonatomic, strong) NSData *term;

@end

@implementation HSDGCDWebSocket

+ (BOOL)isWebSocketRequest:(NSDictionary *)requestHeaders {
    // Request (Draft 75):
    //
    // GET /demo HTTP/1.1
    // Upgrade: WebSocket
    // Connection: Upgrade
    // Host: example.com
    // Origin: http://example.com
    // WebSocket-Protocol: sample
    //
    //
    // Request (Draft 76):
    //
    // GET /demo HTTP/1.1
    // Upgrade: WebSocket
    // Connection: Upgrade
    // Host: example.com
    // Origin: http://example.com
    // Sec-WebSocket-Protocol: sample
    // Sec-WebSocket-Key1: 4 @1  46546xW%0l 1 5
    // Sec-WebSocket-Key2: 12998 5 Y3 1  .P00
    //
    // ^n:ds[4U

    // Look for Upgrade: and Connection: headers.
    // If we find them, and they have the proper value,
    // we can safely assume this is a websocket request.

    NSString *connectionHeaderValue = [requestHeaders objectForKey:@"Connection"];
    NSString *upgradeHeaderValue = [requestHeaders objectForKey:@"Upgrade"];

    BOOL isWebSocket = YES;

    if (!upgradeHeaderValue || !connectionHeaderValue) {
        isWebSocket = NO;
    } else if ([upgradeHeaderValue caseInsensitiveCompare:@"WebSocket"] != NSOrderedSame) {
        isWebSocket = NO;
    } else if ([connectionHeaderValue rangeOfString:@"Upgrade" options:NSCaseInsensitiveSearch].location == NSNotFound) {
        isWebSocket = NO;
    }
    return isWebSocket;
}

- (instancetype)initWithServer:(GCDWebServer *)server requestMessage:(CFHTTPMessageRef)requestMessage socket:(CFSocketNativeHandle)socket {
    self = [super init];
    if (self) {
        self.server = server;
        self.requestMessage = requestMessage;
        self.socket = socket;
        self.term = [[NSData alloc] initWithBytes:"\xFF" length:1];

        // create the read dispatch source
        self.readSource = [self createReadDispatchSource];

        [self sendResponseHeaders];
        [self didOpen];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendMessage:@"wowowowowow"];
        });
    }
    return self;
}

- (void)dealloc {
    dispatch_source_cancel(self.readSource);
}


- (void)closeWebSocket {
    [self didClose];

    if ([self.webSocketDelegate respondsToSelector:@selector(webSocketDidClose)]) {
        [self.webSocketDelegate webSocketDidClose];
    }
}

- (dispatch_source_t)createReadDispatchSource {
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, self.socket, 0, dispatch_get_global_queue(self.server.dispatchQueuePriority, 0));
    dispatch_source_set_cancel_handler(source, ^{
        @autoreleasepool {
            int result = close(self.socket);
            if (result != 0) {
                GWS_LOG_ERROR(@"Failed closing IPv4 WebSocket socket: %s (%i)", strerror(errno), errno);
            } else {
                GWS_LOG_DEBUG(@"Did close IPv4 listening socket %i", self.socket);
            }
        }
    });
    dispatch_source_set_event_handler(source, ^{
        @autoreleasepool {
            [self readData:nil withLength:NSUIntegerMax completionBlock:^(BOOL success, NSData *data) {
                [self handleReceivedData:data];
            }];
        }
    });
    dispatch_resume(source);
    return source;
}

#pragma mark -

- (void)sendResponseHeaders {
    // Request (Draft 75):
    //
    // GET /demo HTTP/1.1
    // Upgrade: WebSocket
    // Connection: Upgrade
    // Host: example.com
    // Origin: http://example.com
    // WebSocket-Protocol: sample
    //
    //
    // Request (Draft 76):
    //
    // GET /demo HTTP/1.1
    // Upgrade: WebSocket
    // Connection: Upgrade
    // Host: example.com
    // Origin: http://example.com
    // Sec-WebSocket-Protocol: sample
    // Sec-WebSocket-Key2: 12998 5 Y3 1  .P00
    // Sec-WebSocket-Key1: 4 @1  46546xW%0l 1 5
    //
    // ^n:ds[4U

    // Response (Draft 75):
    //
    // HTTP/1.1 101 Web Socket Protocol Handshake
    // Upgrade: WebSocket
    // Connection: Upgrade
    // WebSocket-Origin: http://example.com
    // WebSocket-Location: ws://example.com/demo
    // WebSocket-Protocol: sample
    //
    //
    // Response (Draft 76):
    //
    // HTTP/1.1 101 WebSocket Protocol Handshake
    // Upgrade: WebSocket
    // Connection: Upgrade
    // Sec-WebSocket-Origin: http://example.com
    // Sec-WebSocket-Location: ws://example.com/demo
    // Sec-WebSocket-Protocol: sample
    //
    // 8jKS'y:G*Co,Wxa-

    // use Draft 75

    // request info
    NSDictionary *requestHeaders = CFBridgingRelease(CFHTTPMessageCopyAllHeaderFields(self.requestMessage));
    NSString *origin = [requestHeaders objectForKey:@"Origin"];
    NSString *host = [requestHeaders objectForKey:@"Host"];
    NSString *secWebSocketKey = [requestHeaders objectForKey:@"Sec-WebSocket-Key"];

    NSURL *requestURL = CFBridgingRelease(CFHTTPMessageCopyRequestURL(self.requestMessage));
    NSString *relativeString = [requestURL relativeString];

    // response
    CFHTTPMessageRef responseMessage = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 101, CFSTR("Web Socket Protocol Handshake"), kCFHTTPVersion1_1);
    CFHTTPMessageSetHeaderFieldValue(responseMessage, CFSTR("Connection"), CFSTR("Upgrade"));
    CFHTTPMessageSetHeaderFieldValue(responseMessage, CFSTR("Upgrade"), CFSTR("WebSocket"));

    // Note: It appears that WebSocket-Origin and WebSocket-Location
    // are required for Google's Chrome implementation to work properly.
    //
    // If we don't send either header, Chrome will never report the WebSocket as open.
    // If we only send one of the two, Chrome will immediately close the WebSocket.
    //
    // In addition to this it appears that Chrome's implementation is very picky of the values of the headers.
    // They have to match exactly with what Chrome sent us or it will close the WebSocket.
    CFHTTPMessageSetHeaderFieldValue(responseMessage, CFSTR("WebSocket-Origin"), (__bridge CFStringRef)origin);
    NSString *locationValue = [NSString stringWithFormat:@"ws://%@%@", host, relativeString];
    CFHTTPMessageSetHeaderFieldValue(responseMessage, CFSTR("WebSocket-Location"), (__bridge CFStringRef)locationValue);

    // Sec-WebSocket-Accept
    NSString *guid = @"258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
    NSString *acceptValue = [[secWebSocketKey stringByAppendingString:guid] dataUsingEncoding: NSUTF8StringEncoding].sha1Digest.base64Encoded;
    if (acceptValue.length > 0) {
        CFHTTPMessageSetHeaderFieldValue(responseMessage, CFSTR("Sec-WebSocket-Accept"), (__bridge CFStringRef)acceptValue);
    }

    CFDataRef data = CFHTTPMessageCopySerializedMessage(responseMessage);
    [self writeData:(__bridge NSData*)data withCompletionBlock:^(BOOL sucess) {}];
    CFRelease(data);
}

- (void)sendMessage:(NSString *)msg {
    NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *data = nil;

    NSUInteger length = msgData.length;
    if (length <= 125) {
        data = [NSMutableData dataWithCapacity:(length + 2)];
        [data appendBytes:"\x81" length:1];
        UInt8 len = (UInt8)length;
        [data appendBytes:&len length:1];
        [data appendData:msgData];
    } else if (length <= 0xFFFF) {
        data = [NSMutableData dataWithCapacity:(length + 4)];
        [data appendBytes:"\x81\x7E" length:2];
        UInt16 len = (UInt16)length;
        [data appendBytes:(UInt8[]){len >> 8, len & 0xFF} length:2];
        [data appendData:msgData];
    } else {
        data = [NSMutableData dataWithCapacity:(length + 10)];
        [data appendBytes:"\x81\x7F" length:2];
        [data appendBytes:(UInt8[]){0, 0, 0, 0, (UInt8)(length >> 24), (UInt8)(length >> 16), (UInt8)(length >> 8), length & 0xFF} length:8];
        [data appendData:msgData];
    }

    [self writeData:data withCompletionBlock:^(BOOL success) {}];
}

// WebSocket data frame structure https://github.com/abbshr/abbshr.github.io/issues/22
// 0                   1                   2                   3
// 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
// +-+-+-+-+-------+-+-------------+-------------------------------+
// |F|R|R|R| opcode|M| Payload len |    Extended payload length    |
// |I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
// |N|V|V|V|       |S|             |   (if payload len==126/127)   |
// | |1|2|3|       |K|             |                               |
// +-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
// |     Extended payload length continued, if payload len == 127  |
// + - - - - - - - - - - - - - - - +-------------------------------+
// |                               |Masking-key, if MASK set to 1  |
// +-------------------------------+-------------------------------+
// | Masking-key (continued)       |          Payload Data         |
// +-------------------------------- - - - - - - - - - - - - - - - +
// :                     Payload Data continued ...                :
// + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
// |                     Payload Data continued ...                |
// +---------------------------------------------------------------+
- (void)handleReceivedData:(NSData *)data {
    NSUInteger curPointPos = 0;     // pointer postion cursor
    NSUInteger msgLength;           // payload length
    NSUInteger opCode;
    BOOL frameMasked;
    NSData *maskingKey;

    NSData *tmp = [[NSData alloc] initWithBytes:(UInt8 *)[data bytes] length:1];// first byte
    curPointPos++;

    UInt8 frame = *(UInt8 *)[tmp bytes];
    if ([self isValidWebSocketFrame:frame]) {
        opCode = frame & 0x0F;
    } else {
        return;
    }

    tmp = [[NSData alloc] initWithBytes:((UInt8 *)[data bytes] + curPointPos) length:1];
    curPointPos++;

    frame = *(UInt8 *)[tmp bytes];
    frameMasked = WS_PAYLOAD_IS_MASKED(frame);
    NSUInteger length = WS_PAYLOAD_LENGTH(frame);

    if (length <= 125) {
        if (frameMasked) {
            maskingKey = [[NSData alloc] initWithBytes:((UInt8 *)[data bytes] + curPointPos) length:4];
            curPointPos += 4;
        }
        msgLength = length;
    } else if (length == 126) {
        tmp = [[NSData alloc] initWithBytes:((UInt8 *)[data bytes] + curPointPos) length:2];
        curPointPos += 2;

        UInt8 *pFrame = (UInt8 *)[tmp bytes];
        NSUInteger length = ((NSUInteger)pFrame[0] << 8) | (NSUInteger)pFrame[1];
        if (frameMasked) {
            maskingKey = [[NSData alloc] initWithBytes:((UInt8 *)[data bytes] + curPointPos) length:4];
            curPointPos += 4;
        }
        msgLength = length;
    } else {
        tmp = [[NSData alloc] initWithBytes:((UInt8 *)[data bytes] + curPointPos) length:8];
        curPointPos += 8;
        // FIXME: 64bit data size in memory?
        [self closeWebSocket];
        return;
    }

    NSData *remainingData = [[NSData alloc] initWithBytes:((UInt8 *)[data bytes] + curPointPos) length:msgLength];
    if (frameMasked && maskingKey) {
        NSMutableData *masked = [remainingData mutableCopy];
        UInt8 *pData = (UInt8 *)masked.mutableBytes;
        UInt8 *pMask = (UInt8 *)maskingKey.bytes;
        for (NSUInteger i = 0; i < msgLength; i++) {
            pData[i] = pData[i] ^ pMask[i % 4];
        }
        remainingData = masked;
    }
    if (opCode == WS_OP_TEXT_FRAME) {
        NSString *msg = [[NSString alloc] initWithBytes:[remainingData bytes] length:msgLength encoding:NSUTF8StringEncoding];
        [self didReceiveMessage:msg];
    } else {
        [self closeWebSocket];
    }
}

- (BOOL)isValidWebSocketFrame:(UInt8)frame {
    NSUInteger rsv =  frame & 0x70;
    NSUInteger opcode = frame & 0x0F;
    if (rsv || (3 <= opcode && opcode <= 7) || (0xB <= opcode && opcode <= 0xF)) {
        return NO;
    }
    return YES;
}

#pragma mark - basic write and read operation

- (void)writeData:(NSData *)data withCompletionBlock:(void(^)(BOOL))block {
    dispatch_data_t buffer = dispatch_data_create(data.bytes, data.length, dispatch_get_global_queue(self.server.dispatchQueuePriority, 0), ^{
        [data self];  // Keeps ARC from releasing data too early
    });
    dispatch_write(self.socket, buffer, dispatch_get_global_queue(self.server.dispatchQueuePriority, 0), ^(dispatch_data_t remainingData, int error) {
        @autoreleasepool {
            if (error == 0) {
                GWS_DCHECK(remainingData == NULL);
                block(YES);
            } else {
                GWS_LOG_ERROR(@"Error while writing to socket %i: %s (%i)", self.socket, strerror(error), error);
                block(NO);
            }
        }
    });
#if !OS_OBJECT_USE_OBJC_RETAIN_RELEASE
    dispatch_release(buffer);
#endif
}

- (void)readData:(NSData *)data withLength:(NSUInteger)length completionBlock:(void(^)(BOOL success, NSData *data))block {
    dispatch_read(self.socket, length, dispatch_get_global_queue(self.server.dispatchQueuePriority, 0), ^(dispatch_data_t buffer, int error) {
        @autoreleasepool {
            if (error == 0) {
                size_t size = dispatch_data_get_size(buffer);
                if (size > 0) {
                    NSMutableData *mData;
                    if (data) {
                        mData = [[NSMutableData alloc] initWithData:data];
                    } else {
                        mData = [[NSMutableData alloc] init];
                    }
                    dispatch_data_apply(buffer, ^bool(dispatch_data_t region, size_t chunkOffset, const void* chunkBytes, size_t chunkSize) {
                        [mData appendBytes:chunkBytes length:chunkSize];
                        return true;
                    });
                    block(YES, mData);
                } else {
                    GWS_LOG_WARNING(@"No data received from socket %i", self.socket);
                    block(NO, nil);
                }
            } else {
                GWS_LOG_ERROR(@"Error while reading from socket %i: %s (%i)", self.socket, strerror(error), error);
                block(NO, nil);
            }
        }
    });
}

#pragma mark - subclassing method

- (void)didOpen {
}

- (void)didReceiveMessage:(NSString *)msg {

}

- (void)didClose {
}

@end

@implementation NSData (DDData)

static char encodingTable[64] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };

- (NSData *)md5Digest
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];

    CC_MD5([self bytes], (CC_LONG)[self length], result);
    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

- (NSData *)sha1Digest
{
    unsigned char result[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1([self bytes], (CC_LONG)[self length], result);
    return [NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH];
}

- (NSString *)hexStringValue
{
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([self length] * 2)];

    const unsigned char *dataBuffer = [self bytes];
    int i;

    for (i = 0; i < [self length]; ++i)
    {
        [stringBuffer appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
    }

    return [stringBuffer copy];
}

- (NSString *)base64Encoded
{
    const unsigned char    *bytes = [self bytes];
    NSMutableString *result = [NSMutableString stringWithCapacity:[self length]];
    unsigned long ixtext = 0;
    unsigned long lentext = [self length];
    long ctremaining = 0;
    unsigned char inbuf[3], outbuf[4];
    unsigned short i = 0;
    unsigned short charsonline = 0, ctcopy = 0;
    unsigned long ix = 0;

    while( YES )
    {
        ctremaining = lentext - ixtext;
        if( ctremaining <= 0 ) break;

        for( i = 0; i < 3; i++ ) {
            ix = ixtext + i;
            if( ix < lentext ) inbuf[i] = bytes[ix];
            else inbuf [i] = 0;
        }

        outbuf [0] = (inbuf [0] & 0xFC) >> 2;
        outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
        outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
        outbuf [3] = inbuf [2] & 0x3F;
        ctcopy = 4;

        switch( ctremaining )
        {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }

        for( i = 0; i < ctcopy; i++ )
            [result appendFormat:@"%c", encodingTable[outbuf[i]]];

        for( i = ctcopy; i < 4; i++ )
            [result appendString:@"="];

        ixtext += 3;
        charsonline += 4;
    }

    return [NSString stringWithString:result];
}

- (NSData *)base64Decoded
{
    const unsigned char    *bytes = [self bytes];
    NSMutableData *result = [NSMutableData dataWithCapacity:[self length]];

    unsigned long ixtext = 0;
    unsigned long lentext = [self length];
    unsigned char ch = 0;
    unsigned char inbuf[4] = {0, 0, 0, 0};
    unsigned char outbuf[3] = {0, 0, 0};
    short i = 0, ixinbuf = 0;
    BOOL flignore = NO;
    BOOL flendtext = NO;

    while( YES )
    {
        if( ixtext >= lentext ) break;
        ch = bytes[ixtext++];
        flignore = NO;

        if( ( ch >= 'A' ) && ( ch <= 'Z' ) ) ch = ch - 'A';
        else if( ( ch >= 'a' ) && ( ch <= 'z' ) ) ch = ch - 'a' + 26;
        else if( ( ch >= '0' ) && ( ch <= '9' ) ) ch = ch - '0' + 52;
        else if( ch == '+' ) ch = 62;
        else if( ch == '=' ) flendtext = YES;
        else if( ch == '/' ) ch = 63;
        else flignore = YES;

        if( ! flignore )
        {
            short ctcharsinbuf = 3;
            BOOL flbreak = NO;

            if( flendtext )
            {
                if( ! ixinbuf ) break;
                if( ( ixinbuf == 1 ) || ( ixinbuf == 2 ) ) ctcharsinbuf = 1;
                else ctcharsinbuf = 2;
                ixinbuf = 3;
                flbreak = YES;
            }

            inbuf [ixinbuf++] = ch;

            if( ixinbuf == 4 )
            {
                ixinbuf = 0;
                outbuf [0] = ( inbuf[0] << 2 ) | ( ( inbuf[1] & 0x30) >> 4 );
                outbuf [1] = ( ( inbuf[1] & 0x0F ) << 4 ) | ( ( inbuf[2] & 0x3C ) >> 2 );
                outbuf [2] = ( ( inbuf[2] & 0x03 ) << 6 ) | ( inbuf[3] & 0x3F );

                for( i = 0; i < ctcharsinbuf; i++ )
                    [result appendBytes:&outbuf[i] length:1];
            }

            if( flbreak )  break;
        }
    }

    return [NSData dataWithData:result];
}

@end
