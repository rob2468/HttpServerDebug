//
//  HSDHttpServerConnection+Preview.h
//  HttpServerDebug
//
//  Created by chenjun on 03/08/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "HSDHttpServerConnection.h"

@interface HSDHttpServerConnection (Preview)

- (NSObject<HTTPResponse> *)fetchFilePreviewResponse:(NSDictionary *)params forMethod:(NSString *)method URI:(NSString *)path;

@end
