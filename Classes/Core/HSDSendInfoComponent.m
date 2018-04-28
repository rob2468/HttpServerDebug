//
//  HSDSendInfoComponent.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDSendInfoComponent.h"
#import "HSDManager+Private.h"
#import "HTTPMessage.h"
#import "HSDDelegate.h"
#import "HTTPDataResponse.h"

@implementation HSDSendInfoComponent

- (NSObject<HTTPResponse> *)fetchSendInfoAPIResponseForMethod:(NSString *)method paths:(NSArray *)paths parameters:(NSDictionary *)params withRequest:(HTTPMessage *)request {
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
