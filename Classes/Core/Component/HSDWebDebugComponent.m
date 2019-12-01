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

@interface HSDWebDebugComponent()

@property (strong, nonatomic) NSHashTable *allWebViews;
@property (copy, nonatomic) NSString *jsString;

@end

@implementation HSDWebDebugComponent

- (instancetype)init {
    self = [super init];
    if (self) {
//        self.allWebViews = [NSHashTable weakObjectsHashTable];
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"HttpServerDebug" ofType:@"bundle"];
        NSString *inspectFile = [resourcePath stringByAppendingPathComponent:@"HSDWebDebugInspector.js"];
        self.jsString = [[NSString alloc] initWithContentsOfFile:inspectFile encoding:NSUTF8StringEncoding error:nil];
    }
    return self;
}

- (NSArray<HSDWebDebugWebViewInfo *> *)allWebViewInfo {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    NSMutableDictionary<NSString *, HSDWebDebugWebViewInfo *> *titlesDict = [[NSMutableDictionary alloc] init];
    NSMutableArray<NSString *> *webViewAddrs = [[NSMutableArray alloc] init]; // webView memory addresses, used to sort the titles array

    self.allWebViews = [NSHashTable weakObjectsHashTable];
    dispatch_sync(dispatch_get_main_queue(), ^{
        // get all webviews
        NSArray *windows = [HSDViewDebugComponent fetchAllWindows];
        for (UIWindow *window in windows) {
            [self recursiveSubviewsInView:window];
        }

        NSInteger count = [self.allWebViews count];
        for (WKWebView *webView in self.allWebViews) {
            NSString *memAddr = [NSString stringWithFormat:@"%p", webView];

            // get webview title
            [webView evaluateJavaScript:@"getWebViewInfo();" completionHandler:^(NSDictionary *webViewInfo, NSError * _Nullable error) {
                HSDWebDebugWebViewInfo *infoObj = [[HSDWebDebugWebViewInfo alloc] init];
                infoObj.title = [webViewInfo objectForKey:@"title"];
                infoObj.url = [webViewInfo objectForKey:@"url"];
                [titlesDict setObject:infoObj forKey:memAddr];

                if ([titlesDict count] >= count) {
                    // all titles have gotten
                    dispatch_semaphore_signal(semaphore);
                }
            }];

            // memory address
            [webViewAddrs addObject:memAddr];
        }
    });

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    // sort
    NSMutableArray<HSDWebDebugWebViewInfo *> *retVal = [[NSMutableArray alloc] init];
    for (WKWebView *webView in self.allWebViews) {
        NSString *memAddr = [NSString stringWithFormat:@"%p", webView];
        for (NSString *key in [titlesDict allKeys]) {
            if ([memAddr isEqualToString:key]) {
                [retVal addObject:[titlesDict objectForKey:key]];
                break;
            }
        }
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
        [self.allWebViews addObject:webView];

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

@end

@implementation HSDWebDebugWebViewInfo

@end
