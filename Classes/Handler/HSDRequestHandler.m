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
#import "HSDGWebServerRequest.h"
#import "HSDGWebServerDataRequest.h"
#import "HSDGWebServerMultiPartFormRequest.h"
#import "HSDGWebServerResponse.h"
#import "HSDGWebServerFileResponse.h"
#import "HSDGWebServerDataResponse.h"
#import "HSDGWebServerHTTPStatusCodes.h"
#import "HSDUtility.h"

@implementation HSDRequestHandler

+ (HSDGWebServerResponse *)handleRequest:(HSDGWebServerRequest *)request {
    HSDGWebServerResponse *response;
    NSString *documentRoot = [HSDManager fetchDocumentRoot];

    NSString *path = request.path;
    NSDictionary *query = request.query;
    NSString *cookie = [request.headers objectForKey:@"Cookie"];
    NSString *languageType = [HSDRequestHandler getCookie:cookie forName:@"languageType"];
    if (languageType.length == 0) {
        // default value
        languageType = @"zhcn";
    }

    // parse paths
    NSArray<NSString *> *pathComps = [HSDUtility parsePathComponents:path];
    NSString *firstPath;
    NSString *secondPath;
    NSString *thirdPath;
    if ([pathComps count] > 0) {
        firstPath = [pathComps objectAtIndex:0];
    }
    if ([pathComps count] > 1) {
        secondPath = [pathComps objectAtIndex:1];
    }
    if ([pathComps count] > 2) {
        thirdPath = [pathComps objectAtIndex:2];
    }

    // route
    if ([firstPath isEqualToString:@"api"]) {
        // api requests
        if ([secondPath isEqualToString:kHSDComponentFileExplorer]) {
            // file_explorer api
            if ([request isKindOfClass:[HSDGWebServerMultiPartFormRequest class]]) {
                // upload file
                HSDGWebServerMultiPartFormRequest *uploadRequest = (HSDGWebServerMultiPartFormRequest *)request;
                HSDGWebServerMultiPartFile *file = [uploadRequest firstFileForControlName:@"selectedfile"];
                NSString *temporaryPath = [file.temporaryPath copy];    // uploaded temporary file path

                // target directory and file name
                NSString *targetDirectory = [[[uploadRequest firstArgumentForControlName:@"path"] string] copy];
                NSString *targetFileName = [file.fileName copy];

                HSDResponseInfo *responseInfo = [HSDComponentMiddleware uploadTemporaryFile:temporaryPath targetDirectory:targetDirectory fileName:targetFileName];
                response = [[HSDGWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
            } else {
                // general request
                HSDResponseInfo *responseInfo = [HSDComponentMiddleware fetchFileExplorerAPIResponseInfo:query];
                response = [[HSDGWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
            }
        } else if ([secondPath isEqualToString:kHSDComponentFilePreview]) {
            // file_preview api
            HSDResponseInfo *responseInfo = [HSDComponentMiddleware fetchFilePreviewResponseInfo:query];
            response = [[HSDGWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
        } else if ([secondPath isEqualToString:kHSDComponentDBInspect]) {
            // database_inspect api
            HSDResponseInfo *responseInfo = [HSDComponentMiddleware fetchDatabaseAPIResponseInfo:query];
            response = [[HSDGWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
        } else if ([secondPath isEqualToString:kHSDComponentViewDebug]) {
            // view_debug api
            HSDResponseInfo *responseInfo = [HSDComponentMiddleware fetchViewDebugAPIResponseInfo:query];
            response = [[HSDGWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
        } else if ([secondPath isEqualToString:kHSDComponentSendInfo]) {
            // send_info api
            if ([request isKindOfClass:[HSDGWebServerDataRequest class]]) {
                // information sent with POST method
                HSDGWebServerDataRequest *dataRequest = (HSDGWebServerDataRequest*)request;
                NSData *data = dataRequest.data;
                if (data.length >= 0) {
                    NSString *infoStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    HSDResponseInfo *responseInfo = [HSDComponentMiddleware fetchSendInfoAPIResponseInfo:infoStr];
                    response = [[HSDGWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
                }
            } else {
                // information sent with GET method
                NSString *infoStr = [query objectForKey:@"info"];
                infoStr = [infoStr stringByRemovingPercentEncoding];
                HSDResponseInfo *responseInfo = [HSDComponentMiddleware fetchSendInfoAPIResponseInfo:infoStr];
                response = [[HSDGWebServerDataResponse alloc] initWithData:responseInfo.data contentType:responseInfo.contentType];
            }
        } else if ([secondPath isEqualToString:kHSDComponentConsoleLog]) {
            // console_log api
        } else if ([secondPath isEqualToString:@"localization"]) {
            // localization api
            NSDictionary *json = [HSDComponentMiddleware localizationJSON:languageType];
            json = json ? json : @{};
            NSDictionary *dict =
              @{ @"success": @YES,
                 @"result": json,
                 };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            response = [[HSDGWebServerDataResponse alloc] initWithData:data contentType:@"text/plain;charset=utf-8"];
        }
    } else if (firstPath.length == 0) {
        // index.html
        // read html file
        NSString *documentPath = [documentRoot stringByAppendingPathComponent:@"index.html"];
        NSString *htmlStr = [NSString stringWithContentsOfFile:documentPath encoding:NSUTF8StringEncoding error:nil];

        // replace localized string
        htmlStr = [HSDComponentMiddleware localize:languageType text:htmlStr];
        response = [[HSDGWebServerDataResponse alloc] initWithHTML:htmlStr];
    } else {
        NSString *documentPath = [documentRoot stringByAppendingPathComponent:path];
        if ([[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
            // file exist
            if ([[documentPath pathExtension] isEqualToString:@"html"]) {
                // html template
                NSString *htmlStr = [NSString stringWithContentsOfFile:documentPath encoding:NSUTF8StringEncoding error:nil];
                htmlStr = [HSDComponentMiddleware localize:languageType text:htmlStr];  // localization

                NSDictionary *replacementDict;
                if ([path isEqualToString:@"/database_inspect.html"]) {
                    // database_inspect.html
                    replacementDict = [HSDComponentMiddleware fetchDatabaseAPITemplateHTMLReplacement:query];
                    if ([replacementDict count] == 0) {
                        // show prompt message
                        NSDictionary *localStrings = [HSDComponentMiddleware localizationJSON:languageType];
                        htmlStr = [localStrings objectForKey:@"LocalizedDBInspectDBDisconnectedPromptHtml"];
                    }
                } else if ([path isEqualToString:@"/web_debug.html"]) {
                    // web_debug.html
                    replacementDict = [HSDComponentMiddleware fetchWebDebugTemplateHTMLReplacement];
                }

                if ([replacementDict count] > 0) {
                    // valid replacement values for html template
                    // replace template string
                    htmlStr = [HSDComponentMiddleware formatTemplateString:htmlStr variables:replacementDict];
                }

                response = [[HSDGWebServerDataResponse alloc] initWithHTML:htmlStr];
            } else {
                // files which is not html type
                response = [[HSDGWebServerFileResponse alloc] initWithFile:documentPath];
            }
        }
    }

    if (!response) {
        response = [[HSDGWebServerResponse alloc] initWithStatusCode:kGCDWebServerHTTPStatusCode_BadRequest];
    }
    return response;
}

/**
 * get cookie
 * @param cname key
 */
+ (NSString *)getCookie:(NSString *)cookie forName:(NSString *)cname {
    NSString *retVal;
    NSString *name = [cname stringByAppendingString:@"="];
    NSArray *ca = [cookie componentsSeparatedByString:@";"];
    for (NSInteger i = 0; i < [ca count]; i++) {
        NSString *c = [ca objectAtIndex:i];
        while ([[c substringToIndex:1] isEqualToString:@" "]) {
            c = [c substringFromIndex:1];
        }
        if ([c hasPrefix:name]) {
            retVal = [c substringFromIndex:[name length]];
            break;
        }
    }
    return retVal;
}

@end
