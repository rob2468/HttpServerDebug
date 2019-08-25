//
//  HSDViewDebugComponent.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDViewDebugComponent.h"
#import <objc/runtime.h>

static NSString * const kViewDataKeyParent = @"parent";
static NSString * const kViewDataKeyChildren = @"children";
static NSInteger kViewDataValueRootParent = -1;

@implementation HSDViewDebugComponent

+ (NSArray *)fetchAllViewsDataInHierarchy {
    NSArray *(^MainThreadBlock)(void) = ^{
        NSMutableArray *allViewsData = [[NSMutableArray alloc] init];
        NSArray *windows = [HSDViewDebugComponent fetchAllWindows];
        for (UIWindow *window in windows) {
            // generate all views data of displayed window
            if (![[self class] viewBaseClassIsHidden:window]) {
                // root view data
                NSMutableDictionary *viewData = [[self fetchViewData:window inWindow:window] mutableCopy];
                [viewData setObject:@(kViewDataValueRootParent) forKey:kViewDataKeyParent];
                [allViewsData addObject:viewData];

                // recursive subviews
                NSInteger viewIndex = [allViewsData count] - 1;
                NSArray *subviewsData = [self allRecursiveSubviewsInView:window viewData:viewData viewIndex:viewIndex inWindow:window];

                [allViewsData addObjectsFromArray:subviewsData];
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

+ (NSArray *)allRecursiveSubviewsInView:(UIView *)view viewData:(NSMutableDictionary *)viewData viewIndex:(NSInteger)viewIndex inWindow:(UIWindow *)window {
    NSMutableArray *subviews = [[NSMutableArray alloc] init];
    for (UIView *subview in view.subviews) {
        // generate data of displayed subview
        if (![[self class] viewBaseClassIsHidden:subview]) {
            // view data
            NSMutableDictionary *subviewData = [[self fetchViewData:subview inWindow:window] mutableCopy];
            [subviewData setObject:@(viewIndex) forKey:kViewDataKeyParent];
            [subviews addObject:subviewData];

            // recursive subviews
            NSInteger currentIndex = viewIndex + [subviews count];
            NSArray *subviewsData = [self allRecursiveSubviewsInView:subview viewData:subviewData viewIndex:currentIndex inWindow:window];

            // update subviewData children
            if (![subviewData objectForKey:kViewDataKeyChildren]) {
                [subviewData setObject:[@[] mutableCopy] forKey:kViewDataKeyChildren];
            }

            // update parent viewData
            NSMutableArray *children = [viewData objectForKey:kViewDataKeyChildren];
            if (!children) {
                children = [@[] mutableCopy];
            }
            [children addObject:@(currentIndex)];
            [viewData setObject:children forKey:kViewDataKeyChildren];

            [subviews addObjectsFromArray:subviewsData];
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
 *  "frame":{"x":"","y":"","width":"","height":""},
 *  "bounds":{"x":"","y":"","width":"","height":""},
 *  "clippedOrigin":{"x":"","y":""}                             // clipped content origin
 *  "clippedFrameRoot":{"x":"","y":"","width":"","height":""},  // clipped content frame in window
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
 *  "parent": 0,            // parent view index in the all views array. For the root, the value is -1
 *  "children": [1, 2, 3],  // subview index in the all view array
 *  }
 */
+ (NSDictionary *)fetchViewData:(UIView *)view inWindow:(UIWindow *)window {
    NSMutableDictionary *viewData = [[NSMutableDictionary alloc] init];
    NSString *description = [[view class] description];
    NSString *className = NSStringFromClass([view class]);
    NSString *memoryAddress = [NSString stringWithFormat:@"%p", view];

    // hierarchyDepth, clippedFrameRoot
    NSInteger hierarchyDepth = 0;
    CGRect tryClippedRect = view.bounds;
    UIView *tryView = view;
    while (tryView.superview) {
        UIView *superview = tryView.superview;
        tryClippedRect = [tryView convertRect:tryClippedRect toView:superview];

        if (!CGSizeEqualToSize(tryClippedRect.size, CGSizeMake(0, 0)) &&
            superview.clipsToBounds) {
            // super view rect
            CGRect baseRect = superview.bounds;

            // clipped
            tryClippedRect = CGRectIntersection(tryClippedRect, baseRect);
            tryClippedRect = CGRectIsNull(tryClippedRect) ? CGRectZero : tryClippedRect;
        }

        tryView = superview;
        hierarchyDepth++;
    }
    CGRect clippedFrameRoot = tryClippedRect;   // frame for clipped view in window
    NSDictionary *clippedFrameRootDict = [self convertCGRect:clippedFrameRoot];

    CGPoint clippedOrigin = [view convertPoint:tryClippedRect.origin fromView:window];   // origin for snapshot clipped view

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
    NSDictionary *positionDict = [self convertCGPoint:position];

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
    [viewData setObject:frameDict forKey:@"frame"];
    [viewData setObject:boundsDict forKey:@"bounds"];
    [viewData setObject:[self convertCGPoint:clippedOrigin] forKey:@"clippedOrigin"];
    [viewData setObject:clippedFrameRootDict forKey:@"clippedFrameRoot"];
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

+ (NSData *)snapshotImageData:(UIView *)view isSubviewsExcluding:(BOOL)isSubviewsExcluding clippedFrame:(CGRect)clippedFrame {
    NSData *(^MainThreadBlock)(void) = ^{
        NSMutableSet *subviews;
        if (isSubviewsExcluding) {
            // hide subviews
            subviews = [[NSMutableSet alloc] init];
            for (UIView *subview in view.subviews) {
                BOOL isHidden = [[self class] viewBaseClassIsHidden:subview];
                if (!isHidden) {
                    // collect
                    [subviews addObject:subview];

                    // hide
                    [[self class] view:subview baseClassSetHidden:YES];
                }
            }
        }

        // get view snapshot
        UIGraphicsBeginImageContextWithOptions(clippedFrame.size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, -clippedFrame.origin.x, -clippedFrame.origin.y);
        [view.layer renderInContext:context];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        if (isSubviewsExcluding) {
            // show subviews
            for (UIView *subview in subviews) {
                [[self class] view:subview baseClassSetHidden:NO];
            }
        }

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

+ (NSDictionary *)convertCGPoint:(CGPoint)origin {
    NSDictionary *dict =
    @{@"x": @(origin.x),
      @"y": @(origin.y)
      };
    return dict;
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
