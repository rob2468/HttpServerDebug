//
//  BDHttpServerConnection+Preview.h
//  BDPhoneBrowser
//
//  Created by chenjun on 03/08/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "BDHttpServerConnection.h"

@interface BDHttpServerConnection (Preview)

- (NSObject<HTTPResponse> *)fetchFilePreviewResponse:(NSDictionary *)params forMethod:(NSString *)method URI:(NSString *)path;

@end
