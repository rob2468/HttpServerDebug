//
//  CJDBProductItemManager.m
//  Closet
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "CJDBProductItemManager.h"
#import "CJProductItemDataModel.h"
#import "FMDB.h"
#import "CJDBManager.h"

static NSString * const kImagePathValuesSeparator = @":";         // 单品数据库中，imagePath字段，多个值使用该分隔符间隔

@implementation CJDBProductItemManager

// 添加单品
+ (void)addProductItem:(CJProductItemDataModel *)productItem {
    FMDatabaseQueue *databaseQueue = [CJDBManager sharedInstance].databaseQueue;
    [databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *tableName = kTABLEPRODUCT;
        NSString *nameField = kPRODUCTFIELDNAME;
        NSString *priceField = kPRODUCTFIELDPRICE;
        NSString *imagePathField = kPRODUCTFIELDIMAGEPATH;
        NSString *name = productItem.name;
        name = name.length > 0 ? name : @"";
        double price = productItem.price;
        NSString *imagePath;
        NSArray<NSString *> *imagePaths = [productItem.imagePath copy];
        imagePath = [imagePaths componentsJoinedByString:kImagePathValuesSeparator];
        imagePath = imagePath.length > 0 ? imagePath : @"";
        NSString *stat = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@) VALUES (%@, %f, %@);", tableName, nameField, priceField, imagePathField, name, price, imagePath];
        [db executeUpdate:stat];
    }];
}

@end
