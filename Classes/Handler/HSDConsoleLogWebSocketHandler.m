//
//  HSDConsoleLogWebSocketHandler.m
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/11/5.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import "HSDConsoleLogWebSocketHandler.h"
#import "HSDComponentMiddleware.h"

@implementation HSDConsoleLogWebSocketHandler

- (void)didOpen:(NSString *)requestPath {
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
