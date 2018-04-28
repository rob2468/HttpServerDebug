//
//  HSDWebSocket.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/10.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDWebSocket.h"
#import "HSDManager+Private.h"
#import "HSDConsoleLogComponent.h"

@implementation HSDWebSocket

- (void)didOpen {
    [super didOpen];
    
    // redirect stderr
    HSDConsoleLogComponent *consoleLogComponent= [HSDManager fetchTheConsoleLogComponent];
    [consoleLogComponent redirectStandardErrorOutput];
    
    HSDWebSocket __weak *weakSelf = self;
    consoleLogComponent.readCompletionBlock = ^(NSString *logStr) {
        [weakSelf sendMessage:logStr];
    };
}

- (void)didReceiveMessage:(NSString *)msg {
}

- (void)didClose {
    [super didClose];
    
    // reset stderr
    HSDConsoleLogComponent *consoleLogComponent = [HSDManager fetchTheConsoleLogComponent];
    [consoleLogComponent recoverStandardErrorOutput];
}

@end
