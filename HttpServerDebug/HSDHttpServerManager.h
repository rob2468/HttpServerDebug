//
//  HSDHttpServerManager.h
//  HttpServerDebug
//
//  Created by chenjun on 07/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol HSDHttpServerDebugDelegate;

@interface HSDHttpServerManager : NSObject

+ (instancetype)sharedInstance;

+ (BOOL)isHttpServerRunning;

/**
 *  @param port  port number. nil will use random number.
 */
+ (void)startHttpServer:(NSString *)port;

+ (void)stopHttpServer;

+ (NSString *)fetchAlternateServerSites;

+ (NSString *)fetchWebUploadDirectoryPath;

+ (void)updateDefaultInspectDBFilePath:(NSString *)path;

+ (NSString *)fetchDatabaseFilePath;

+ (void)updateHSDDelegate:(id<HSDHttpServerDebugDelegate>)delegate;

+ (id<HSDHttpServerDebugDelegate>)fetchHSDDelegate;

@end
