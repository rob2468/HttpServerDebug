//
//  HSDHostNameResolveComponent.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//
//  used to resolve HttpServerDebug host name

#import <Foundation/Foundation.h>
#import "HSDManager+Project.h"

@interface HSDHostNameResolveComponent : NSObject

/**
 *
 */
- (void)resolveHostName:(HSDHostNameResolveBlock)block;

@end
