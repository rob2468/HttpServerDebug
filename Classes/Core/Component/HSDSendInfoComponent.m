//
//  HSDSendInfoComponent.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDSendInfoComponent.h"
#import "HSDManager+Project.h"
#import "HSDDelegate.h"

@implementation HSDSendInfoComponent

+ (NSDictionary *)fetchResultWithInfo:(NSString *)info {
    NSDictionary *responseDict;
    // forward to the delegate
    id<HSDDelegate> delegate = [HSDManager fetchHSDDelegate];
    if ([delegate respondsToSelector:@selector(onHSDReceiveInfo:)]) {
        NSDictionary *result = [delegate onHSDReceiveInfo:info];
        if (result) {
            // construct response data
            responseDict = @{@"data": result};
        }
    }
    return responseDict;
}

@end
