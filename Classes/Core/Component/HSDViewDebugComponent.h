//
//  HSDViewDebugComponent.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HSDViewDebugComponent : NSObject

/**
 *  get all views data
 */
+ (NSArray *)fetchAllViewsDataInHierarchy;

/**
 *  get snapshot
 *  @param view  target view
 *  @param isSubviewsExcluding  snapshot target view with or without subviews
 */
+ (NSData *)snapshotImageData:(UIView *)view isSubviewsExcluding:(BOOL)isSubviewsExcluding clippedFrame:(CGRect)clippedFrame;

+ (NSArray<UIWindow *> *)fetchAllWindows;

@end
