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

+ (NSArray *)fetchAllViewsDataInHierarchy;

+ (NSData *)fetchViewSnapshotImageData:(UIView *)view;

@end
