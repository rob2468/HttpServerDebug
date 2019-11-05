//
//  HSDGWebSocketHandler.m
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/11/5.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import "HSDGWebSocketHandler.h"

@implementation HSDGWebSocketHandler

- (void)didOpen:(NSString *)requestPath {
}

- (void)didReceiveMessage:(NSString *)msg {
}

- (void)didClose {
}

#pragma mark -

- (void)sendMessage:(NSString *)msg {
    if ([self.delegate respondsToSelector:@selector(onWebSocketHandlerSendMessage:)]) {
        [self.delegate onWebSocketHandlerSendMessage:msg];
    }
}

@end

