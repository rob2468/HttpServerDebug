//
//  HSDWebSocket.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/10.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDWebSocket.h"
#import "HSDManager+Private.h"
#import "HSDComponentMiddleware.h"

@implementation HSDWebSocket

- (void)didOpen {
    [super didOpen];
    
    // redirect stderr
    [HSDComponentMiddleware consoleLogRedirectStandardErrorOutput:^(NSString *logStr) {
        [self sendMessage:logStr];
    }];
}

- (void)didReceiveMessage:(NSString *)msg {
}

- (void)didClose {
    [super didClose];
    
    // reset stderr
    [HSDComponentMiddleware consoleLogRecoverStandardErrorOutput];
}

@end
