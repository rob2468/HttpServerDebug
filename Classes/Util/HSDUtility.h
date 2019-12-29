//
//  HSDUtility.h
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/11/5.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSDUtility : NSObject

+ (NSArray<NSString *> *)parsePathComponents:(NSString *)path;

@end

#ifdef DEBUG
#define HSD_LOG_DEBUG(fmt, ...) NSLog(@"[HSD]:" fmt, ##__VA_ARGS__);
#else
#define HSD_LOG_DEBUG(fmt, ...);
#endif
