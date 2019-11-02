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
    if ([firstPath isEqualToString:@"pages"]) {
        // html pages
        if ([secondPath isEqualToString:kHSDComponentFileExplorer]) {
            // file_explorer
            NSString *documentPath = [documentRoot stringByAppendingPathComponent:path];
            if ([thirdPath isEqualToString:[kHSDComponentFileExplorer stringByAppendingString:@".html"]]) {
                // file_explorer.html
                NSString *htmlStr = [NSString stringWithContentsOfFile:documentPath encoding:NSUTF8StringEncoding error:nil];
                htmlStr = [HSDComponentMiddleware localize:languageType text:htmlStr];  // localization
                response = [[HSDGWebServerDataResponse alloc] initWithHTML:htmlStr];
            } else {
                response = [[HSDGWebServerFileResponse alloc] initWithFile:documentPath];
            }
        } else if ([secondPath isEqualToString:kHSDComponentDBInspect]) {
            // database_inspect
            NSString *documentPath = [documentRoot stringByAppendingPathComponent:path];
            if ([thirdPath isEqualToString:[kHSDComponentDBInspect stringByAppendingString:@".html"]]) {
                // database_inspect.html
                NSDictionary *replacementDict = [HSDComponentMiddleware fetchDatabaseAPITemplateHTMLReplacement:query];
                if ([replacementDict count] > 0) {
                    // valid replacement values for html template
                    // replace template string
                    NSString *htmlStr = [[NSString alloc] initWithContentsOfFile:documentPath encoding:NSUTF8StringEncoding error:nil];
                    htmlStr = [HSDComponentMiddleware formatTemplateString:htmlStr variables:replacementDict];

                    // localization
                    htmlStr = [HSDComponentMiddleware localize:languageType text:htmlStr];
                    response = [[HSDGWebServerDataResponse alloc] initWithHTML:htmlStr];
                } else {
                    // show prompt message
                    NSDictionary *localStrings = [HSDComponentMiddleware localizationJSON:languageType];
                    NSString *htmlText = [localStrings objectForKey:@"LocalizedDBInspectDBDisconnectedPromptHtml"];
                    response = [[HSDGWebServerDataResponse alloc] initWithHTML:htmlText];
                }
            } else {
                response = [[HSDGWebServerFileResponse alloc] initWithFile:documentPath];
            }
        } else if ([secondPath isEqualToString:kHSDComponentViewDebug]) {
            // view_debug.html
            NSString *documentPath = [documentRoot stringByAppendingPathComponent:path];
            response = [[HSDGWebServerFileResponse alloc] initWithFile:documentPath];
        } else if ([secondPath isEqualToString:kHSDComponentSendInfo]) {
            // send_info
            NSString *documentPath = [documentRoot stringByAppendingPathComponent:path];
            if ([thirdPath isEqualToString:[kHSDComponentSendInfo stringByAppendingString:@".html"]]) {
                // send_info.html
                NSString *htmlStr = [NSString stringWithContentsOfFile:documentPath encoding:NSUTF8StringEncoding error:nil];
                htmlStr = [HSDComponentMiddleware localize:languageType text:htmlStr];
                response = [[HSDGWebServerDataResponse alloc] initWithHTML:htmlStr];
            } else {
                response = [[HSDGWebServerFileResponse alloc] initWithFile:documentPath];
            }
        } else if ([secondPath isEqualToString:kHSDComponentConsoleLog]) {
            // console_log
            NSString *documentPath = [documentRoot stringByAppendingPathComponent:path];
            if ([thirdPath isEqualToString:[kHSDComponentConsoleLog stringByAppendingString:@".html"]]) {
                // console_log.html
                NSString *htmlStr = [NSString stringWithContentsOfFile:documentPath encoding:NSUTF8StringEncoding error:nil];
                htmlStr = [HSDComponentMiddleware localize:languageType text:htmlStr];
                response = [[HSDGWebServerDataResponse alloc] initWithHTML:htmlStr];
            } else {
                response = [[HSDGWebServerFileResponse alloc] initWithFile:documentPath];
            }
        }
    } else if ([firstPath isEqualToString:@"api"]) {
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
                response = [[HSDGWebServerDataResponse alloc] initWithHTML:htmlStr];
            } else {
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
