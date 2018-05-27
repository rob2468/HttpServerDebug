//
//  CJDBProductItemManager.h
//  Closet
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CJProductItemDataModel;

@interface CJDBProductItemManager : NSObject

// 添加单品
+ (void)addProductItem:(CJProductItemDataModel *)productItem;

@end
