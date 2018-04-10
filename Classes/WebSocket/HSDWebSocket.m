//
//  HSDWebSocket.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/10.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDWebSocket.h"
#import "HSDManager.h"
#import "HSDConsoleLogController.h"

@implementation HSDWebSocket

- (void)didOpen {
    [super didOpen];
    
    // redirect stderr
    HSDConsoleLogController *consoleLogController = [HSDManager fetchTheConsoleLogController];
    [consoleLogController redirectStandardErrorOutput];
    
    HSDWebSocket __weak *weakSelf = self;
    consoleLogController.readCompletionBlock = ^(NSString *logStr) {
        [weakSelf sendMessage:logStr];
    };
}

- (void)didReceiveMessage:(NSString *)msg {
}

- (void)didClose {
    [super didClose];
    
    // reset stderr
    HSDConsoleLogController *consoleLogController = [HSDManager fetchTheConsoleLogController];
    [consoleLogController recoverStandardErrorOutput];
}

@end
