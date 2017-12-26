//
//  BDHttpServerDebugDelegate.h
//  HttpServerDebug
//
//  Created by chenjun on 2017/12/26.
//  Copyright © 2017年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BDHttpServerDebugDelegate <NSObject>

@optional

/**
 *  
 */
- (void)onHSDReceiveInfo:(NSString *)info;

@end
