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
@protocol HSDGCDWebSocketDelegate;

@interface HSDGCDWebSocket : NSObject

@property (nonatomic, weak) id<HSDGCDWebSocketDelegate> webSocketDelegate;

/**
 * judge websocket request with header
 */
+ (BOOL)isWebSocketRequest:(NSDictionary *)requestHeaders;

/**
 * init method
 */
- (instancetype)initWithServer:(GCDWebServer *)server requestMessage:(CFHTTPMessageRef)requestMessage socket:(CFSocketNativeHandle)socket;

/**
 * send message from server to client
 */
- (void)sendMessage:(NSString *)msg;

@end

@protocol HSDGCDWebSocketDelegate <NSObject>

- (void)webSocketDidClose;

@end

NS_ASSUME_NONNULL_END
