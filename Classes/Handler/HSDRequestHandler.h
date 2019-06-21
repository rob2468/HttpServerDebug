//
//  HSDRequestHandler.h
//  HttpServerDebug
//
//  Created by 陈军 on 2018/11/5.
//  Copyright © 2018 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HSDGWebServerRequest;
@class HSDGWebServerResponse;

@interface HSDRequestHandler : NSObject

+ (HSDGWebServerResponse *)handleRequest:(HSDGWebServerRequest *)request;

@end
