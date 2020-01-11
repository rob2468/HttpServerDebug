//
//  HSDWebDebugComponent.h
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/12/1.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HSDWebDebugWebViewInfo;
@class HSDDevToolProtocolInfo;
@class WKWebView;

@interface HSDWebDebugComponent : NSObject

/**
 */
- (NSArray<HSDWebDebugWebViewInfo *> *)allWebViewInfo;

- (void)handleDevProtocol:(HSDDevToolProtocolInfo *)devToolProtocolInfo parameters:(NSDictionary *)msgDict responseCallback:(void(^)(NSDictionary *result, NSError *error))responseCallback;

@end

@interface HSDWebDebugWebViewInfo : NSObject

@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSNumber *pageId;

@end

@interface HSDDevToolProtocolInfo : NSObject

@property (nonatomic, strong) NSNumber *pageId;     // indicate web page
@property (nonatomic, copy) NSString *objectId;     // indicate one communication
@property (nonatomic, copy) NSString *domainName;
@property (nonatomic, copy) NSString *methodName;
@property (nonatomic, strong) NSDictionary *params;

@end
