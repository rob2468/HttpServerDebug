//
//  CJDBCategoryManager.h
//  Closet
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CJCategoryDataModel;

@interface CJDBCategoryManager : NSObject

// 获取所有“分类”
+ (NSArray<CJCategoryDataModel *> *)fetchAllCategories;

// 添加“分类”
+ (void)addCategory:(CJCategoryDataModel *)category;

// 更新“分类”
+ (void)updateCategory:(CJCategoryDataModel *)category;

// 删除指定“分类”
+ (void)deleteCategoryWithID:(NSInteger)ID;

@end
