//
//  HSDManager+Private.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDManager.h"
@class HSDConsoleLogComponent;
@class HSDHostNameResolveComponent;
@class HSDViewDebugComponent;
@class HSDDBInspectComponent;
@class HSDFileExplorerComponent;
@class HSDSendInfoComponent;
@class HSDFilePreviewComponent;

@interface HSDManager (Private)

+ (void)updateHttpServerName:(NSString *)name;

+ (NSString *)fetchHttpServerName;

+ (NSString *)fetchDefaultInspectDBFilePath;

+ (id<HSDDelegate>)fetchHSDDelegate;

+ (NSString *)fetchWebUploadDirectoryPath;

/**
 *
 */
+ (NSString *)fetchDocumentRoot;

/**
 *  return the HSDConsoleLogComponent singleton instance
 */
+ (HSDConsoleLogComponent *)fetchTheConsoleLogComponent;

/**
 *  return the HSDHostNameResolveComponent singleton instance
 */
+ (HSDHostNameResolveComponent *)fetchTheHostNameResolveComponent;

/**
 *
 */
+ (HSDViewDebugComponent *)fetchTheViewDebugComponent;

/**
 *
 */
+ (HSDDBInspectComponent *)fetchTheDBInspectComponent;

/**
 *
 */
+ (HSDFileExplorerComponent *)fetchTheFileExplorerComponent;

/**
 *
 */
+ (HSDSendInfoComponent *)fetchTheSendInfoComponent;

/**
 *
 */
+ (HSDFilePreviewComponent *)fetchTheFilePreviewComponent;

/**
 *  Content-Type according to file extension, default return value text/plain;charset=utf-8
 */
+ (NSString *)fetchContentTypeWithFilePathExtension:(NSString *)pathExtension;

@end
