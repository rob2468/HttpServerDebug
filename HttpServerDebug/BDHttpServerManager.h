//
//  BDHttpServerManager.h
//  BaiduBrowser
//
//  Created by chenjun on 07/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDHttpServerManager : NSObject

+ (instancetype)sharedInstance;

+ (BOOL)isHttpServerRunning;

+ (void)startHttpServer;

+ (void)stopHttpServer;

+ (NSString *)fetchServerSite;

+ (NSString *)fetchWebUploadDirectoryPath;

+ (void)updateDatabaseFilePath:(NSString *)path;

+ (NSString *)fetchDatabaseFilePath;

@end
