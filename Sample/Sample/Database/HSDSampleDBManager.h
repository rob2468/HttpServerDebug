//
//  HSDSampleDBManager.h
//  Sample
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabaseQueue;

// 表名
extern NSString * const kTABLECATEGORY;
// 字段名
extern NSString * const kCATEGORYFIELDID;
extern NSString * const kCATEGORYFIELDNAME;

@interface HSDSampleDBManager : NSObject

@property (strong, nonatomic, readonly) FMDatabaseQueue *databaseQueue;

+ (instancetype)sharedInstance;

@end
