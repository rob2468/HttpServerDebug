//
//  HSDSampleDBManager.m
//  Sample
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDSampleDBManager.h"
#import "FMDB.h"

static const NSInteger kCurrentVersion = 1;

// 表名
NSString * const kTABLECATEGORY = @"category";
// 字段名
NSString * const kCATEGORYFIELDID = @"id";
NSString * const kCATEGORYFIELDNAME = @"name";

@interface HSDSampleDBManager ()

@property (strong, nonatomic) NSURL *dbFilePath;
@property (strong, nonatomic, readwrite) FMDatabaseQueue *databaseQueue;

@end

@implementation HSDSampleDBManager

+ (instancetype)sharedInstance {
    static HSDSampleDBManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HSDSampleDBManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURL *path = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
        self.dbFilePath = [path URLByAppendingPathComponent:@"Closet.sqlite"];
        self.databaseQueue = [[FMDatabaseQueue alloc] initWithURL:self.dbFilePath];
        // 读取数据库版本号
        __block NSInteger version = 0;
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            FMResultSet *rs = [db executeQuery:@"PRAGMA user_version"];
            if (rs) {
                FMResultSet *resultSet = rs;
                if ([resultSet next]) {
                    version = [resultSet intForColumnIndex:0];
                }
                [resultSet close];
            }
            
        }];
        NSAssert(version <= kCurrentVersion, @"");
        // 数据库升级
        [self upgradeDatabaseFromVersion:version];
    }
    return self;
}

- (void)upgradeDatabaseFromVersion:(NSInteger)version {
    // 数据库逐版本升级
    for (NSInteger i = version; i < kCurrentVersion; i++) {
        if (i == 0) {
            [self.databaseQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
                // 创建“分类”表
                NSString *stat = [NSString stringWithFormat:@"CREATE TABLE %@ (%@ INTEGER PRIMARY KEY AUTOINCREMENT, %@ TEXT);", kTABLECATEGORY, kCATEGORYFIELDID, kCATEGORYFIELDNAME];
                [db executeUpdate:stat];
            }];
        }
    }

    // 更新数据库版本号
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *stat = [NSString stringWithFormat:@"PRAGMA user_version = %ld;", (long)kCurrentVersion];
        [db executeUpdate:stat];
    }];
}

@end
