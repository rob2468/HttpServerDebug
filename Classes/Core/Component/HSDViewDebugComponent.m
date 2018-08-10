//
//  HSDViewDebugComponent.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDViewDebugComponent.h"
#import <objc/runtime.h>

@implementation HSDViewDebugComponent

+ (NSArray *)fetchAllViewsDataInHierarchy {
    NSArray *(^MainThreadBlock)(void) = ^{
        NSMutableArray *allViewsData = [[NSMutableArray alloc] init];
        NSArray *windows = [HSDViewDebugComponent fetchAllWindows];
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

+ (NSArray *)allRecursiveSubviewsInView:(UIView *)view inWindow:(UIWindow *)window {
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

/**
 *  {
 *  "description": ,
 *  "className": ,
 *  "memoryAdress: ,
 *  "hierarchyDepth: ": ,      // view hierarchy depth num, 0 indexed
 *  "clippedFrameRoot":{"x":"","y":"","width":"","height":""},  // clipped content
 *  "frame":{"x":"","y":"","width":"","height":""},
 *  "bounds":{"x":"","y":"","width":"","height":""},
 *  "frameRoot":{"x":"","y":"","width":"","height":""},         // frame in window
 *  "snapshotNosub": ,                                          // snapshot without subviews
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
+ (NSDictionary *)fetchViewData:(UIView *)view inWindow:(UIWindow *)window {
    NSMutableDictionary *viewData = [[NSMutableDictionary alloc] init];
    NSString *description = [[view class] description];
    NSString *className = NSStringFromClass([view class]);
    NSString *memoryAddress = [NSString stringWithFormat:@"%p", view];

    // hierarchyDepth, clippedFrameRoot
    NSInteger hierarchyDepth = 0;
    CGPoint tryClippedOrigin = CGPointMake(0, 0);           // origin will be updated
    if ([view isKindOfClass:[UIScrollView class]]) {
        // scroll view case
        UIScrollView *scrollView = (UIScrollView *)view;
        CGPoint contentOffset = scrollView.contentOffset;
        tryClippedOrigin = contentOffset;
    }
    CGSize tryClippedSize = view.frame.size;                // size will be updated
    UIView *tryView = view;
    while (tryView.superview) {
        UIView *superview = tryView.superview;

        // convert origin
        tryClippedOrigin = [tryView convertPoint:tryClippedOrigin toView:superview];

        if (!CGSizeEqualToSize(tryClippedSize, CGSizeMake(0, 0)) &&
            superview.clipsToBounds) {
            // convert size
            CGRect tryClippedFrame = CGRectMake(tryClippedOrigin.x, tryClippedOrigin.y, tryClippedSize.width, tryClippedSize.height);
            CGRect frame = CGRectMake(0, 0, 0, 0);
            frame.size = superview.bounds.size;
            tryClippedFrame = CGRectIntersection(tryClippedFrame, frame);

            // update origin
            if (tryClippedOrigin.x < 0) {
                tryClippedOrigin.x = 0;
            }
            if (tryClippedOrigin.y < 0) {
                tryClippedOrigin.y = 0;
            }

            // parse size from frame
            tryClippedSize = tryClippedFrame.size;
        }

        tryView = superview;
        hierarchyDepth++;
    }
    CGRect clippedFrameRoot = CGRectMake(0, 0, 0, 0);   // frame for clipped view in window
    if (!CGSizeEqualToSize(tryClippedSize, CGSizeMake(0, 0))) {
        clippedFrameRoot = CGRectMake(tryClippedOrigin.x, tryClippedOrigin.y, tryClippedSize.width, tryClippedSize.height);
    }
    NSDictionary *clippedFrameRootDict = [self convertCGRect:clippedFrameRoot];

    CGPoint clippedOrigin = [view convertPoint:tryClippedOrigin fromView:window];   // origin for snapshot clipped view

    // frame
    CGRect frame = view.frame;
    NSDictionary *frameDict = [self convertCGRect:frame];

    // bounds
    CGRect bounds = view.bounds;
    NSDictionary *boundsDict = [self convertCGRect:bounds];

    // frameRoot
    CGRect frameRoot = [view convertRect:view.bounds toView:window];
    NSDictionary *frameRootDict = [self convertCGRect:frameRoot];

    // snapshot without subviews
    NSString *snapshotDataStr = @"";
    if (!CGSizeEqualToSize(clippedFrameRoot.size, CGSizeMake(0, 0))) {
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
        UIGraphicsBeginImageContextWithOptions(clippedFrameRoot.size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGFloat tx = -clippedOrigin.x;
        CGFloat ty = -clippedOrigin.y;
        CGContextTranslateCTM(context, tx, ty);
        [view.layer renderInContext:context];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        // show subviews
        for (UIView *subview in subviews) {
            [[self class] view:subview baseClassSetHidden:NO];
        }

        // image data
        NSData *snapshotData = UIImagePNGRepresentation(snapshot);
        snapshotDataStr = [snapshotData base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
        snapshotDataStr = snapshotDataStr.length > 0 ? snapshotDataStr: @"";
    }
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
    [viewData setObject:[NSNumber numberWithInteger:hierarchyDepth] forKey:@"hierarchyDepth"];
    [viewData setObject:clippedFrameRootDict forKey:@"clippedFrameRoot"];
    [viewData setObject:frameDict forKey:@"frame"];
    [viewData setObject:boundsDict forKey:@"bounds"];
    [viewData setObject:frameRootDict forKey:@"frameRoot"];
    [viewData setObject:snapshotDataStr forKey:@"snapshotNosub"];
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

+ (NSData *)fetchViewSnapshotImageData:(UIView *)view {
    NSData *(^MainThreadBlock)(void) = ^{
        // get view snapshot
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();

        // handle UIScrollView
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            CGPoint contentOffset = scrollView.contentOffset;
            CGContextTranslateCTM(context, -contentOffset.x, -contentOffset.y);
        }

        [view.layer renderInContext:context];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        // image data
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

+ (NSDictionary *)convertCGRect:(CGRect)rect {
    NSDictionary *dict =
    @{@"x": @(rect.origin.x),
      @"y": @(rect.origin.y),
      @"width": @(rect.size.width),
      @"height": @(rect.size.height)
      };
    return dict;
}

#pragma mark - Method IMP

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
