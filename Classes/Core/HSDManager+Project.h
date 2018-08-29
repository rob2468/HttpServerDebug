//
//  HSDManager+Project.h
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

@interface HSDManager (Project)

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
 *  Content-Type according to file extension, default return value text/plain;charset=utf-8
 */
+ (NSString *)fetchContentTypeWithFilePathExtension:(NSString *)pathExtension;

/**
 *  get the object of one specific memory address
 */
+ (id)instanceOfMemoryAddress:(NSString *)memoryAddress;

@end
