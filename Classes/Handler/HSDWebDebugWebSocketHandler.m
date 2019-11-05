//
//  HSDWebDebugWebSocketHandler.m
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/11/5.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import "HSDWebDebugWebSocketHandler.h"

@implementation HSDWebDebugWebSocketHandler

- (void)didOpen:(NSString *)requestPath {

}

- (void)didReceiveMessage:(NSString *)msg {
    NSLog(@"HSDWEBSOCKET: didReceiveMessage: %@", msg);
}

- (void)didClose {

}

@end
