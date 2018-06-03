//
//  HSDDBInspectComponent.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//
//  TODO: decouple from cocoahttpserver

#import <Foundation/Foundation.h>

@interface HSDDBInspectComponent : NSObject

/**
 *  all table names list
 */
+ (NSString *)fetchTableNamesHTMLString:(NSString *)dbPath;

/**
 *
 */
+ (NSData *)queryTableData:(NSString *)dbPath tableName:(NSString *)tableName;

/**
 *
 */
+ (NSData *)queryDatabaseSchema:(NSString *)dbPath;

/**
 *
 */
+ (NSData *)executeSQL:(NSString *)dbPath sql:(NSString *)sqlStr;

@end
