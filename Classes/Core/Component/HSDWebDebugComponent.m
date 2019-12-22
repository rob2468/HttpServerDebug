//
//  HSDWebDebugComponent.m
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/12/1.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import "HSDWebDebugComponent.h"
#import "HSDViewDebugComponent.h"
#import <WebKit/WebKit.h>
#import "HSDDefine.h"

@interface HSDWebDebugComponent()

@property (nonatomic, strong) NSMutableDictionary *allWebViews;
@property (nonatomic, copy) NSString *jsString;

@end

@implementation HSDWebDebugComponent

- (instancetype)init {
    self = [super init];
    if (self) {
        // get the injection js script string
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"HttpServerDebug" ofType:@"bundle"];
        NSString *inspectFile = [resourcePath stringByAppendingPathComponent:@"HSDWebDebugInspector.js"];
        self.jsString = [[NSString alloc] initWithContentsOfFile:inspectFile encoding:NSUTF8StringEncoding error:nil];
    }
    return self;
}

- (NSArray<HSDWebDebugWebViewInfo *> *)allWebViewInfo {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    self.allWebViews = [[NSMutableDictionary alloc] init];
    NSMutableArray<NSString *> *webViewAddrs = [[NSMutableArray alloc] init]; // webView memory addresses, used to sort the titles array

    dispatch_sync(dispatch_get_main_queue(), ^{
        // get all webviews
        NSArray *windows = [HSDViewDebugComponent fetchAllWindows];
        for (UIWindow *window in windows) {
            [self recursiveSubviewsInView:window];
        }

        NSInteger count = [self.allWebViews count];
        if (count > 0) {
            __block NSInteger currentCount = 0;
            for (NSNumber *key in [self.allWebViews allKeys]) {
                HSDWebDebugWebViewInfo *webViewInfo = [self.allWebViews objectForKey:key];
                WKWebView *webView = webViewInfo.webView;
                NSString *memAddr = [NSString stringWithFormat:@"%p", webView];

                // get webview title
                [webView evaluateJavaScript:@"getWebViewInfo();" completionHandler:^(NSDictionary *infoDict, NSError * _Nullable error) {
                    webViewInfo.title = [infoDict objectForKey:@"title"];
                    webViewInfo.url = [infoDict objectForKey:@"url"];

                    currentCount++;
                    if (currentCount >= count) {
                        // all titles have gotten
                        dispatch_semaphore_signal(semaphore);
                    }
                }];

                // memory address
                [webViewAddrs addObject:memAddr];
            }
        } else {
            dispatch_semaphore_signal(semaphore);
        }

    });

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    // sort
    NSMutableArray<NSNumber *> *pageIds = [[self.allWebViews allKeys] mutableCopy];
    [pageIds sortUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        if (obj1.integerValue < obj2.integerValue) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];

    NSMutableArray<HSDWebDebugWebViewInfo *> *retVal = [[NSMutableArray alloc] init];
    for (NSNumber *pageId in pageIds) {
        [retVal addObject:[self.allWebViews objectForKey:pageId]];
    }
    return retVal;
}

/**
 * recursive subviews and inject js script
 */
- (void)recursiveSubviewsInView:(UIView *)view {
    if ([view isKindOfClass:[WKWebView class]]) {
        // store webview
        WKWebView *webView = (WKWebView *)view;
        NSNumber *pageId = [self generatePageId];

        HSDWebDebugWebViewInfo *info = [[HSDWebDebugWebViewInfo alloc] init];
        info.webView = webView;
        info.pageId = pageId;
        [self.allWebViews setObject:info forKey:pageId];

        // inject js script
        [webView evaluateJavaScript:self.jsString completionHandler:^(id _Nullable abc, NSError * _Nullable error) {
//            NSLog(@"%@ : %@", abc, error);
        }];
    } else {
        // recursive subviews
        for (UIView *subview in [view subviews]) {
            [self recursiveSubviewsInView:subview];
        }
    }
}

- (NSNumber *)generatePageId {
    static NSInteger nextPageId = 1;   // page number, used to represent specific web view
    NSNumber *pageId = [NSNumber numberWithInteger:nextPageId];
    nextPageId++;
    return pageId;
}

- (void)handleDevProtocol:(HSDDevToolProtocolInfo *)devToolProtocolInfo parameters:(NSDictionary *)msgDict responseCallback:(void (^)(NSDictionary *, NSError *))responseCallback {
    NSDictionary *result = nil;
    if ([devToolProtocolInfo.domainName isEqualToString:kHSDWebDebugDomainDOM]) {
        if ([devToolProtocolInfo.methodName isEqualToString:@"getDocument"]) {
            HSDWebDebugWebViewInfo *webViewInfo = [self.allWebViews objectForKey:devToolProtocolInfo.pageId];
            webViewInfo.webView;

            NSString *a = @"/Users/jam/Desktop/workspace/ios-app/HttpServerDebug/Resources/HttpServerDebug.bundle/data.json";
            NSData *d = [[NSData alloc] initWithContentsOfFile:a];
            result = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
            result = [result objectForKey:@"result"];
        }
    }
    if (responseCallback) {
        responseCallback(result, nil);
    }
}

@end

@implementation HSDWebDebugWebViewInfo

@end

@implementation HSDDevToolProtocolInfo

@end
