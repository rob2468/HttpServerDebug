//
//  HSDDBInspectComponent.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//
//  TODO: decouple from cocoahttpserver

#import <Foundation/Foundation.h>
@protocol HTTPResponse;
@class HTTPConnection;

@interface HSDDBInspectComponent : NSObject

/**
 *  fetch html page
 */
- (NSObject<HTTPResponse> *)fetchDatabaseHTMLResponse:(NSDictionary *)params withConnection:(HTTPConnection *)connection;

/**
 *  request table data, database schema; execute sql
 */
- (NSObject<HTTPResponse> *)fetchDatabaseAPIResponsePaths:(NSArray *)paths parameters:(NSDictionary *)params;

@end
