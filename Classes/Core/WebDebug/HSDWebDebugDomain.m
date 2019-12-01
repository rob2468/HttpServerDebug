//
//  HSDWebDebugDomain.m
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/11/5.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import "HSDWebDebugDomain.h"

@interface HSDWebDebugDomain()

@end

@implementation HSDWebDebugDomain

- (void)handleMethodWithName:(NSString *)methodName parameters:(NSDictionary *)params responseCallback:(void(^)(NSDictionary *result, NSError *error))responseCallback {
    if (responseCallback) {
        responseCallback(nil, nil);
    }
}

@end
