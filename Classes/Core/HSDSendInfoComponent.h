//
//  HSDSendInfoComponent.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//
//  TODO: decouple from cocoahttpserver

#import <Foundation/Foundation.h>
@protocol HTTPResponse;
@class HTTPMessage;

@interface HSDSendInfoComponent : NSObject

- (NSObject<HTTPResponse> *)fetchSendInfoAPIResponseForMethod:(NSString *)method paths:(NSArray *)paths parameters:(NSDictionary *)params withRequest:(HTTPMessage *)request;

@end
