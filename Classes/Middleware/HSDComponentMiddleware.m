//
//  HSDComponentMiddleware.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/5/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDComponentMiddleware.h"
#import "HTTPDataResponse.h"
#import "HSDViewDebugComponent.h"

@implementation HSDComponentMiddleware

+ (NSObject<HTTPResponse> *)fetchViewDebugAPIResponsePaths:(NSArray *)paths parameters:(NSDictionary *)params {
    NSObject<HTTPResponse> *response;
    NSString *subModule;
    if ([paths count] > 1) {
        subModule = [paths objectAtIndex:1];
    }
    if (subModule.length > 0) {
        if ([subModule isEqualToString:@"all_views"]) {
            // get all views data
            NSArray *allViewsData = [HSDViewDebugComponent fetchAllViewsDataInHierarchy];
            NSData *data = [NSJSONSerialization dataWithJSONObject:allViewsData options:0 error:nil];
            response = [[HTTPDataResponse alloc] initWithData:data];
        } else if ([subModule isEqualToString:@"select_view"]) {
            NSString *memoryAddress = [params objectForKey:@"memory_address"];
            NSString *className = [params objectForKey:@"class_name"];
            UIView *view;
            
            unsigned long long addressPtr = ULONG_LONG_MAX;
            [[NSScanner scannerWithString:memoryAddress] scanHexLongLong:&addressPtr];
            if (addressPtr != ULONG_LONG_MAX && className.length > 0) {
                // get oc object according to memory address
                void *rawObj = (void *)(intptr_t)addressPtr;
                id obj = (__bridge id)rawObj;
                
                // type casting
                if (obj && [obj isKindOfClass:NSClassFromString(className)]) {
                    view = (UIView *)obj;
                }
            }
            
            NSString *thirdModule;
            if ([paths count] > 2) {
                thirdModule = [paths objectAtIndex:2];
            }
            if (view) {
                if ([thirdModule isEqualToString:@"snapshot"]) {
                    // get view snapshot
                    NSData *data = [HSDViewDebugComponent fetchViewSnapshotImageData:view];
                    response = [[HTTPDataResponse alloc] initWithData:data];
                } else {
                    
                }
                
            }
        }
    }
    return response;
}

@end
