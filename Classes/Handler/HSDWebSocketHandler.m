//
//  HSDWebSocketHandler.m
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/5/31.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import "HSDWebSocketHandler.h"
#import "HSDComponentMiddleware.h"

@implementation HSDWebSocketHandler

- (void)didOpen {
    // redirect stderr
    [HSDComponentMiddleware consoleLogRedirectStandardErrorOutput:^(NSString *logStr) {
        [self sendMessage:logStr];
    }];
}

- (void)didReceiveMessage:(NSString *)msg {
    NSLog(@"HSDWEBSOCKET: didReceiveMessage: %@", msg);
}

- (void)didClose {
    // reset stderr
    [HSDComponentMiddleware consoleLogRecoverStandardErrorOutput];
}

@end
