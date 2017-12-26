//
//  BDHttpServerConnection+Info.h
//  HttpServerDebug
//
//  Created by chenjun on 2017/12/26.
//  Copyright © 2017年 chenjun. All rights reserved.
//

#import "BDHttpServerConnection.h"

@interface BDHttpServerConnection (Info)

- (NSObject<HTTPResponse> *)fetchSendInfoResponseForMethod:(NSString *)method URI:(NSString *)path;

- (NSObject<HTTPResponse> *)fetchSendInfoAPIResponsePath:(NSArray *)paths parameters:(NSDictionary *)params;

@end
