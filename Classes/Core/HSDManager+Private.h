//
//  HSDManager+Private.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDManager.h"

@interface HSDManager (Private)

+ (NSString *)fetchDefaultInspectDBFilePath;

+ (id<HSDDelegate>)fetchHSDDelegate;

+ (NSString *)fetchWebUploadDirectoryPath;

/**
 *  return the HSDConsoleLogController instance
 */
+ (HSDConsoleLogController *)fetchTheConsoleLogController;

@end
