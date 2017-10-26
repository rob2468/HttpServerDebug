//
//  BDHttpServerConnection.h
//  BaiduBrowser
//
//  Created by chenjun on 22/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "HTTPConnection.h"
#import "HTTPDataResponse.h"

@interface BDHttpServerConnection : HTTPConnection

@property (strong, nonatomic) NSFileHandle *storeFile;

@end

@interface BDHttpServerDataResponse : HTTPDataResponse

- (instancetype)initWithData:(NSData *)data contentType:(NSString *)type;

@end

