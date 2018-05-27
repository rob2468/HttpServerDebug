//
//  CJProductItemDataModel.h
//  Closet
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//
//  "单品“数据模型

#import <Foundation/Foundation.h>

@interface CJProductItemDataModel : NSObject

@property (assign, nonatomic) NSInteger ID; // 唯一标识符
@property (copy, nonatomic) NSString *name; // 单品名称
@property (assign, nonatomic) double price; // 价格
@property (strong, nonatomic) NSArray<NSString *> *imagePath; // 照片本地存放路径（第一张图片为默认图片）

- (instancetype)init;

@end
