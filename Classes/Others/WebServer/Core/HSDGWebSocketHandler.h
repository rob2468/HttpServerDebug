//
//  HSDGWebSocketHandler.h
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/11/5.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol HSDGWebSocketHandlerDelegate;

@interface HSDGWebSocketHandler: NSObject

@property (weak, nonatomic) id<HSDGWebSocketHandlerDelegate> delegate;

- (void)didOpen:(NSString *)requestPath;

- (void)didReceiveMessage:(NSString *)msg;

- (void)didClose;

#pragma mark -

- (void)sendMessage:(NSString *)msg;

@end

@protocol HSDGWebSocketHandlerDelegate <NSObject>

- (void)onWebSocketHandlerSendMessage:(NSString *)msg;

@end
