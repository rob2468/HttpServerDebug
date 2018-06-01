//
//  HSDSampleCategoryDataModel.m
//  Sample
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDSampleCategoryDataModel.h"

@implementation HSDSampleCategoryDataModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.ID = NSNotFound;
        self.name = @"";
    }
    return self;
};

@end
