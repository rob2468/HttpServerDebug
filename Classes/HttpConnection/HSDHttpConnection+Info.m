//
//  HSDHttpConnection+Info.m
//  HttpServerDebug
//
//  Created by chenjun on 2017/12/26.
//  Copyright © 2017年 chenjun. All rights reserved.
//

#import "HSDHttpConnection+Info.h"
#import "HSDManager.h"
#import "HSDDelegate.h"
#import "HTTPMessage.h"

@implementation HSDHttpConnection (Info)

- (NSObject<HTTPResponse> *)fetchSendInfoResponseForMethod:(NSString *)method URI:(NSString *)path {
    return [super httpResponseForMethod:method URI:path];
}

- (NSObject<HTTPResponse> *)fetchSendInfoAPIResponseForMethod:(NSString *)method paths:(NSArray *)paths parameters:(NSDictionary *)params {
    NSDictionary *responseDict;
    NSString *info;
    // parse info from request
    if ([method isEqualToString:@"GET"]) {
        if (params) {
            info = [params objectForKey:@"info"];
            info = [info stringByRemovingPercentEncoding];
        }
    } else if ([method isEqualToString:@"POST"]) {
        NSString *contentType = [request headerField:@"Content-Type"];
        if ([contentType hasPrefix:@"text/plain"]
            || [contentType hasPrefix:@"application/x-www-form-urlencoded"]) {
            NSData *infoData = [request body];
            info = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
        }
    }
    // forward to the delegate
    id<HSDDelegate> delegate = [HSDManager fetchHSDDelegate];
    if ([delegate respondsToSelector:@selector(onHSDReceiveInfo:)]) {
        NSDictionary *result = [delegate onHSDReceiveInfo:info];
        if (result) {
            // construct response data
            responseDict = @{@"data": result};
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
