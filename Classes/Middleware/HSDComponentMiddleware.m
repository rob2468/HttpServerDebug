//
//  HSDComponentMiddleware.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/5/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDComponentMiddleware.h"
#import "HSDFileExplorerComponent.h"
#import "HSDDBInspectComponent.h"
#import "HSDViewDebugComponent.h"
#import "HSDSendInfoComponent.h"
#import "HSDFilePreviewComponent.h"
#import "HSDConsoleLogComponent.h"
#import "HSDManager+Project.h"
#import "HSDDefine.h"
#import "HSDResponseInfo.h"

@interface HSDComponentMiddleware ()

@property (nonatomic, strong) HSDConsoleLogComponent *consoleLogComponent;

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
+ (HSDResponseInfo *)fetchFileExplorerAPIResponseInfo:(NSDictionary *)params {
    // parse data
    NSString *filePath = [params objectForKey:@"file_path"];
    filePath = [filePath stringByRemovingPercentEncoding];
    NSString *action = [params objectForKey:@"action"];

    NSInteger errorNum = 0;
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
                errorNum = 0;
            } else {
                // delete failed
                errorNum = -1;
            }
        }
    }

    // response json
    NSMutableDictionary *responseJSON = [[NSMutableDictionary alloc] init];
    if (json) {
        [responseJSON setObject:json forKey:@"data"];
    }
    [responseJSON setObject:@(errorNum) forKey:@"errno"];
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseJSON options:0 error:nil];

    HSDResponseInfo *responseInfo = [[HSDResponseInfo alloc] init];
    responseInfo.data = responseData;
    responseInfo.contentType = @"text/plain;charset=utf-8";
    return responseInfo;
}

#pragma mark - Database Inspect

/**
 *  request table data, database schema; execute sql
 */
+ (HSDResponseInfo *)fetchDatabaseAPIResponseInfo:(NSDictionary *)params {
    NSString *action = [params objectForKey:@"action"];

    id data;                // business data
    if (action.length == 0) {
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
    } else if ([action isEqualToString:@"execute_sql"]) {
        NSString *dbPath = [params objectForKey:@"db_path"];
        dbPath = [dbPath stringByRemovingPercentEncoding];
        NSString *sqlStr = [params objectForKey:@"sql"];
        sqlStr = [sqlStr stringByRemovingPercentEncoding];
        data = [HSDDBInspectComponent executeSQL:dbPath sql:sqlStr];
    }

    // response data
    NSMutableDictionary *responseJSON = [[NSMutableDictionary alloc] init];
    NSInteger errorNum;     // error code
    if (data) {
        errorNum = 0;
        [responseJSON setObject:data forKey:@"data"];
    } else {
        errorNum = -1;
    }
    [responseJSON setObject:@(errorNum) forKey:@"errno"];
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseJSON options:0 error:nil];

    HSDResponseInfo *responseInfo = [[HSDResponseInfo alloc] init];
    responseInfo.data = responseData;
    responseInfo.contentType = @"text/plain;charset=utf-8";
    return responseInfo;
}

#pragma mark - View Debug

+ (HSDResponseInfo *)fetchViewDebugAPIResponseInfo:(NSDictionary *)params {
    NSString *action = [params objectForKey:@"action"];

    NSData *data;
    NSString *contentType = @"text/plain;charset=utf-8";
    if (action.length > 0) {
        if ([action isEqualToString:@"all_views"]) {
            // get all views data
            NSArray *allViewsData = [HSDViewDebugComponent fetchAllViewsDataInHierarchy];
            data = [NSJSONSerialization dataWithJSONObject:allViewsData options:0 error:nil];
        } else if ([action isEqualToString:@"select_view"]) {
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

            NSString *subAction = [params objectForKey:@"subaction"];
            if (view) {
                if ([subAction isEqualToString:@"snapshot"]) {
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

                    data = [HSDViewDebugComponent snapshotImageData:view isSubviewsExcluding:isSubviewsExcluding clippedFrame:clippedFrame];
                    contentType = @"image/png";
                } else {
                    // empty
                }
            }
        }
    }

    HSDResponseInfo *responseInfo = [[HSDResponseInfo alloc] init];
    if (data) {
        responseInfo.data = data;
        responseInfo.contentType = contentType;
    }
    return responseInfo;
}

#pragma mark - Send Info

+ (HSDResponseInfo *)fetchSendInfoAPIResponseInfo:(NSString *)infoStr {
    NSDictionary *result =  [HSDSendInfoComponent fetchResultWithInfo:infoStr];
    NSInteger errorNum;
    if (result) {
        // success
        errorNum = 0;
    } else {
        // fail
        errorNum = -1;
        result = [[NSDictionary alloc] init];
    }

    // construct response data
    NSDictionary *responseDict =
    @{
      @"data" : result,
      @"errno" : @(errorNum)
      };

    // serialization
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDict options:0 error:nil];

    HSDResponseInfo *responseInfo = [[HSDResponseInfo alloc] init];
    responseInfo.data = responseData;
    responseInfo.contentType = @"text/plain;charset=utf-8";
    return responseInfo;
}

#pragma mark - File Preview

+ (HSDResponseInfo *)fetchFilePreviewResponseInfo:(NSDictionary *)params {
    HSDResponseInfo *responseInfo = [[HSDResponseInfo alloc] init];

    NSString *contentType;
    NSString *filePath = [params objectForKey:@"file_path"];
    if (filePath.length > 0) {
        filePath = [filePath stringByRemovingPercentEncoding];
        NSData *data;
        if ([filePath isEqualToString:@"standardUserDefaults"]) {
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
            NSString *str = [dict description];
            data = [str dataUsingEncoding:NSUTF8StringEncoding];

            responseInfo.data = data;
            responseInfo.contentType = @"text/plain;charset=utf-8";
        } else {
            // contents of file
            data = [HSDFilePreviewComponent fetchContentsWithFilePath:filePath contentType:&contentType];

            responseInfo.data = data;
            responseInfo.contentType = contentType;
        }
    }
    if (!responseInfo.data) {
        NSString *prompt = @"文件不存在或不支持预览";
        NSData *data = [prompt dataUsingEncoding:NSUTF8StringEncoding];

        responseInfo.data = data;
        responseInfo.contentType = @"text/plain;charset=utf-8";
    }
    return responseInfo;
}

#pragma mark - Console Log

+ (HSDResponseInfo *)toggleConsoleLogConnection:(NSDictionary *)params {
    HSDResponseInfo *responseInfo;

    NSString *connect = [params objectForKey:@"connect"];
    if (connect.length > 0) {
        HSDConsoleLogComponent *consoleLogComponent = [HSDComponentMiddleware sharedInstance].consoleLogComponent;
        if ([connect isEqualToString:@"1"]) {
            // enable hsd console log
            [consoleLogComponent redirectStandardErrorOutput];
        } else {
            // disable hsd console log
            [consoleLogComponent recoverStandardErrorOutput];
        }
    }

    return responseInfo;
}

/**
 *  redirect STDERR_FILENO
 */
+ (void)consoleLogRedirectStandardErrorOutput:(void(^)(NSString *))readCompletionBlock {
    HSDConsoleLogComponent *consoleLogComponent = [HSDComponentMiddleware sharedInstance].consoleLogComponent;
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
