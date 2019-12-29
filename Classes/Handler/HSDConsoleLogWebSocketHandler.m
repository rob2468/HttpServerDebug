//
//  HSDConsoleLogWebSocketHandler.m
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/11/5.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import "HSDConsoleLogWebSocketHandler.h"
#import "HSDComponentMiddleware.h"
#import "HSDUtility.h"

@implementation HSDConsoleLogWebSocketHandler

- (void)didOpen:(NSString *)requestPath {
    // redirect stderr
    __weak __typeof(self) weakSelf = self;
    [HSDComponentMiddleware consoleLogRedirectStandardErrorOutput:^(NSString *logStr) {
        [weakSelf sendMessage:logStr];
    }];
}

- (void)didReceiveMessage:(NSString *)msg {
    HSD_LOG_DEBUG(@"didReceiveMessage: %@", msg);
}

- (void)didClose {
    // reset stderr
    [HSDComponentMiddleware consoleLogRecoverStandardErrorOutput];
}

@end
