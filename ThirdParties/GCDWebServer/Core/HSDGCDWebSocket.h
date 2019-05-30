//
//  HSDGCDWebSocket.h
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/4/17.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GCDWebServer;

@interface HSDGCDWebSocket : NSObject

+ (BOOL)isWebSocketRequest:(NSDictionary *)requestHeaders;

- (instancetype)initWithServer:(GCDWebServer *)server requestMessage:(CFHTTPMessageRef)requestMessage socket:(CFSocketNativeHandle)socket;

- (void)start;

@end

NS_ASSUME_NONNULL_END
