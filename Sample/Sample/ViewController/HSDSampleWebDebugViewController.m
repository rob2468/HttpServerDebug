//
//  HSDSampleWebDebugViewController.m
//  Sample
//
//  Created by jam.chenjun on 2019/11/5.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import "HSDSampleWebDebugViewController.h"
#import <WebKit/WebKit.h>

@interface HSDSampleWebDebugViewController()
<WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation HSDSampleWebDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // webView
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    NSURL *url = [NSURL URLWithString:@"https://blog.jamchenjun.com/"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];

//    [[self.webView configuration].userContentController addScriptMessageHandler:self name:@"hsdTest"];
//
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self stub];
//    });
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%@", message.name);
}

- (void)stub {
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"HttpServerDebug" ofType:@"bundle"];
    NSString *inspectFile = [resourcePath stringByAppendingPathComponent:@"HSDWebDebugInspector.js"];
    NSString *jsString = [[NSString alloc] initWithContentsOfFile:inspectFile encoding:NSUTF8StringEncoding error:nil];
    [self.webView evaluateJavaScript:jsString completionHandler:^(id _Nullable abc, NSError * _Nullable error) {
        NSLog(@"%@ : %@", abc, error);
    }];
}

@end
