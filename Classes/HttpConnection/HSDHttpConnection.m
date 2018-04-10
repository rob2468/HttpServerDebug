//
//  HSDHttpConnection.m
//  HttpServerDebug
//
//  Created by chenjun on 22/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "HSDHttpConnection.h"
#import "HSDDefine.h"
#import "HTTPFileResponse.h"
#import "HSDHttpConnection+Explorer.h"
#import "HSDHttpConnection+Database.h"
#import "HSDHttpConnection+Preview.h"
#import "HSDHttpConnection+View.h"
#import "HSDHttpConnection+Info.h"
#import "HTTPMessage.h"
#import "MultipartFormDataParser.h"
#import "HTTPDynamicFileResponse.h"
#import "HSDManager.h"
#import "HSDUtility.h"

@interface HSDHttpConnection ()

@property (nonatomic, strong) MultipartFormDataParser *parser;

@end

@implementation HSDHttpConnection

#pragma mark -- override methods

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
    BOOL isSupported = [super supportsMethod:method atPath:path];
    if ([method isEqualToString:@"POST"]) {
        if ([path isEqualToString:[NSString stringWithFormat:@"/%@", kHSDHttpServerSendInfo]]) {
            // "/send_info"
            isSupported = YES;
        }
    }
    return isSupported;
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
    BOOL isExpect = [super expectsRequestBodyFromMethod:method atPath:path];
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
    if ([firstPath isEqualToString:[NSString stringWithFormat:@"%@.html", kHSDHttpServerFileExplorer]]) {
        // file_explorer.html
        response = [self fetchFileExplorerResponse:params forMethod:method URI:path];
    } else if ([firstPath isEqualToString:kHSDHttpServerFileExplorer]) {
        // file_explorer api
        response = [self fetchFileExplorerAPIResponsePaths:pathComps parameters:params];
    } else if ([firstPath isEqualToString:[NSString stringWithFormat:@"%@.html", kHSDHttpServerDBInspect]]) {
        // database_inspect.html
        response = [self fetchDatabaseHTMLResponse:params];
    } else if ([firstPath isEqualToString:kHSDHttpServerDBInspect]) {
        // database_inspect api
        response = [self fetchDatabaseAPIResponsePaths:pathComps parameters:params];
    } else if ([firstPath isEqualToString:kHSDHttpServerFilePreview]) {
        // file_preview api
        response = [self fetchFilePreviewResponse:params forMethod:method URI:path];
    } else if ([firstPath isEqualToString:[NSString stringWithFormat:@"%@.html", kHSDHttpServerViewDebug]]) {
        // view_debug.html
        response = [self fetchViewDebugResponseForMethod:method URI:path];
    } else if ([firstPath isEqualToString:kHSDHttpServerViewDebug]) {
        // view_debug api
        response = [self fetchViewDebugAPIResponsePaths:pathComps parameters:params];
    } else if ([firstPath isEqualToString:[NSString stringWithFormat:@"%@.html", kHSDHttpServerSendInfo]]) {
        // send_info.html
        response = [self fetchSendInfoResponseForMethod:method URI:path];
    } else if ([firstPath isEqualToString:kHSDHttpServerSendInfo]) {
        // send_info api
        response = [self fetchSendInfoAPIResponseForMethod:method paths:pathComps parameters:params];
    } else if (firstPath.length == 0 || [firstPath isEqualToString:@"index.html"]) {
        // index.html
        NSString *htmlPath = [[config documentRoot] stringByAppendingPathComponent:@"index.html"];
        NSString *dbPath = [HSDManager fetchDatabaseFilePath];
        dbPath = dbPath.length > 0? dbPath: @"";
        NSDictionary *replacementDict =
        @{@"DB_FILE_PATH": dbPath};
        response = [[HTTPDynamicFileResponse alloc] initWithFilePath:htmlPath forConnection:self separator:kHSDHttpServerTemplateSeparator replacementDictionary:replacementDict];
    } else if ([firstPath isEqualToString:@"resources"]) {
        // set resources Content-Type manually
        NSString *pathExtension = [[pathComps lastObject] pathExtension];
        NSString *contentType = [HSDUtility fetchContentTypeWithFilePathExtension:pathExtension];
        NSString *dataPath = [[config documentRoot] stringByAppendingPathComponent:path];
        NSData *data = [[NSData alloc] initWithContentsOfFile:dataPath];
        response = [[HSDHttpDataResponse alloc] initWithData:data contentType:contentType];
    } else {
        response = [super httpResponseForMethod:method URI:path];
    }
    return response;
}

- (void)prepareForBodyWithSize:(UInt64)contentLength {

}

- (void)processBodyData:(NSData *)postDataChunk {
    // TODO: here, assuming only one data chunk
    [request setBody:postDataChunk];
}

@end

@interface HSDHttpDataResponse ()

@property (nonatomic, copy) NSString *contentType;

@end

@implementation HSDHttpDataResponse

- (instancetype)initWithData:(NSData *)data contentType:(NSString *)type {
    self = [super initWithData:data];
    if (self) {
        self.contentType = type;
    }
    return self;
}

- (NSDictionary *)httpHeaders {
    NSString *type = self.contentType;
    type = type.length > 0 ? type: @"";
    return @{@"Content-Type": type};
}

@end

