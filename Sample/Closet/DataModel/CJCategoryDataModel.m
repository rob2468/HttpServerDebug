//
//  CJCategoryDataModel.m
//  Closet
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "CJCategoryDataModel.h"

@implementation CJCategoryDataModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.ID = NSNotFound;
        self.name = @"";
    }
    return self;
};

@end
