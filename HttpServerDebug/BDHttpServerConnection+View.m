//
//  BDHttpServerConnection+View.m
//  HttpServerDebug
//
//  Created by chenjun on 2017/10/30.
//  Copyright © 2017年 chenjun. All rights reserved.
//

#import "BDHttpServerConnection+View.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation BDHttpServerConnection (View)

- (NSObject<HTTPResponse> *)fetchViewDebugResponseForMethod:(NSString *)method URI:(NSString *)path {    
    return [super httpResponseForMethod:method URI:path];
}

- (NSObject<HTTPResponse> *)fetchViewDebugAPIResponse:(NSDictionary *)params {
    NSObject<HTTPResponse> *response;
    if ([params count] == 0) {
        NSArray *allViewsData = [self fetchAllViewsDataInHierarchy];
        NSData *data = [NSJSONSerialization dataWithJSONObject:allViewsData options:0 error:nil];
        response = [[HTTPDataResponse alloc] initWithData:data];
    } else {
        NSString *memoryAddress = [params objectForKey:@"memory_address"];
        unsigned long long addressPtr = ULONG_LONG_MAX;
        [[NSScanner scannerWithString:memoryAddress] scanHexLongLong:&addressPtr];
        void *rawObj = (void *)(intptr_t)addressPtr;
        id obj = (__bridge id)rawObj;
        UIView *view = (UIView *)obj;
        NSString *str = NSStringFromCGRect(view.frame);
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        response = [[HTTPDataResponse alloc] initWithData:data];
    }
    return response;
}

- (NSArray *)fetchAllViewsDataInHierarchy {
    NSArray *(^MainThreadBlock)(void) = ^{
        NSMutableArray *allViewsData = [[NSMutableArray alloc] init];
        NSArray *windows = [BDHttpServerConnection fetchAllWindows];
        for (UIWindow *window in windows) {
            NSDictionary *viewData = [self fetchViewData:window];
            [allViewsData addObject:viewData];
            
            [allViewsData addObjectsFromArray:[self allRecursiveSubviewsInView:window]];
        }
        return allViewsData;
    };
    __block NSArray *allViews;
    if ([NSThread isMainThread]) {
        allViews = MainThreadBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            allViews = MainThreadBlock();
        });
    }
    return allViews;
}

/**
 *  {
 *  "description": ,
 *  "class_name": ,
 *  "memory_adress: ,
 *  "hierarchy_depth: ": ,      // view hierarchy depth num, 0 indexed
 *  }
 */
- (NSDictionary *)fetchViewData:(UIView *)view {
    NSMutableDictionary *viewData = [[NSMutableDictionary alloc] init];
    NSString *description = [[view class] description];
    NSString *className = NSStringFromClass([view class]);
    NSString *memoryAddress = [NSString stringWithFormat:@"%p", view];
    // hierarchy depth
    NSInteger depth = 0;
    UIView *tryView = view;
    while (tryView.superview) {
        tryView = tryView.superview;
        depth++;
    }
    
    [viewData setObject:description forKey:@"description"];
    [viewData setObject:className forKey:@"class_name"];
    [viewData setObject:memoryAddress forKey:@"memory_address"];
    [viewData setObject:[NSNumber numberWithInteger:depth] forKey:@"hierarchy_depth"];
    return viewData;
}

- (NSDictionary *)fetchHierarchyDepthsForViews:(NSArray *)views {
    NSMutableDictionary *hierarchyDepths = [[NSMutableDictionary alloc] init];
    for (UIView *view in views) {
        NSInteger depth = 0;
        UIView *tryView = view;
        while (tryView.superview) {
            tryView = tryView.superview;
            depth++;
        }
        [hierarchyDepths setObject:@(depth) forKey:[NSValue valueWithNonretainedObject:view]];
    }
    return hierarchyDepths;
}

- (NSArray *)allRecursiveSubviewsInView:(UIView *)view {
    NSMutableArray *subviews = [[NSMutableArray alloc] init];
    for (UIView *subview in view.subviews) {
        NSDictionary *subviewData = [self fetchViewData:subview];
        [subviews addObject:subviewData];
        [subviews addObjectsFromArray:[self allRecursiveSubviewsInView:subview]];
    }
    return subviews;
}

+ (NSArray *)fetchAllWindows {
    // allWindowsIncludingInternalWindows:YES onlyVisibleWindows:NO
    BOOL includeInternalWindows = YES;
    BOOL onlyVisibleWindows = NO;
    
    NSArray *allWindowsComponents = @[@"al", @"lWindo", @"wsIncl", @"udingInt", @"ernalWin", @"dows:o", @"nlyVisi", @"bleWin", @"dows:"];
    SEL allWindowsSelector = NSSelectorFromString([allWindowsComponents componentsJoinedByString:@""]);
    
    NSMethodSignature *methodSignature = [[UIWindow class] methodSignatureForSelector:allWindowsSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    
    invocation.target = [UIWindow class];
    invocation.selector = allWindowsSelector;
    [invocation setArgument:&includeInternalWindows atIndex:2];
    [invocation setArgument:&onlyVisibleWindows atIndex:3];
    [invocation invoke];
    
    __unsafe_unretained NSArray *windows = nil;
    [invocation getReturnValue:&windows];
    return windows;
}

@end
