//
//  HSDWebSocket.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/10.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDWebSocket.h"

@implementation HSDWebSocket

- (void)didOpen {
    [super didOpen];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:3 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self sendMessage:[NSString stringWithFormat:@"%@", [NSDate date]]];
        }];

    });
}

- (void)didReceiveMessage:(NSString *)msg {
}

- (void)didClose {
    [super didClose];
}

@end
