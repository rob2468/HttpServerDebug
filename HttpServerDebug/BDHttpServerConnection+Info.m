//
//  BDHttpServerConnection+Info.m
//  HttpServerDebug
//
//  Created by chenjun on 2017/12/26.
//  Copyright © 2017年 chenjun. All rights reserved.
//

#import "BDHttpServerConnection+Info.h"
#import "BDHttpServerManager.h"
#import "BDHttpServerDebugDelegate.h"

@implementation BDHttpServerConnection (Info)

- (NSObject<HTTPResponse> *)fetchSendInfoResponseForMethod:(NSString *)method URI:(NSString *)path {
    return [super httpResponseForMethod:method URI:path];
}

- (NSObject<HTTPResponse> *)fetchSendInfoAPIResponsePath:(NSArray *)paths parameters:(NSDictionary *)params {
    NSDictionary *responseDict;
    if (params) {
        NSString *info = [params objectForKey:@"info"];
        info = [info stringByRemovingPercentEncoding];
        id<BDHttpServerDebugDelegate> delegate = [BDHttpServerManager fetchHSDDelegate];
        if ([delegate respondsToSelector:@selector(onHSDReceiveInfo:)]) {
            NSDictionary *result = [delegate onHSDReceiveInfo:info];
            if (result) {
                // construct response data
                responseDict = @{@"data": result};
            }
        }
    }
    // serialization
    NSData *responseData;
    if (responseDict) {
        responseData = [NSJSONSerialization dataWithJSONObject:responseDict options:0 error:nil];
    }
    if (!responseData) {
        responseData = [@"1" dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSObject<HTTPResponse> *response = [[HTTPDataResponse alloc] initWithData:responseData];
    return response;
}

@end
