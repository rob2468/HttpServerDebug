//
//  HSDComponentMiddleware.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/5/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HTTPConnection;
@class HTTPMessage;
@protocol HTTPResponse;

@interface HSDComponentMiddleware : NSObject

#pragma mark - File Explorer

/**
 *  request data
 */
+ (NSObject<HTTPResponse> *)fetchFileExplorerAPIResponsePaths:(NSArray *)paths parameters:(NSDictionary *)params;

#pragma mark - Database Inspect

/**
 *  fetch html page
 */
+ (NSObject<HTTPResponse> *)fetchDatabaseHTMLResponse:(NSDictionary *)params withConnection:(HTTPConnection *)connection;

/**
 *  request table data, database schema; execute sql
 */
+ (NSObject<HTTPResponse> *)fetchDatabaseAPIResponseModules:(NSArray *)modules parameters:(NSDictionary *)params;

#pragma mark - View Debug

/**
 *
 */
+ (NSObject<HTTPResponse> *)fetchViewDebugAPIResponseModules:(NSArray *)modules parameters:(NSDictionary *)params;

#pragma mark - Send Info

+ (NSObject<HTTPResponse> *)fetchSendInfoAPIResponseForMethod:(NSString *)method paths:(NSArray *)paths parameters:(NSDictionary *)params withRequest:(HTTPMessage *)request;

#pragma mark - File Preview

+ (NSObject<HTTPResponse> *)fetchFilePreviewResponse:(NSDictionary *)params forMethod:(NSString *)method URI:(NSString *)path;

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
