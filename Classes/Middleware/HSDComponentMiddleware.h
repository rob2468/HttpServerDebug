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
@class HSDWebDebugDomain;

@interface HSDComponentMiddleware : NSObject

+ (instancetype)sharedInstance;

#pragma mark - File Explorer

/**
 *  request data
 */
+ (HSDResponseInfo *)fetchFileExplorerAPIResponseInfo:(NSDictionary *)params;

/**
 *  move the uploaded file, from the temporary path to the target path
 *  @param temporaryPath  the uploaded file's temporay path
 *  @param targetDirectory  the target directory
 *  @param targetFileName  the target file name
 *  @return response info
 */
+ (HSDResponseInfo *)uploadTemporaryFile:(NSString *)temporaryPath targetDirectory:(NSString *)targetDirectory fileName:(NSString *)targetFileName;

#pragma mark - Database Inspect

+ (NSDictionary *)fetchDatabaseAPITemplateHTMLReplacement:(NSDictionary *)params;

/**
 *  request table data, database schema; execute sql
 */
+ (HSDResponseInfo *)fetchDatabaseAPIResponseInfo:(NSDictionary *)params;

#pragma mark - View Debug

/**
 *  view debug
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

#pragma mark - Web Debug

+ (NSDictionary *)fetchWebDebugTemplateHTMLReplacement;

#pragma mark -

/**
 *
 */
+ (NSString *)formatTemplateString:(NSString *)str variables:(NSDictionary *)variables;

#pragma mark - localization

/**
 * localize text, content needs to be localized is marked in style: %%LocalizedLanguageName%%
 */
+ (NSString *)localize:(NSString *)local text:(NSString *)text;

/**
 * get localized json
 */
+ (NSDictionary *)localizationJSON:(NSString *)local;

@end
