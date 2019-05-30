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

@interface NSData (DDData)

- (NSData *)md5Digest;

- (NSData *)sha1Digest;

- (NSString *)hexStringValue;

- (NSString *)base64Encoded;
- (NSData *)base64Decoded;

@end

@interface HSDGCDWebSocket ()

@property (nonatomic, weak) GCDWebServer *server;
@property (nonatomic, assign) CFSocketNativeHandle socket;
@property (nonatomic, assign) CFHTTPMessageRef requestMessage;

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
    }
    return self;
}

- (void)start {
    [self sendResponseHeaders];
}

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
    [self writeData:(__bridge NSData*)data withCompletionBlock:^(BOOL sucess) {

    }];
    CFRelease(data);
}

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
