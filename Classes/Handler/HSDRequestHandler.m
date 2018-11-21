//
//  HSDRequestHandler.m
//  HttpServerDebug
//
//  Created by 陈军 on 2018/11/5.
//  Copyright © 2018 chenjun. All rights reserved.
//

#import "HSDRequestHandler.h"
#import "HSDManager+Project.h"
#import "HSDDefine.h"
#import "HSDComponentMiddleware.h"
#import "HSDResponseInfo.h"
#import "HSDDBInspectComponent.h"
#import "GCDWebServerRequest.h"
#import "GCDWebServerDataRequest.h"
#import "GCDWebServerMultiPartFormRequest.h"
#import "GCDWebServerResponse.h"
#import "GCDWebServerFileResponse.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebServerHTTPStatusCodes.h"

@implementation HSDRequestHandler

+ (GCDWebServerResponse *)handleRequest:(GCDWebServerRequest *)request {
    GCDWebServerResponse *response;
    NSString *documentRoot = [HSDManager fetchDocumentRoot];

    NSString *path = request.path;
    NSDictionary *query = request.query;

    // parse paths
    NSString *p = [path copy];
    if ([p hasPrefix:@"/"]) {
        p = [p substringFromIndex:1];
    }
    if ([p hasSuffix:@"/"]) {
        p = [p substringToIndex:p.length - 1];
    }

    // path components
    NSArray<NSString *> *pathComps = [[NSArray alloc] init];
    if (p.length > 0) {
        pathComps = [p componentsSeparatedByString:@"/"];
    }
    NSString *firstPath;
    NSString *secondPath;
    if ([pathComps count] > 0) {
        firstPath = [pathComps objectAtIndex:0];
    }
    if ([pathComps count] > 1) {
        secondPath = [pathComps objectAtIndex:1];
    }

    // route
    if ([firstPath isEqualToString:@"pages"]) {
        // html pages
        if ([secondPath isEqualToString:kHSDComponentFileExplorer]) {
            // file_explorer.html
            NSString *documentPath = [documentRoot stringByAppendingPathComponent:path];
            response = [[GCDWebServerFileResponse alloc] initWithFile:documentPath];
        } else if ([secondPath isEqualToString:kHSDComponentDBInspect]) {
            // database file path
            NSDictionary *replacementDict = [HSDComponentMiddleware fetchDatabaseAPITemplateHTMLReplacement:query];
            if ([replacementDict count] > 0) {
                // valid replacement values for html template
                NSString *htmlPath = [documentRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"/pages/%@/%@.html", kHSDComponentDBInspect, kHSDComponentDBInspect]];
                response = [[GCDWebServerDataResponse alloc] initWithHTMLTemplate:htmlPath variables:replacementDict];
            } else {
                // show prompt message
                NSString *htmlText = @"<p>没有连接到可用的数据库，可通过如下方法解决。</p><p>方法一：在<a href='/pages/file_explorer/file_explorer.html'>文件浏览</a>中找到目标数据库文件，打开。</p><p>方法二：使用+[HSDManager updateDefaultInspectDBFilePath:]方法设置默认数据库文件路径，然后在首页可直接点击打开。</p>";
                response = [[GCDWebServerDataResponse alloc] initWithHTML:htmlText];
            }
        } else if ([secondPath isEqualToString:kHSDComponentViewDebug]) {
            // view_debug.html
            NSString *documentPath = [documentRoot stringByAppendingPathComponent:path];
            response = [[GCDWebServerFileResponse alloc] initWithFile:documentPath];
        } else if ([secondPath isEqualToString:kHSDComponentSendInfo]) {
            // send_info.html
            NSString *documentPath = [documentRoot stringByAppendingPathComponent:path];
            response = [[GCDWebServerFileResponse alloc] initWithFile:documentPath];
        } else if ([secondPath isEqualToString:kHSDComponentConsoleLog]) {
            // console_log.html
            NSString *documentPath = [documentRoot stringByAppendingPathComponent:path];
            response = [[GCDWebServerFileResponse alloc] initWithFile:documentPath];
        }
    } else if ([firstPath isEqualToString:@"api"]) {
        // api requests
        if ([secondPath isEqualToString:kHSDComponentFileExplorer]) {
            // file_explorer api
            if ([request isKindOfClass:[GCDWebServerMultiPartFormRequest class]]) {
                // upload file
                GCDWebServerMultiPartFormRequest *uploadRequest = (GCDWebServerMultiPartFormRequest *)request;
                GCDWebServerMultiPartFile *file = [uploadRequest firstFileForControlName:@"selectedfile"];
                NSString *temporaryPath = [file.temporaryPath copy];    // uploaded temporary file path

                // target directory and file name
                NSString *targetDirectory = [[[uploadRequest firstArgumentForControlName:@"path"] string] copy];
                NSString *targetFileName = [file.fileName copy];

                HSDResponseInfo *responseInfo = [HSDComponentMiddleware uploadTemporaryFile:temporaryPath targetDirectory:targetDirectory fileName:targetFileName];
                response = [[GCDWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
            } else {
                // general request
                HSDResponseInfo *responseInfo = [HSDComponentMiddleware fetchFileExplorerAPIResponseInfo:query];
                response = [[GCDWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
            }
        } else if ([secondPath isEqualToString:kHSDComponentFilePreview]) {
            // file_preview api
            HSDResponseInfo *responseInfo = [HSDComponentMiddleware fetchFilePreviewResponseInfo:query];
            response = [[GCDWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
        } else if ([secondPath isEqualToString:kHSDComponentDBInspect]) {
            // database_inspect api
            HSDResponseInfo *responseInfo = [HSDComponentMiddleware fetchDatabaseAPIResponseInfo:query];
            response = [[GCDWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
        } else if ([secondPath isEqualToString:kHSDComponentViewDebug]) {
            // view_debug api
            HSDResponseInfo *responseInfo = [HSDComponentMiddleware fetchViewDebugAPIResponseInfo:query];
            response = [[GCDWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
        } else if ([secondPath isEqualToString:kHSDComponentSendInfo]) {
            // send_info api
            if ([request isKindOfClass:[GCDWebServerDataRequest class]]) {
                // information sent with POST method
                GCDWebServerDataRequest *dataRequest = (GCDWebServerDataRequest*)request;
                NSData *data = dataRequest.data;
                if (data.length >= 0) {
                    NSString *infoStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    HSDResponseInfo *responseInfo = [HSDComponentMiddleware fetchSendInfoAPIResponseInfo:infoStr];
                    response = [[GCDWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
                }
            } else {
                // information sent with GET method
                NSString *infoStr = [query objectForKey:@"info"];
                infoStr = [infoStr stringByRemovingPercentEncoding];
                HSDResponseInfo *responseInfo = [HSDComponentMiddleware fetchSendInfoAPIResponseInfo:infoStr];
                response = [[GCDWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
            }
        } else if ([secondPath isEqualToString:kHSDComponentConsoleLog]) {
            // console_log api
            HSDResponseInfo *responseInfo = [HSDComponentMiddleware fetchConsoleLogResponseInfo:query];
            response = [[GCDWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
        }
    } else if ([firstPath isEqualToString:@"favicon.ico"]) {
        // favicon
        NSString *relativePath = [NSString stringWithFormat:@"resources/favicon.ico"];
        NSString *documentPath = [documentRoot stringByAppendingPathComponent:relativePath];
        response = [[GCDWebServerFileResponse alloc] initWithFile:documentPath];
    } else if ([firstPath isEqualToString:@"resources"]) {
        // set resources Content-Type manually
        NSString *documentPath = [documentRoot stringByAppendingPathComponent:path];
        response = [[GCDWebServerFileResponse alloc] initWithFile:documentPath];
    } else if (firstPath.length == 0) {
        // index.html
        NSString *documentPath = [documentRoot stringByAppendingPathComponent:@"pages/index/index.html"];
        NSString *dbPath = [HSDManager fetchDefaultInspectDBFilePath];
        dbPath = dbPath.length > 0 ? dbPath : @"";
        NSDictionary *replacementDict = @{@"DB_FILE_PATH" : dbPath};
        response = [[GCDWebServerDataResponse alloc] initWithHTMLTemplate:documentPath variables:replacementDict];
    } else {
        NSString *documentPath = [documentRoot stringByAppendingPathComponent:path];
        response = [[GCDWebServerFileResponse alloc] initWithFile:documentPath];
    }

    if (!response) {
        response = [[GCDWebServerResponse alloc] initWithStatusCode:kGCDWebServerHTTPStatusCode_BadRequest];
    }
    return response;
}

@end
