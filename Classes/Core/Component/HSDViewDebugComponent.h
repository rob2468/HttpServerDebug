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
 */
+ (NSData *)fetchViewSnapshotImageData:(UIView *)view;

@end
