//
//  HSDManager+Private.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDManager.h"
@class HSDConsoleLogController;
@class HSDHostNameResolveController;

@interface HSDManager (Private)

+ (void)updateHttpServerName:(NSString *)name;

+ (NSString *)fetchHttpServerName;

+ (NSString *)fetchDefaultInspectDBFilePath;

+ (id<HSDDelegate>)fetchHSDDelegate;

+ (NSString *)fetchWebUploadDirectoryPath;

/**
 *  return the HSDConsoleLogController singleton instance
 */
+ (HSDConsoleLogController *)fetchTheConsoleLogController;

/**
 *  return the HSDHostNameResolveController singleton instance
 */
+ (HSDHostNameResolveController *)fetchTheHostNameResolveController;

/**
 *  Content-Type according to file extension, default return value text/plain;charset=utf-8
 */
+ (NSString *)fetchContentTypeWithFilePathExtension:(NSString *)pathExtension;

@end
