//
//  HSDResponseInfo.m
//  HttpServerDebug
//
//  Created by 陈军 on 2018/11/5.
//  Copyright © 2018 chenjun. All rights reserved.
//

#import "HSDResponseInfo.h"

@implementation HSDResponseInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        self.data = nil;
        self.contentType = nil;
    }
    return self;
}

@end
