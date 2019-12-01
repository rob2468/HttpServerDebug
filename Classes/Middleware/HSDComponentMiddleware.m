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
#import "HSDWebDebugComponent.h"
#import "HSDManager+Project.h"
#import "HSDDefine.h"
#import "HSDResponseInfo.h"

@interface HSDComponentMiddleware ()

@property (nonatomic, strong) HSDConsoleLogComponent *consoleLogComponent;
@property (nonatomic, strong) HSDWebDebugComponent *webDebugComponent;

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

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - File Explorer

/**
 *  request data
 */
+ (HSDResponseInfo *)fetchFileExplorerAPIResponseInfo:(NSDictionary *)params {
    // parse data
    NSString *filePath = [params objectForKey:@"file_path"];
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

+ (HSDResponseInfo *)uploadTemporaryFile:(NSString *)temporaryPath targetDirectory:(NSString *)targetDirectory fileName:(NSString *)targetFileName {
    BOOL isSuccess = YES;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:temporaryPath]
        || ![fileManager fileExistsAtPath:targetDirectory]
        || targetFileName.length == 0) {
        // illegal cases
        isSuccess = NO;
    }

    if (isSuccess) {
        // move
        NSString *targetPath = [targetDirectory stringByAppendingPathComponent:targetFileName];
        isSuccess = [fileManager moveItemAtPath:temporaryPath toPath:targetPath error:nil];
    }

    NSInteger errNum;
    NSArray *filesDataList;
    if (isSuccess) {
        errNum = 0;

        // get the updated directory content
        filesDataList = [HSDFileExplorerComponent constructFilesDataListInDirectory:targetDirectory];
    } else {
        errNum = -1;
        filesDataList = [[NSArray alloc] init];
    }

    NSDictionary *responseDict =
    @{
      @"errno" : @(errNum),
      @"data" : filesDataList
      };

    HSDResponseInfo *responseInfo = [[HSDResponseInfo alloc] init];
    responseInfo.data = [NSJSONSerialization dataWithJSONObject:responseDict options:0 error:nil];
    responseInfo.contentType = @"text/plain;charset=utf-8";
    return responseInfo;
}

#pragma mark - Database Inspect

+ (NSDictionary *)fetchDatabaseAPITemplateHTMLReplacement:(NSDictionary *)params {
    NSDictionary *replacementDict;
    NSString *dbPath = [params objectForKey:@"db_path"];
    if (dbPath.length > 0) {
        dbPath = [dbPath stringByRemovingPercentEncoding];
        NSString *selectHTML = [HSDDBInspectComponent fetchTableNamesHTMLString:dbPath];
        if (selectHTML.length > 0) {
            replacementDict =
            @{@"DB_FILE_PATH" : dbPath,
              @"SELECT_HTML" : selectHTML
              };
        }
    }
    return replacementDict;
}

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
    BOOL success;
    if (result) {
        // success
        success = YES;
    } else {
        // fail
        success = NO;
        result = [[NSDictionary alloc] init];
    }

    // construct response data
    NSDictionary *responseDict =
    @{
      @"success": @(success),
      @"result" : result,
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
            // contents of standardUserDefaults
            data = [HSDFilePreviewComponent fetchContentsOfStandardUserDefaults];

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

#pragma mark - Web Debug

+ (NSDictionary *)fetchWebDebugTemplateHTMLReplacement {
    HSDWebDebugComponent *webDebugComponent = [HSDComponentMiddleware sharedInstance].webDebugComponent;
    NSArray<HSDWebDebugWebViewInfo *> *infoArr = [webDebugComponent allWebViewInfo];

    NSMutableString *htmlStr = [@"" mutableCopy];
    for (HSDWebDebugWebViewInfo *webViewInfo in infoArr) {
        [htmlStr appendString:@"<li class=\"page-item\">"];
        [htmlStr appendString:@"<div class=\"page-info\">"];
        [htmlStr appendFormat:@"<div class=\"page-title\">%@</div>", webViewInfo.title];
        [htmlStr appendFormat:@"<div class=\"page-url\">%@</div>", webViewInfo.url];
        [htmlStr appendString:@"</div>"];
        [htmlStr appendFormat:@"<a class=\"debug\" href=\"http://127.0.0.1:5555/chrome-devtools-frontend/front_end/inspector.html?ws=127.0.0.1:5555/web_debug/devtools/page/1\" target=\"_blank\">调试</a>"];
        [htmlStr appendString:@"</li>"];
    }
    return @{ @"PageList": htmlStr };
}

#pragma mark - localization

+ (NSString *)localize:(NSString *)local text:(NSString *)text {
    // get localization json data
    NSDictionary *localized = [HSDComponentMiddleware localizationJSON:local];

    do {
        // detect with regular expression
        NSString *pattern = [NSString stringWithFormat:@"%@.+?%@", kHSDMarkLocalizationString, kHSDMarkLocalizationString];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        NSRange range = [regex rangeOfFirstMatchInString:text options:0 range:NSMakeRange(0, [text length])];

        if (range.location == NSNotFound) {
            break;
        } else {
            // found
            NSString *prefixStr = [text substringToIndex:range.location];
            NSString *suffix = [text substringFromIndex:range.location + range.length];

            range.location += [kHSDMarkLocalizationString length];
            range.length -= [kHSDMarkLocalizationString length] * 2;
            NSString *localizedStrKey = [text substringWithRange:range];
            NSString *localizedStr = [localized objectForKey:localizedStrKey];

            text = [NSString stringWithFormat:@"%@%@%@", prefixStr, localizedStr, suffix];
        }
    } while (1);
    return text;
}

+ (NSDictionary *)localizationJSON:(NSString *)local {
    NSString *pathComponent = [NSString stringWithFormat:@"%@.json", local];
    NSString *localizedFilePath = [[HSDManager fetchDocumentRoot] stringByAppendingPathComponent:pathComponent];
    NSData *data = [NSData dataWithContentsOfFile:localizedFilePath];
    NSDictionary *localized = @{};
    if (data) {
        localized = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    return localized;
}

#pragma mark = Utility

+ (NSString *)formatTemplateString:(NSString *)str variables:(NSDictionary *)variables {
    NSMutableString *mStr = [str mutableCopy];
    [variables enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        NSString *template = [NSString stringWithFormat:@"%@%@%@", kHSDMarkFormatString, key, kHSDMarkFormatString];
        [mStr replaceOccurrencesOfString:template withString:value options:0 range:NSMakeRange(0, mStr.length)];
    }];
    return mStr;
}

#pragma mark - Getter

- (HSDConsoleLogComponent *)consoleLogComponent {
    if (!_consoleLogComponent) {
        _consoleLogComponent = [[HSDConsoleLogComponent alloc] init];
    }
    return _consoleLogComponent;
}

- (HSDWebDebugComponent *)webDebugComponent {
    if (!_webDebugComponent) {
        _webDebugComponent = [[HSDWebDebugComponent alloc] init];
    }
    return _webDebugComponent;
}

@end
