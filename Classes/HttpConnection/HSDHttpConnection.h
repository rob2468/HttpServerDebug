//
//  HSDHttpConnection.h
//  HttpServerDebug
//
//  Created by chenjun on 22/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "HTTPConnection.h"
#import "HTTPDataResponse.h"
#import "HTTPFileResponse.h"

@interface HSDHttpConnection : HTTPConnection

@property (strong, nonatomic) NSFileHandle *storeFile;

@end

@interface HSDHttpDataResponse : HTTPDataResponse

- (instancetype)initWithData:(NSData *)data contentType:(NSString *)type;

@end

@interface HTTPFileResponse (Generic)

- (void)setHSDContentType:(NSString *)contentType;

/**
 *  add unrealized HTTPResponse method httpHeaders for HTTPFileResponse
 */
- (NSDictionary *)httpHeaders;

@end
