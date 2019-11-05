//
//  HSDUtility.h
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/11/5.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSDUtility : NSObject

+ (NSArray<NSString *> *)parsePathComponents:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
