//
//  HSDGCDWebSocket.h
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/4/17.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HSDGWebServer;
@class HSDGWebSocketHandler;
@protocol HSDGWebSocketDelegate;

@interface HSDGWebSocket : NSObject

@property (nonatomic, weak) id<HSDGWebSocketDelegate> webSocketDelegate;

/**
 * judge websocket request with header
 */
+ (BOOL)isWebSocketRequest:(NSDictionary *)requestHeaders;

/**
 * init method
 */
- (instancetype)initWithServer:(HSDGWebServer *)server requestMessage:(CFHTTPMessageRef)requestMessage socket:(CFSocketNativeHandle)socket handler:(HSDGWebSocketHandler *)handler;

/**
 * send message from server to client
 */
- (void)sendMessage:(NSString *)msg;

@end

@protocol HSDGWebSocketDelegate <NSObject>

- (void)webSocketDidClose;

@end

NS_ASSUME_NONNULL_END
