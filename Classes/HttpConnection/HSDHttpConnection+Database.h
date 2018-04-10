//
//  HSDHttpConnection+Database.h
//  HttpServerDebug
//
//  Created by chenjun on 26/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "HSDHttpConnection.h"

@interface HSDHttpConnection (Database)

/**
 *  fetch html page
 */
- (NSObject<HTTPResponse> *)fetchDatabaseHTMLResponse:(NSDictionary *)params;

/**
 *  request table data, database schema; execute sql
 */
- (NSObject<HTTPResponse> *)fetchDatabaseAPIResponsePaths:(NSArray *)paths parameters:(NSDictionary *)params;

@end
