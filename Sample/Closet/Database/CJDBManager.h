//
//  CJDBManager.h
//  Closet
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabaseQueue;

// 表名
extern NSString * const kTABLECATEGORY;
extern NSString * const kTABLEPRODUCT;
// 字段名
extern NSString * const kCATEGORYFIELDID;
extern NSString * const kCATEGORYFIELDNAME;
extern NSString * const kPRODUCTFIELDID;
extern NSString * const kPRODUCTFIELDNAME;
extern NSString * const kPRODUCTFIELDPRICE;
extern NSString * const kPRODUCTFIELDIMAGEPATH;

@interface CJDBManager : NSObject

@property (strong, nonatomic, readonly) FMDatabaseQueue *databaseQueue;

+ (instancetype)sharedInstance;

@end
