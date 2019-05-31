//
//  HSDConsoleLogComponent.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/10.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSDConsoleLogComponent : NSObject

/**
 *  finish reading from stderr
 */
@property (nonatomic, copy) void(^readCompletionBlock)(NSString *);

/**
 *
 */
- (NSArray<NSString *> *)consumeLogs;

#pragma mark - state

/**
 *  is log output redirected
 */
- (BOOL)isRedirected;

#pragma mark - behaviour control

/**
 *  redirect STDERR_FILENO
 */
- (void)redirectStandardErrorOutput;

/**
 *  reset STDERR_FILENO
 */
- (void)recoverStandardErrorOutput;

@end
