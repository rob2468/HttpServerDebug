//
//  HSDFilePreviewComponent.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//
//  TODO: decouple from cocoahttpserver

#import <Foundation/Foundation.h>
@protocol HTTPResponse;

@interface HSDFilePreviewComponent : NSObject

- (NSObject<HTTPResponse> *)fetchFilePreviewResponse:(NSDictionary *)params forMethod:(NSString *)method URI:(NSString *)path;

@end
