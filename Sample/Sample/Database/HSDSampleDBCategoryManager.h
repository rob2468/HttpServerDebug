//
//  HSDSampleDBCategoryManager.h
//  Sample
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HSDSampleCategoryDataModel;

@interface HSDSampleDBCategoryManager : NSObject

// 获取所有“分类”
+ (NSArray<HSDSampleCategoryDataModel *> *)fetchAllCategories;

// 添加“分类”
+ (void)addCategory:(HSDSampleCategoryDataModel *)category;

// 更新“分类”
+ (void)updateCategory:(HSDSampleCategoryDataModel *)category;

// 删除指定“分类”
+ (void)deleteCategoryWithID:(NSInteger)ID;

@end
