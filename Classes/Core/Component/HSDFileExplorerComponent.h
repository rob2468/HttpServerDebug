//
//  HSDFileExplorerComponent.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//
//  TODO: decouple from cocoahttpserver

#import <Foundation/Foundation.h>
@protocol HTTPResponse;

@interface HSDFileExplorerComponent : NSObject

/**
 *  request data
 */
- (NSObject<HTTPResponse> *)fetchFileExplorerAPIResponsePaths:(NSArray *)paths parameters:(NSDictionary *)params;

@end
