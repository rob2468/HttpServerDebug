//
//  HSDHttpConnection.h
//  HttpServerDebug
//
//  Created by chenjun on 22/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "HTTPConnection.h"
#import "HTTPDataResponse.h"

@interface HSDHttpConnection : HTTPConnection

@property (strong, nonatomic) NSFileHandle *storeFile;

@end

@interface HSDHttpDataResponse : HTTPDataResponse

- (instancetype)initWithData:(NSData *)data contentType:(NSString *)type;

@end

