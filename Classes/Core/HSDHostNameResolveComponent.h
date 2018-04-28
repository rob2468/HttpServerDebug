//
//  HSDHostNameResolveComponent.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSDManager+Private.h"

@interface HSDHostNameResolveComponent : NSObject

- (void)resolveHostName:(HostNameResolveBlock)block;

@end
