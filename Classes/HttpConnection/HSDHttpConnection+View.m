//
//  HSDHttpConnection+View.m
//  HttpServerDebug
//
//  Created by chenjun on 2017/10/30.
//  Copyright © 2017年 chenjun. All rights reserved.
//

#import "HSDHttpConnection+View.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation HSDHttpConnection (View)

#pragma mark - create http response

- (NSObject<HTTPResponse> *)fetchViewDebugResponseForMethod:(NSString *)method URI:(NSString *)path {    
    return [super httpResponseForMethod:method URI:path];
}

- (NSObject<HTTPResponse> *)fetchViewDebugAPIResponsePaths:(NSArray *)paths parameters:(NSDictionary *)params {
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
        NSArray *windows = [HSDHttpConnection fetchAllWindows];
        for (UIWindow *window in windows) {
            // generate all views data of displayed window
            if (![[self class] viewBaseClassIsHidden:window]) {
                NSDictionary *viewData = [self fetchViewData:window inWindow:window];
                [allViewsData addObject:viewData];
                [allViewsData addObjectsFromArray:[self allRecursiveSubviewsInView:window inWindow:window]];
            }
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
 *  "className": ,
 *  "memoryAdress: ,
 *  "hierarchyDepth: ": ,      // view hierarchy depth num, 0 indexed
 *  "frameRoot":{"x":"","y":"","width":"","height":""},// frame in window
 *  "snapshotNosub": ,         // snapshot without subviews
 *  "frame":{"x":"","y":"","width":"","height":""},
 *  "bounds":{"x":"","y":"","width":"","height":""},
 *  "position":{"x":"","y":""},
 *  "zPosition": ,
 *  "contentMode": ,
 *  "tag": ,
 *  "isUserInteractionEnabled": ,
 *  "isMultipleTouchEnabled": ,
 *  "isHidden": ,
 *  "isOpaque": ,
 *  "clipsToBounds": ,
 *  "backgroundColor":{"r":,"g":,"b":,"a":} | {"r":"nil color"}
 *  "three": {"mesh": , "wireframe": }, // webgl elements, set in js context
 *  }
 */
- (NSDictionary *)fetchViewData:(UIView *)view inWindow:(UIWindow *)window {
    NSMutableDictionary *viewData = [[NSMutableDictionary alloc] init];
    NSString *description = [[view class] description];
    NSString *className = NSStringFromClass([view class]);
    NSString *memoryAddress = [NSString stringWithFormat:@"%p", view];
    // hierarchyDepth
    NSInteger depth = 0;
    UIView *tryView = view;
    while (tryView.superview) {
        tryView = tryView.superview;
        depth++;
    }
    // frameRoot
    CGRect frameRoot = [view convertRect:view.bounds toView:window];
    NSDictionary *frameRootDict =
  @{@"x": @(frameRoot.origin.x),
    @"y": @(frameRoot.origin.y),
    @"width": @(frameRoot.size.width),
    @"height": @(frameRoot.size.height)
    };
    // snapshot without subviews
    // hide subviews
    NSMutableSet *subviews = [[NSMutableSet alloc] init];
    for (UIView *subview in view.subviews) {
        BOOL isHidden = [[self class] viewBaseClassIsHidden:subview];
        if (!isHidden) {
            // collect
            [subviews addObject:subview];
            // hide
            [[self class] view:subview baseClassSetHidden:YES];
        }
    }
    // get view snapshot
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // show subviews
    for (UIView *subview in subviews) {
        [[self class] view:subview baseClassSetHidden:NO];
    }
    NSData *snapshotData = UIImagePNGRepresentation(snapshot);
    NSString *snapshotDataStr = [snapshotData base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
    snapshotDataStr = snapshotDataStr.length > 0? snapshotDataStr: @"";
    // frame
    CGRect frame = view.frame;
    NSDictionary *frameDict =
    @{@"x": @(frame.origin.x),
      @"y": @(frame.origin.y),
      @"width": @(frame.size.width),
      @"height": @(frame.size.height)
      };
    // bounds
    CGRect bounds = view.bounds;
    NSDictionary *boundsDict =
    @{@"x": @(bounds.origin.x),
      @"y": @(bounds.origin.y),
      @"width": @(bounds.size.width),
      @"height": @(bounds.size.height)
      };
    // position
    CGPoint position = view.layer.position;
    NSDictionary *positionDict =
    @{@"x": @(position.x),
      @"y": @(position.y)
      };
    // zPosition
    CGFloat zPosition = view.layer.zPosition;
    // contentMode
    NSString *contentMode = @"";
    NSArray<NSString *> *contentModeArr =
  @[@"UIViewContentModeScaleToFill",
    @"UIViewContentModeScaleAspectFit",
    @"UIViewContentModeScaleAspectFill",
    @"UIViewContentModeRedraw",
    @"UIViewContentModeCenter",
    @"UIViewContentModeTop",
    @"UIViewContentModeBottom",
    @"UIViewContentModeLeft",
    @"UIViewContentModeRight",
    @"UIViewContentModeTopLeft",
    @"UIViewContentModeTopRight",
    @"UIViewContentModeBottomLeft",
    @"UIViewContentModeBottomRight"];
    if (view.contentMode >= 0 && view.contentMode < [contentModeArr count]) {
         contentMode = [contentModeArr objectAtIndex:view.contentMode];
    }
    // Tag
    NSInteger tag = view.tag;
    // isUserInteractionEnabled
    BOOL isUserInteractionEnabled = view.isUserInteractionEnabled;
    // isMultipleTouchEnabled
    BOOL isMultipleTouchEnabled = view.isMultipleTouchEnabled;
    // isHidden
    BOOL isHidden = [[self class] viewBaseClassIsHidden:view];
    // isOpaque
    BOOL isOpaque = view.isOpaque;
    // clipsToBounds
    BOOL clipsToBounds = view.clipsToBounds;
    // autoresizesSubviews
    BOOL autoresizesSubviews = view.autoresizesSubviews;
    // layer
    NSString *layerMemoryAddress = @"";
    NSString *layerClassName = @"";
    id layer = view.layer;
    if (layer) {
        layerMemoryAddress = [NSString stringWithFormat:@"%p", layer];
        layerClassName = NSStringFromClass([layer class]);
    }
    // alpha
    CGFloat alpha = view.alpha;
    // backgroundColor
    UIColor *backgroundColor = view.backgroundColor;
    NSDictionary *backgroundColorDict;
    if (!backgroundColor) {
        backgroundColorDict =
        @{
          @"r": @"nil color"
          };
    } else {
        CGFloat red, green, blue, a;
        BOOL suc = [backgroundColor getRed:&red green:&green blue:&blue alpha:&a];
        if (suc) {
            backgroundColorDict =
            @{
              @"r": @(red * 255),
              @"g": @(green * 255),
              @"b": @(blue * 255),
              @"a": @(a)
              };
        } else {
            CGColorSpaceRef colorSpace = CGColorGetColorSpace(backgroundColor.CGColor);
            NSString *str = [NSString stringWithFormat:@"%@", colorSpace];
            str = str.length > 0 ? str : @"";
            backgroundColorDict =
            @{
              @"r": str
              };
        }
    }
    
    // construct data
    [viewData setObject:description forKey:@"description"];
    [viewData setObject:className forKey:@"className"];
    [viewData setObject:memoryAddress forKey:@"memoryAddress"];
    [viewData setObject:[NSNumber numberWithInteger:depth] forKey:@"hierarchyDepth"];
    [viewData setObject:frameRootDict forKey:@"frameRoot"];
    [viewData setObject:snapshotDataStr forKey:@"snapshotNosub"];
    [viewData setObject:frameDict forKey:@"frame"];
    [viewData setObject:boundsDict forKey:@"bounds"];
    [viewData setObject:positionDict forKey:@"position"];
    [viewData setObject:@(zPosition) forKey:@"zPosition"];
    [viewData setObject:contentMode forKey:@"contentMode"];
    [viewData setObject:@(tag) forKey:@"tag"];
    [viewData setObject:@(isUserInteractionEnabled) forKey:@"isUserInteractionEnabled"];
    [viewData setObject:@(isMultipleTouchEnabled) forKey:@"isMultipleTouchEnabled"];
    [viewData setObject:@(isHidden) forKey:@"isHidden"];
    [viewData setObject:@(isOpaque) forKey:@"isOpaque"];
    [viewData setObject:@(clipsToBounds) forKey:@"clipsToBounds"];
    [viewData setObject:@(autoresizesSubviews) forKey:@"autoresizesSubviews"];
    [viewData setObject:layerMemoryAddress forKey:@"layerMemoryAddress"];
    [viewData setObject:layerClassName forKey:@"layerClassName"];
    [viewData setObject:@(alpha) forKey:@"alpha"];
    [viewData setObject:backgroundColorDict forKey:@"backgroundColor"];
    
    return viewData;
}

- (NSArray *)allRecursiveSubviewsInView:(UIView *)view inWindow:(UIWindow *)window {
    NSMutableArray *subviews = [[NSMutableArray alloc] init];
    for (UIView *subview in view.subviews) {
        // generate data of displayed subview
        if (![[self class] viewBaseClassIsHidden:subview]) {
            NSDictionary *subviewData = [self fetchViewData:subview inWindow:window];
            [subviews addObject:subviewData];
            [subviews addObjectsFromArray:[self allRecursiveSubviewsInView:subview inWindow:window]];
        }
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

static BOOL (*baseClassIsHiddenIMP)(id, SEL);
static void (*baseClassSetHiddenIMP)(id, SEL, BOOL);

+ (BOOL)viewBaseClassIsHidden:(UIView *)view {
    if (!baseClassIsHiddenIMP) {
        // base class (UIView) hidden method
        Method baseClassIsHiddenMethod = class_getInstanceMethod([UIView class], @selector(isHidden));
        baseClassIsHiddenIMP = (BOOL (*)(id, SEL))method_getImplementation(baseClassIsHiddenMethod);
    }
    BOOL isHidden = baseClassIsHiddenIMP(view, @selector(isHidden));
    return isHidden;
}

+ (void)view:(UIView *)view baseClassSetHidden:(BOOL)isHidden {
    if (!baseClassSetHiddenIMP) {
        // base class (UIView) setHidden: method
        Method baseClassSetHiddenMethod = class_getInstanceMethod([UIView class], @selector(setHidden:));
        baseClassSetHiddenIMP = (void (*)(id, SEL, BOOL))method_getImplementation(baseClassSetHiddenMethod);
    }
    baseClassSetHiddenIMP(view, @selector(setHidden:), isHidden);
}

@end
