//
//  HSDWebDebugDomain.h
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/11/5.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSDWebDebugDomain : NSObject

- (void)handleMethodWithName:(NSString *)methodName parameters:(NSDictionary *)params responseCallback:(void(^)(NSDictionary *result, NSError *error))responseCallback;

@end

