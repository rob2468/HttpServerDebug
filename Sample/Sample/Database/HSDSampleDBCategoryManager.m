//
//  HSDSampleDBCategoryManager.m
//  Sample
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDSampleDBCategoryManager.h"
#import "HSDSampleCategoryDataModel.h"
#import "FMDB.h"
#import "HSDSampleDBManager.h"

@implementation HSDSampleDBCategoryManager

// 获取所有“分类”
+ (NSArray<HSDSampleCategoryDataModel *> *)fetchAllCategories {
    NSMutableArray<HSDSampleCategoryDataModel *> *dataList = [[NSMutableArray alloc] init];
    FMDatabaseQueue *databaseQueue = [HSDSampleDBManager sharedInstance].databaseQueue;
    [databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *tableCategory = kTABLECATEGORY;
        NSString *stat = [NSString stringWithFormat:@"SELECT * FROM %@;", tableCategory];
        FMResultSet *resultSet = [db executeQuery:stat];
        if (resultSet) {
            FMResultSet *rs = resultSet;
            NSString *categoryFieldID = kCATEGORYFIELDID;
            NSString *categoryFieldName = kCATEGORYFIELDNAME;
            while ([rs next]) {
                NSInteger ID = [rs longForColumn:categoryFieldID];
                NSString *name = [rs stringForColumn:categoryFieldName];
                HSDSampleCategoryDataModel *category = [[HSDSampleCategoryDataModel alloc] init];
                category.ID = ID;
                category.name = name;
                [dataList addObject:category];
            }
            [rs close];
        }
    }];
    return dataList;
}

// 添加“分类”
+ (void)addCategory:(HSDSampleCategoryDataModel *)category {
    FMDatabaseQueue *databaseQueue = [HSDSampleDBManager sharedInstance].databaseQueue;
    [databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *tableName = kTABLECATEGORY;
        NSString *nameField = kCATEGORYFIELDNAME;
        NSString *name = category.name;
        NSString *stat = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES ('%@');", tableName, nameField, name];
        [db executeUpdate:stat];
    }];
}

// 更新“分类”
+ (void)updateCategory:(HSDSampleCategoryDataModel *)category {
    FMDatabaseQueue *databaseQueue = [HSDSampleDBManager sharedInstance].databaseQueue;
    [databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *tableName = kTABLECATEGORY;
        NSString *idField = kCATEGORYFIELDID;
        NSString *nameField = kCATEGORYFIELDNAME;
        NSInteger ID = category.ID;
        NSString *name = category.name;
        NSString *stat = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE %@ = %ld;", tableName, nameField, name, idField, (long)ID];
        [db executeUpdate:stat];
    }];
}

// 删除指定“分类”
+ (void)deleteCategoryWithID:(NSInteger)ID {
    FMDatabaseQueue *databaseQueue = [HSDSampleDBManager sharedInstance].databaseQueue;
    [databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *tableCategory = kTABLECATEGORY;
        NSString *categoryFieldID = kCATEGORYFIELDID;
        NSString *stat = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %ld;", tableCategory, categoryFieldID, (long)ID];
        [db executeUpdate:stat];
    }];
}

@end
