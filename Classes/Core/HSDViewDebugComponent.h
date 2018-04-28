//
//  HSDViewDebugComponent.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol HTTPResponse;

@interface HSDViewDebugComponent : NSObject

- (NSObject<HTTPResponse> *)fetchViewDebugAPIResponsePaths:(NSArray *)paths parameters:(NSDictionary *)params;

@end
