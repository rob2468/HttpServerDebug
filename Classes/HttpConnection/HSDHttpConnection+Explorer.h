//
//  HSDHttpConnection+Explorer.h
//  HttpServerDebug
//
//  Created by chenjun on 02/08/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "HSDHttpConnection.h"

@interface HSDHttpConnection (Explorer)

/**
 *  request html
 */
- (NSObject<HTTPResponse> *)fetchFileExplorerResponse:(NSDictionary *)params forMethod:(NSString *)method URI:(NSString *)path;

/**
 *  request data
 */
- (NSObject<HTTPResponse> *)fetchFileExplorerAPIResponsePaths:(NSArray *)paths parameters:(NSDictionary *)params;

@end
