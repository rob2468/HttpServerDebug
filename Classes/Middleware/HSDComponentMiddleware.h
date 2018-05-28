//
//  HSDComponentMiddleware.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/5/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol HTTPResponse;

@interface HSDComponentMiddleware : NSObject

#pragma mark - View Debug

+ (NSObject<HTTPResponse> *)fetchViewDebugAPIResponsePaths:(NSArray *)paths parameters:(NSDictionary *)params;

@end
