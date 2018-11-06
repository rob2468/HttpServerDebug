//
//  HSDComponentMiddleware.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/5/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//
//  middleware between the http server and the core ability

#import <Foundation/Foundation.h>

@class HSDResponseInfo;

@interface HSDComponentMiddleware : NSObject

#pragma mark - File Explorer

/**
 *  request data
 */
+ (HSDResponseInfo *)fetchFileExplorerAPIResponseInfo:(NSDictionary *)params;

#pragma mark - Database Inspect

/**
 *  request table data, database schema; execute sql
 */
+ (HSDResponseInfo *)fetchDatabaseAPIResponseInfo:(NSDictionary *)params;

#pragma mark - View Debug

/**
 *
 */
+ (HSDResponseInfo *)fetchViewDebugAPIResponseInfo:(NSDictionary *)params;

#pragma mark - Send Info

+ (HSDResponseInfo *)fetchSendInfoAPIResponseInfo:(NSString *)infoStr;

#pragma mark - File Preview

+ (HSDResponseInfo *)fetchFilePreviewResponseInfo:(NSDictionary *)params;

#pragma mark - Console Log

/**
 *  redirect STDERR_FILENO
 */
+ (void)consoleLogRedirectStandardErrorOutput:(void(^)(NSString *))readCompletionBlock;

/**
 *  reset STDERR_FILENO
 */
+ (void)consoleLogRecoverStandardErrorOutput;

@end
