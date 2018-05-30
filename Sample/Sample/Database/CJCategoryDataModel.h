//
//  CJCategoryDataModel.h
//  Closet
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//
//  “分类”数据模型

#import <Foundation/Foundation.h>

@interface CJCategoryDataModel : NSObject

@property (assign, nonatomic) NSInteger ID; // 唯一标识符
@property (copy, nonatomic) NSString *name; // 分类名

- (instancetype)init;

@end
