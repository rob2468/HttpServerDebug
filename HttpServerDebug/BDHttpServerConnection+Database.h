//
//  BDHttpServerConnection+Database.h
//  BaiduBrowser
//
//  Created by chenjun on 26/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "BDHttpServerConnection.h"

@interface BDHttpServerConnection (Database)

- (NSObject<HTTPResponse> *)fetchDatabaseResponse:(NSDictionary *)params;

@end
