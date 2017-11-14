//
//  BDHttpServerConnection.m
//  BaiduBrowser
//
//  Created by chenjun on 22/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "BDHttpServerConnection.h"
#import "BDHttpServerDefine.h"
#import "HTTPFileResponse.h"
#import "BDHttpServerConnection+Explorer.h"
#import "BDHttpServerConnection+Database.h"
#import "BDHttpServerConnection+Upload.h"
#import "BDHttpServerConnection+Preview.h"
#import "BDHttpServerConnection+View.h"
#import "HTTPMessage.h"
#import "MultipartFormDataParser.h"
#import "HTTPDynamicFileResponse.h"
#import "BDHttpServerManager.h"
#import "BDHttpServerUtility.h"

@interface BDHttpServerConnection ()

@property (nonatomic, strong) MultipartFormDataParser *parser;

@end

@implementation BDHttpServerConnection

#pragma mark -- override methods

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    BOOL isSupported = [super supportsMethod:method atPath:path];
    if ([method isEqualToString:@"POST"]) {
        if ([path isEqualToString:[NSString stringWithFormat:@"/%@.html", kBDHttpServerWebUpload]]) {
            isSupported = YES;
        }
    }
    return isSupported;
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
    BOOL isExpect = [super expectsRequestBodyFromMethod:method atPath:path];
    if([method isEqualToString:@"POST"] && [path isEqualToString:[NSString stringWithFormat:@"/%@.html", kBDHttpServerWebUpload]]) {
        BOOL isExpectTmp = YES;
        // 确保头中存在boundary字段
        NSString *contentType = [request headerField:@"Content-Type"];
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if (NSNotFound == paramsSeparator) {
            isExpectTmp = NO;
        } else if (paramsSeparator >= contentType.length - 1) {
            isExpectTmp = NO;
        } else {
            NSString *type = [contentType substringToIndex:paramsSeparator];
            if (![type isEqualToString:@"multipart/form-data"]) {
                // content type应该为multipart/form-data
                isExpectTmp = NO;
            }
        }
        if (isExpectTmp) {
            // 遍历content-type，寻找boundary字段
            NSArray *params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
            for (NSString *param in params) {
                paramsSeparator = [param rangeOfString:@"="].location;
                if ((NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1) {
                    continue;
                }
                NSString *paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator - 1)];
                NSString *paramValue = [param substringFromIndex:paramsSeparator + 1];
                
                if ([paramName isEqualToString:@"boundary"]) {
                    // 将boundary字段直接设置到头中，以方便处理
                    [request setHeaderField:@"boundary" value:paramValue];
                }
            }
            if (![request headerField:@"boundary"])  {
                isExpectTmp = NO;
            } else {
                isExpectTmp = YES;
            }
            isExpect = isExpectTmp;
        }
    }
    return isExpect;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    id response;
    NSArray *comps = [path componentsSeparatedByString:@"?"];
    NSString *p = [comps firstObject];
    // parse paths
    NSArray<NSString *> *pathComps = [p componentsSeparatedByString:@"/"];
    if ([pathComps count] > 0) {
        NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:pathComps];
        [tmp removeObject:@""];
        pathComps = tmp;
    }
    NSString *firstPath;
    if ([pathComps count] > 0) {
        firstPath = [pathComps firstObject];
    }
    // parse parameters
    NSMutableDictionary *params;
    if ([comps count] > 1) {
        params = [[NSMutableDictionary alloc] init];
        NSString *paramsStr = [comps objectAtIndex:1];
        NSArray *comps = [paramsStr componentsSeparatedByString:@"&"];
        for (NSString *item in comps) {
            NSString *tmp = [item stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSArray *keyAndValue = [tmp componentsSeparatedByString:@"="];
            if ([keyAndValue count] == 2) {
                NSString *key = keyAndValue.firstObject;
                NSString *value = keyAndValue.lastObject;
                [params setObject:value forKey:key];
            }
        }
    }
    if ([firstPath isEqualToString:[NSString stringWithFormat:@"%@.html", kBDHttpServerFileExplorer]]) {
        // file_explorer.html
        response = [self fetchFileExplorerResponse:params forMethod:method URI:path];
    } else if ([firstPath isEqualToString:[NSString stringWithFormat:@"%@.html", kBDHttpServerDBInspect]]) {
        // database_inspect.html
        response = [self fetchDatabaseHTMLResponse:params];
    } else if ([firstPath isEqualToString:kBDHttpServerDBInspect]) {
        // database_inspect api
        response = [self fetchDatabaseAPIResponse:params];
    } else if ([firstPath isEqualToString:[NSString stringWithFormat:@"%@.html", kBDHttpServerWebUpload]]) {
        response = [self fetchWebUploadResponse:params forMethod:method URI:path];
    } else if ([firstPath isEqualToString:kBDHttpServerFilePreview]) {
        // file_preview
        response = [self fetchFilePreviewResponse:params forMethod:method URI:path];
    } else if ([firstPath isEqualToString:[NSString stringWithFormat:@"%@.html", kBDHttpServerViewDebug]]) {
        // view_debug.html
        response = [self fetchViewDebugResponseForMethod:method URI:path];
    } else if ([firstPath isEqualToString:kBDHttpServerViewDebug]) {
        // view_debug api
        response = [self fetchViewDebugAPIResponsePath:pathComps parameters:params];
    } else if (firstPath.length == 0 || [firstPath isEqualToString:@"index.html"]) {
        // index.html
        NSString *htmlPath = [[config documentRoot] stringByAppendingPathComponent:@"index.html"];
        NSString *dbPath = [BDHttpServerManager fetchDatabaseFilePath];
        dbPath = dbPath.length > 0? dbPath: @"";
        NSDictionary *replacementDict =
        @{@"DB_FILE_PATH": dbPath};
        response = [[HTTPDynamicFileResponse alloc] initWithFilePath:htmlPath forConnection:self separator:kBDHttpServerTemplateSeparator replacementDictionary:replacementDict];
    } else if ([firstPath isEqualToString:@"resources"]) {
        // set resources Content-Type manually
        NSString *pathExtension = [[pathComps lastObject] pathExtension];
        NSString *contentType = [BDHttpServerUtility fetchContentTypeWithFilePathExtension:pathExtension];
        NSString *dataPath = [[config documentRoot] stringByAppendingPathComponent:path];
        NSData *data = [[NSData alloc] initWithContentsOfFile:dataPath];
        response = [[BDHttpServerDataResponse alloc] initWithData:data contentType:contentType];
    } else {
        response = [super httpResponseForMethod:method URI:path];
    }
    return response;
}

- (void)prepareForBodyWithSize:(UInt64)contentLength {
    NSString *boundary = [request headerField:@"boundary"];
    self.parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    self.parser.delegate = self;
}

- (void)processBodyData:(NSData *)postDataChunk {
    [self.parser appendData:postDataChunk];
}

#pragma mark --

@end

@interface BDHttpServerDataResponse ()

@property (nonatomic, copy) NSString *contentType;

@end

@implementation BDHttpServerDataResponse

- (instancetype)initWithData:(NSData *)data contentType:(NSString *)type {
    self = [super initWithData:data];
    if (self) {
        self.contentType = type;
    }
    return self;
}

- (NSDictionary *)httpHeaders {
    NSString *type = self.contentType;
    type = type.length > 0? type: @"";
    return @{@"Content-Type": type};
}

@end

