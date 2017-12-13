//
//  BDHttpServerManager.m
//  BaiduBrowser
//
//  Created by chenjun on 07/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "BDHttpServerManager.h"
#import "HTTPServer.h"
#import "BDHttpServerUtility.h"
#import "BDHttpServerConnection.h"

static NSString *const kHttpServerWebIndexFileName = @"index.html";

@interface BDHttpServerManager ()

@property (strong, nonatomic) HTTPServer *server;
@property (copy, nonatomic) NSString *dbFilePath;   // default inspect db file path

@end

@implementation BDHttpServerManager

- (void)dealloc {
    [self.server stop];
}

+ (instancetype)sharedInstance
{
    static BDHttpServerManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BDHttpServerManager alloc] init];
    });
    return instance;
}

+ (BOOL)isHttpServerRunning
{
    BDHttpServerManager *manager = [BDHttpServerManager sharedInstance];
    HTTPServer *server = manager.server;
    BOOL isRunning = server.isRunning;
    return isRunning;
}

+ (void)startHttpServer:(NSString *)port {
    if ([self isHttpServerRunning]) {
        NSLog(@"http server has already started: %@", [self fetchServerSite]);
        return;
    }
    
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"HttpServerDebug" ofType:@"bundle"];
    NSString *webPath = [resourcePath stringByAppendingPathComponent:@"web"];
    
    BDHttpServerManager *manager = [BDHttpServerManager sharedInstance];
    manager.server = [[HTTPServer alloc] init];
    [manager.server setType:@"_http._tcp."];
    
#ifdef DEBUG
    // develop web in simulator, use files in the project bundle directly
    webPath = @"/Volumes/chenjun_sdcard/workspace/httpserverdebug/HttpServerDebug/Resources/HttpServerDebug.bundle/web";
#endif
    
    [manager.server setDocumentRoot:webPath];
    if (port.length > 0) {
        [manager.server setPort:port.integerValue];
    }
    [manager.server setConnectionClass:[BDHttpServerConnection class]];
    NSError *error;
    BOOL isSucc = [manager.server start:&error];
    
    if (isSucc) {
        NSLog(@"http server started: %@", [self fetchServerSite]);
        NSLog(@"http server root document: %@", webPath);
    } else {
        NSLog(@"Error starting http server: %@", error);
    }
}

+ (void)stopHttpServer
{
    BDHttpServerManager *manager = [BDHttpServerManager sharedInstance];
    [manager.server stop];
    
    NSLog(@"http server stopped");
}

+ (void)updateDefaultInspectDBFilePath:(NSString *)path {
    BDHttpServerManager *manager = [BDHttpServerManager sharedInstance];
    manager.dbFilePath = path;
}

+ (NSString *)fetchDatabaseFilePath {
    return [BDHttpServerManager sharedInstance].dbFilePath;
}

+ (NSString *)fetchServerSite
{
    NSString *localIP = [BDHttpServerUtility fetchLocalIPAddress];
    BDHttpServerManager *manager = [BDHttpServerManager sharedInstance];
    UInt16 port = manager.server.listeningPort;
    NSString *serverSite = [NSString stringWithFormat:@"http://%@:%d", localIP, port];
    return serverSite;
}

+ (NSString *)fetchWebUploadDirectoryPath
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"web_upload"];
    return path;
}

@end
