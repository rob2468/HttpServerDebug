//
//  HSDWebSocket.h
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/4/17.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSDWebSocket : NSObject

+ (BOOL)isWebSocketRequest:(NSDictionary *)requestHeaders;

@end

NS_ASSUME_NONNULL_END
