//
//  BDHttpServerConnection+Explorer.h
//  BDPhoneBrowser
//
//  Created by chenjun on 02/08/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "BDHttpServerConnection.h"

@interface BDHttpServerConnection (Explorer)

- (NSObject<HTTPResponse> *)fetchFileExplorerResponse:(NSDictionary *)params forMethod:(NSString *)method URI:(NSString *)path;

@end
