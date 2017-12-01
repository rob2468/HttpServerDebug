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

#pragma mark - create http response

- (NSObject<HTTPResponse> *)fetchViewDebugResponseForMethod:(NSString *)method URI:(NSString *)path {    
    return [super httpResponseForMethod:method URI:path];
}

- (NSObject<HTTPResponse> *)fetchViewDebugAPIResponsePath:(NSArray *)paths parameters:(NSDictionary *)params {
    NSObject<HTTPResponse> *response;
    NSString *subModule;
    if ([paths count] > 1) {
        subModule = [paths objectAtIndex:1];
    }
    if (subModule.length > 0) {
        if ([subModule isEqualToString:@"all_views"]) {
            // get all views data
            NSArray *allViewsData = [self fetchAllViewsDataInHierarchy];
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
                if ([obj isKindOfClass:NSClassFromString(className)]) {
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
                    NSData *data = [self fetchViewSnapshotImageData:view];
                    response = [[HTTPDataResponse alloc] initWithData:data];
                } else {
                    
                }

            }
        }
    }
    return response;
}

#pragma mark -

- (NSData *)fetchViewSnapshotImageData:(UIView *)view {
    NSData *(^MainThreadBlock)(void) = ^{
        // get view snapshot
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *data = UIImagePNGRepresentation(snapshot);
        return data;
    };
    __block NSData *imageData;
    if ([NSThread isMainThread]) {
        imageData = MainThreadBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            imageData = MainThreadBlock();
        });
    }
    return imageData;
}

- (NSArray *)fetchAllViewsDataInHierarchy {
    NSArray *(^MainThreadBlock)(void) = ^{
        NSMutableArray *allViewsData = [[NSMutableArray alloc] init];
        NSArray *windows = [BDHttpServerConnection fetchAllWindows];
        for (UIWindow *window in windows) {
            NSDictionary *viewData = [self fetchViewData:window inWindow:window];
            [allViewsData addObject:viewData];
            
            [allViewsData addObjectsFromArray:[self allRecursiveSubviewsInView:window inWindow:window]];
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
 *  "frame": ,                  // frame in window
 *  "snapshot": ,               // snapshot without subviews
 *  "three": {"mesh": , "wireframe": }, // webgl elements, set in js context
 *  }
 */
- (NSDictionary *)fetchViewData:(UIView *)view inWindow:(UIWindow *)window {
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
    // frame
    CGRect frame = [view convertRect:view.bounds toView:window];
    NSDictionary *frameDict =
  @{@"x": @(frame.origin.x),
    @"y": @(frame.origin.y),
    @"width": @(frame.size.width),
    @"height": @(frame.size.height)
    };
    // snapshot without subviews
    // base class (UIView) setHidden: method
    Method baseSetHiddenMethod = class_getInstanceMethod([UIView class], @selector(setHidden:));
    void (*baseSetHiddenIMP)(id, SEL, BOOL);
    baseSetHiddenIMP = (void (*)(id, SEL, BOOL))method_getImplementation(baseSetHiddenMethod);
    // base class (UIView) hidden method
    Method baseIsHiddenMethod = class_getInstanceMethod([UIView class], @selector(isHidden));
    BOOL (*baseIsHiddenIMP)(id, SEL);
    baseIsHiddenIMP = (BOOL (*)(id, SEL))method_getImplementation(baseIsHiddenMethod);
    // hide subviews
    NSMutableSet *subviews = [[NSMutableSet alloc] init];
    for (UIView *subview in view.subviews) {
        BOOL isHidden = baseIsHiddenIMP(subview, @selector(isHidden));
        if (!isHidden) {
            // collect
            [subviews addObject:subview];
            // hide
            baseSetHiddenIMP(subview, @selector(setHidden:), YES);
        }
    }
    // get view snapshot
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // show subviews
    for (UIView *subview in subviews) {
        baseSetHiddenIMP(subview, @selector(setHidden:), NO);
    }
    NSData *snapshotData = UIImagePNGRepresentation(snapshot);
    NSString *snapshotDataStr = [snapshotData base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
    snapshotDataStr = snapshotDataStr.length > 0? snapshotDataStr: @"";
    
    [viewData setObject:description forKey:@"description"];
    [viewData setObject:className forKey:@"class_name"];
    [viewData setObject:memoryAddress forKey:@"memory_address"];
    [viewData setObject:[NSNumber numberWithInteger:depth] forKey:@"hierarchy_depth"];
    [viewData setObject:frameDict forKey:@"frame"];
    [viewData setObject:snapshotDataStr forKey:@"snapshot"];
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

- (NSArray *)allRecursiveSubviewsInView:(UIView *)view  inWindow:(UIWindow *)window {
    NSMutableArray *subviews = [[NSMutableArray alloc] init];
    for (UIView *subview in view.subviews) {
        NSDictionary *subviewData = [self fetchViewData:subview inWindow:window];
        [subviews addObject:subviewData];
        [subviews addObjectsFromArray:[self allRecursiveSubviewsInView:subview inWindow:window]];
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
