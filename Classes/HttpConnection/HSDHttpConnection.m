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
#import "HTTPMessage.h"
#import "MultipartFormDataParser.h"
#import "HTTPDynamicFileResponse.h"
#import "HSDManager+Private.h"
#import "HSDWebSocket.h"
#import "HSDComponentMiddleware.h"
#import "HSDDBInspectComponent.h"
#import "HSDFileExplorerComponent.h"
#import "HSDSendInfoComponent.h"
#import "HSDFilePreviewComponent.h"

@interface HSDHttpConnection ()

@property (nonatomic, strong) MultipartFormDataParser *parser;

@end

@implementation HSDHttpConnection

#pragma mark -- override methods

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
    BOOL isSupported = [super supportsMethod:method atPath:path];
    if ([method isEqualToString:@"POST"]) {
        if ([path isEqualToString:[NSString stringWithFormat:@"/api/%@", kHSDComponentSendInfo]]) {
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
    // request host
    NSString *requestHost = [request headerField:@"Host"];

    NSString *firstPath;
    if ([pathComps count] > 0) {
        firstPath = [pathComps firstObject];
    }
    NSString *secondPath;
    if ([pathComps count] > 1) {
        secondPath = [pathComps objectAtIndex:1];
    }
    if ([firstPath isEqualToString:@"pages"]) {
        // html pages
        if ([secondPath isEqualToString:kHSDComponentFileExplorer]) {
            // file_explorer.html
            response = [super httpResponseForMethod:method URI:path];
        } else if ([secondPath isEqualToString:kHSDComponentDBInspect]) {
            // database_inspect.html
            response = [HSDComponentMiddleware fetchDatabaseHTMLResponse:params withConnection:self];
        } else if ([secondPath isEqualToString:kHSDComponentViewDebug]) {
            // view_debug.html
            response = [super httpResponseForMethod:method URI:path];
        } else if ([secondPath isEqualToString:kHSDComponentSendInfo]) {
            // send_info.html
            response = [super httpResponseForMethod:method URI:path];
        } else if ([secondPath isEqualToString:kHSDComponentConsoleLog]) {
            // console_log.html
            NSString *htmlPath = [[config documentRoot] stringByAppendingPathComponent:@"pages/console_log/console_log.html"];
            // construct WebSocket url
            NSString *webSocketURL = @"";
            if (requestHost.length > 0) {
                webSocketURL = [NSString stringWithFormat:@"ws://%@", requestHost];
            }
            NSDictionary *replacementDict =
            @{@"WEBSOCKET_URL": webSocketURL};
            response = [[HTTPDynamicFileResponse alloc] initWithFilePath:htmlPath forConnection:self separator:kHSDTemplateSeparator replacementDictionary:replacementDict];
        }
    } else if ([firstPath isEqualToString:@"api"]) {
        // api requests
        if ([secondPath isEqualToString:kHSDComponentFileExplorer]) {
            // file_explorer api
            response = [HSDComponentMiddleware fetchFileExplorerAPIResponsePaths:pathComps parameters:params];
        } else if ([secondPath isEqualToString:kHSDComponentDBInspect]) {
            // database_inspect api
            NSArray *modules = [pathComps subarrayWithRange:NSMakeRange(2, [pathComps count] - 2)];
            response = [HSDComponentMiddleware fetchDatabaseAPIResponseModules:modules parameters:params];
        } else if ([secondPath isEqualToString:kHSDComponentFilePreview]) {
            // file_preview api
            response = [HSDComponentMiddleware fetchFilePreviewResponse:params forMethod:method URI:path];
        } else if ([secondPath isEqualToString:kHSDComponentViewDebug]) {
            // view_debug api
            NSArray *modules = [pathComps subarrayWithRange:NSMakeRange(2, [pathComps count] - 2)];
            response = [HSDComponentMiddleware fetchViewDebugAPIResponseModules:modules parameters:params];
        } else if ([secondPath isEqualToString:kHSDComponentSendInfo]) {
            // send_info api
            response = [HSDComponentMiddleware fetchSendInfoAPIResponseForMethod:method paths:pathComps parameters:params withRequest:request];
        }
    } else if ([firstPath isEqualToString:@"favicon.ico"]) {
        // favicon
        NSString *relativePath = [NSString stringWithFormat:@"resources/favicon.ico"];
        NSString *dataPath = [[config documentRoot] stringByAppendingPathComponent:relativePath];
        response = [[HTTPFileResponse alloc] initWithFilePath:dataPath forConnection:self];
    } else if ([firstPath isEqualToString:@"resources"]) {
        // set resources Content-Type manually
        NSString *pathExtension = [[pathComps lastObject] pathExtension];
        NSString *contentType = [HSDManager fetchContentTypeWithFilePathExtension:pathExtension];
        NSString *dataPath = [[config documentRoot] stringByAppendingPathComponent:path];
        NSData *data = [[NSData alloc] initWithContentsOfFile:dataPath];
        response = [[HSDHttpDataResponse alloc] initWithData:data contentType:contentType];
    } else if (firstPath.length == 0) {
        // index.html
        NSString *htmlPath = [[config documentRoot] stringByAppendingPathComponent:@"pages/index/index.html"];
        NSString *dbPath = [HSDManager fetchDefaultInspectDBFilePath];
        dbPath = dbPath.length > 0? dbPath: @"";
        NSDictionary *replacementDict =
        @{@"DB_FILE_PATH": dbPath};
        response = [[HTTPDynamicFileResponse alloc] initWithFilePath:htmlPath forConnection:self separator:kHSDTemplateSeparator replacementDictionary:replacementDict];
    } else {
        response = [super httpResponseForMethod:method URI:path];
    }
    return response;
}

- (WebSocket *)webSocketForURI:(NSString *)path {
    HSDWebSocket *webSocket = [[HSDWebSocket alloc] initWithRequest:request socket:asyncSocket];
    return webSocket;
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

