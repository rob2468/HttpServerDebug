//
//  HSDComponentMiddleware.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/5/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDComponentMiddleware.h"
#import "HTTPDataResponse.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPMessage.h"
#import "HSDHttpConnection.h"
#import "HSDFileExplorerComponent.h"
#import "HSDDBInspectComponent.h"
#import "HSDViewDebugComponent.h"
#import "HSDSendInfoComponent.h"
#import "HSDFilePreviewComponent.h"
#import "HSDConsoleLogComponent.h"
#import "HSDManager+Project.h"
#import "HSDDefine.h"

@interface HSDComponentMiddleware ()

@property (strong, nonatomic) HSDConsoleLogComponent *consoleLogComponent;

@end

@implementation HSDComponentMiddleware

+ (instancetype)sharedInstance {
    static HSDComponentMiddleware *singletonMiddleware;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonMiddleware = [[HSDComponentMiddleware alloc] init];
    });
    return singletonMiddleware;
}

#pragma mark - File Explorer

/**
 *  request data
 */
+ (NSObject<HTTPResponse> *)fetchFileExplorerAPIResponsePaths:(NSArray *)paths parameters:(NSDictionary *)params {
    // parse data
    NSString *filePath = [params objectForKey:@"file_path"];
    filePath = [filePath stringByRemovingPercentEncoding];
    NSString *action = [params objectForKey:@"action"];

    id json;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (filePath.length == 0) {
        // request root path
        NSString *homeDirectory = NSHomeDirectory();
        NSArray *filesDataList = [HSDFileExplorerComponent constructFilesDataListInDirectory:homeDirectory];
        json = [filesDataList copy];
    } else {
        // specific file path
        if (action.length == 0) {
            // request directory contents or file attributes
            BOOL isDir;
            if ([fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
                if (isDir) {
                    // directory, construct directory contents
                    NSArray *filesDataList = [HSDFileExplorerComponent constructFilesDataListInDirectory:filePath];
                    json = [filesDataList copy];
                } else {
                    // file, construct attributes
                    json = [HSDFileExplorerComponent constructFileAttribute:filePath];
                }
            }
        } else if ([action isEqualToString:@"delete"]) {
            // delete directory or file
            BOOL isSuc;
            NSError *err;
            isSuc = [fileManager removeItemAtPath:filePath error:&err];
            if (isSuc && !err) {
                // delete successfully
                json = @{ @"errno" : @0 };
            } else {
                // delete failed
                json = @{ @"errno" : @(-1) };
            }
        }
    }
    // serialization
    NSData *data;
    if (json) {
        data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    }
    HTTPDataResponse *response;
    if (data) {
        response = [[HTTPDataResponse alloc] initWithData:data];
    }
    return response;
}

#pragma mark - Database Inspect

/**
 *  fetch html page
 */
+ (NSObject<HTTPResponse> *)fetchDatabaseHTMLResponse:(NSDictionary *)params withConnection:(HTTPConnection *)connection {
    NSObject<HTTPResponse> *response;
    
    // database file path
    NSString *dbPath = [params objectForKey:@"db_path"];

    if (dbPath.length > 0) {
        // fetch part of html
        dbPath = [dbPath stringByRemovingPercentEncoding];
        NSString *selectHtml = [HSDDBInspectComponent fetchTableNamesHTMLString:dbPath];
        if (selectHtml.length > 0) {
            NSString *documentRoot = [HSDManager fetchDocumentRoot];
            NSString *htmlPath = [documentRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"/pages/%@/%@.html", kHSDComponentDBInspect, kHSDComponentDBInspect]];
            NSDictionary *replacementDict =
            @{@"DB_FILE_PATH": dbPath,
              @"SELECT_HTML": selectHtml
              };
            response = [[HTTPDynamicFileResponse alloc] initWithFilePath:htmlPath forConnection:connection separator:kHSDTemplateSeparator replacementDictionary:replacementDict];
        }
    }
    return response;
}

/**
 *  request table data, database schema; execute sql
 */
+ (NSObject<HTTPResponse> *)fetchDatabaseAPIResponseModules:(NSArray *)modules parameters:(NSDictionary *)params {
    NSString *subModule;
    if ([modules count] > 0) {
        subModule = [modules objectAtIndex:0];
    }
    
    NSData *data;
    if (subModule.length == 0) {
        // query
        NSString *type = [params objectForKey:@"type"];
        NSString *dbPath = [params objectForKey:@"db_path"];
        dbPath = [dbPath stringByRemovingPercentEncoding];
        if ([type isEqualToString:@"schema"]) {
            data = [HSDDBInspectComponent queryDatabaseSchema:dbPath];
        } else {
            NSString *tableName = [params objectForKey:@"table_name"];
            data = [HSDDBInspectComponent queryTableData:dbPath tableName:tableName];
        }
    } else if ([subModule isEqualToString:@"execute_sql"]) {
        NSString *dbPath = [params objectForKey:@"db_path"];
        dbPath = [dbPath stringByRemovingPercentEncoding];
        NSString *sqlStr = [params objectForKey:@"sql"];
        sqlStr = [sqlStr stringByRemovingPercentEncoding];
        data = [HSDDBInspectComponent executeSQL:dbPath sql:sqlStr];
    }
    
    HTTPDataResponse *response;
    if (data) {
        response = [[HTTPDataResponse alloc] initWithData:data];
    }
    return response;
}

#pragma mark - View Debug

+ (NSObject<HTTPResponse> *)fetchViewDebugAPIResponseModules:(NSArray *)modules parameters:(NSDictionary *)params {
    NSObject<HTTPResponse> *response;
    NSString *subModule;
    if ([modules count] > 0) {
        subModule = [modules objectAtIndex:0];
    }
    if (subModule.length > 0) {
        if ([subModule isEqualToString:@"all_views"]) {
            // get all views data
            NSArray *allViewsData = [HSDViewDebugComponent fetchAllViewsDataInHierarchy];
            NSData *data = [NSJSONSerialization dataWithJSONObject:allViewsData options:0 error:nil];
            response = [[HTTPDataResponse alloc] initWithData:data];
        } else if ([subModule isEqualToString:@"select_view"]) {
            // one view
            NSString *memoryAddress = [params objectForKey:@"memory_address"];
            NSString *className = [params objectForKey:@"class_name"];
            UIView *view;

            if (memoryAddress.length > 0 && className.length > 0) {
                id obj = [HSDManager instanceOfMemoryAddress:memoryAddress];

                // type casting
                if (obj && [obj isKindOfClass:NSClassFromString(className)]) {
                    view = (UIView *)obj;
                }
            }

            NSString *thirdModule;
            if ([modules count] > 1) {
                thirdModule = [modules objectAtIndex:1];
            }
            if (view) {
                if ([thirdModule isEqualToString:@"snapshot"]) {
                    // get view snapshot
                    BOOL isSubviewsExcluding = [[params objectForKey:@"nosubviews"] boolValue];  // snapshot with or without subviews
                    NSString *frameStr = [params objectForKey:@"frame"];

                    // get clipped frame
                    CGRect clippedFrame = CGRectNull;
                    if (frameStr.length > 0) {
                        NSArray<NSString *> *frameComps = [frameStr componentsSeparatedByString:@","];
                        if ([frameComps count] == 4) {
                            clippedFrame.origin.x = [[frameComps objectAtIndex:0] doubleValue];
                            clippedFrame.origin.y = [[frameComps objectAtIndex:1] doubleValue];
                            clippedFrame.size.width = [[frameComps objectAtIndex:2] doubleValue];
                            clippedFrame.size.height = [[frameComps objectAtIndex:3] doubleValue];
                        }
                    }
                    if (CGRectEqualToRect(clippedFrame, CGRectNull)) {
                        clippedFrame = view.bounds;
                    }

                    NSData *data = [HSDViewDebugComponent snapshotImageData:view isSubviewsExcluding:isSubviewsExcluding clippedFrame:clippedFrame];
                    response = [[HTTPDataResponse alloc] initWithData:data];
                } else {
                    // empty
                }
            }
        }
    }
    return response;
}

#pragma mark - Send Info

+ (NSObject<HTTPResponse> *)fetchSendInfoAPIResponseForMethod:(NSString *)method paths:(NSArray *)paths parameters:(NSDictionary *)params withRequest:(HTTPMessage *)request {
    NSDictionary *responseDict;
    NSString *info;
    // parse info from request
    if ([method isEqualToString:@"GET"]) {
        if (params) {
            info = [params objectForKey:@"info"];
            info = [info stringByRemovingPercentEncoding];
        }
    } else if ([method isEqualToString:@"POST"]) {
        NSString *contentType = [request headerField:@"Content-Type"];
        if ([contentType hasPrefix:@"text/plain"]
            || [contentType hasPrefix:@"application/x-www-form-urlencoded"]) {
            NSData *infoData = [request body];
            info = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
        }
    }
    responseDict =  [HSDSendInfoComponent fetchResultWithInfo:info];
    
    // serialization
    NSData *responseData;
    if (responseDict) {
        responseData = [NSJSONSerialization dataWithJSONObject:responseDict options:0 error:nil];
    }
    if (!responseData) {
        responseData = [@"1" dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSObject<HTTPResponse> *response = [[HTTPDataResponse alloc] initWithData:responseData];
    return response;
}

#pragma mark - File Preview

+ (NSObject<HTTPResponse> *)fetchFilePreviewResponse:(NSDictionary *)params forMethod:(NSString *)method URI:(NSString *)path {
    HSDHttpDataResponse *response;
    NSString *contentType;
    NSString *filePath = [params objectForKey:@"file_path"];
    if (filePath.length > 0) {
        filePath = [filePath stringByRemovingPercentEncoding];
        NSData *data;
        if ([filePath isEqualToString:@"standardUserDefaults"]) {
            contentType = @"text/plain;charset=utf-8";
            
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
            NSString *str = [dict description];
            data = [str dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            // contents of file
            data = [HSDFilePreviewComponent fetchContentsWithFilePath:filePath contentType:&contentType];
        }
        if (data) {
            response = [[HSDHttpDataResponse alloc] initWithData:data contentType:contentType];
        }
    }
    if (!response) {
        contentType = @"text/plain;charset=utf-8";
        
        NSString *prompt = @"文件不存在或不支持预览";
        NSData *data = [prompt dataUsingEncoding:NSUTF8StringEncoding];
        response = [[HSDHttpDataResponse alloc] initWithData:data contentType:contentType];
    }
    return response;
}

#pragma mark - Console Log

/**
 *  redirect STDERR_FILENO
 */
+ (void)consoleLogRedirectStandardErrorOutput:(void(^)(NSString *))readCompletionBlock {
    HSDConsoleLogComponent *consoleLogComponent = [HSDComponentMiddleware sharedInstance].consoleLogComponent;
    consoleLogComponent.readCompletionBlock = readCompletionBlock;
    [consoleLogComponent redirectStandardErrorOutput];
}

/**
 *  reset STDERR_FILENO
 */
+ (void)consoleLogRecoverStandardErrorOutput {
    HSDConsoleLogComponent *consoleLogComponent = [HSDComponentMiddleware sharedInstance].consoleLogComponent;
    [consoleLogComponent recoverStandardErrorOutput];
}

#pragma mark - Getter

- (HSDConsoleLogComponent *)consoleLogComponent {
    if (!_consoleLogComponent) {
        _consoleLogComponent = [[HSDConsoleLogComponent alloc] init];
    }
    return _consoleLogComponent;
}

@end
