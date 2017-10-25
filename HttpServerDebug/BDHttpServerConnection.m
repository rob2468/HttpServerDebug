//
//  BDHttpServerConnection.m
//  BaiduBrowser
//
//  Created by chenjun on 22/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "BDHttpServerConnection.h"
#import "BDHttpServerDefine.h"
#import "HTTPDataResponse.h"
#import "HTTPFileResponse.h"
#import "BDHttpServerConnection+Explorer.h"
#import "BDHttpServerConnection+Database.h"
#import "BDHttpServerConnection+Upload.h"
#import "BDHttpServerConnection+Preview.h"
#import "HTTPMessage.h"
#import "MultipartFormDataParser.h"
#import "HTTPDynamicFileResponse.h"
#import "BDHttpServerManager.h"

@interface BDHttpServerConnection ()

@property (nonatomic, strong) MultipartFormDataParser *parser;

@end

@implementation BDHttpServerConnection

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

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
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

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    id response;
    // 解析请求参数
    NSArray *comps = [path componentsSeparatedByString:@"?"];
    NSString *p = [comps firstObject];
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
    if ([p isEqualToString:[NSString stringWithFormat:@"/%@.html", kBDHttpServerFileExplorer]]) {
        response = [self fetchFileExplorerResponse:params forMethod:method URI:path];
    } else if ([p isEqualToString:[NSString stringWithFormat:@"/%@.html", kBDHttpServerDBInspect]]) {
        response = [self fetchDatabaseResponse:params];
    } else if ([p isEqualToString:[NSString stringWithFormat:@"/%@.html", kBDHttpServerWebUpload]]) {
        response = [self fetchWebUploadResponse:params forMethod:method URI:path];
    } else if ([p isEqualToString:[NSString stringWithFormat:@"/%@.html", kBDHttpServerFilePreview]]) {
        response = [self fetchFilePreviewResponse:params forMethod:method URI:path];
    } else { // index.html
        NSString *htmlPath = [[config documentRoot] stringByAppendingPathComponent:@"index.html"];
        NSDictionary *replacementDict =
        @{@"DB_FILE_PATH": [BDHttpServerManager fetchDatabaseFilePath]};
        response = [[HTTPDynamicFileResponse alloc] initWithFilePath:htmlPath forConnection:self separator:kBDHttpServerTemplateSeparator replacementDictionary:replacementDict];
    }
    return response;
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
    NSString *boundary = [request headerField:@"boundary"];
    self.parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    self.parser.delegate = self;
}

- (void)processBodyData:(NSData *)postDataChunk
{
    [self.parser appendData:postDataChunk];
}

@end
