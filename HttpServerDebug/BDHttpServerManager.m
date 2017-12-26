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
#import "BDHttpServerDebugDelegate.h"

static NSString *const kHttpServerWebIndexFileName = @"index.html";

@interface BDHttpServerManager ()

@property (strong, nonatomic) HTTPServer *server;
@property (copy, nonatomic) NSString *dbFilePath;   // default inspect db file path
@property (weak, nonatomic) id<BDHttpServerDebugDelegate> delegate;

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
        NSLog(@"http server has already started: %@", [self fetchAlternateServerSites]);
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
        NSLog(@"http server started:\n%@", [self fetchAlternateServerSites]);
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

+ (void)updateHSDDelegate:(id<BDHttpServerDebugDelegate>)delegate {
    BDHttpServerManager *manager = [BDHttpServerManager sharedInstance];
    manager.delegate = delegate;
}

+ (id<BDHttpServerDebugDelegate>)fetchHSDDelegate {
    BDHttpServerManager *manager = [BDHttpServerManager sharedInstance];
    return manager.delegate;
}

+ (NSString *)fetchAlternateServerSites
{
    NSArray *ipAddresses = [BDHttpServerUtility fetchLocalAlternateIPAddresses];
    BDHttpServerManager *manager = [BDHttpServerManager sharedInstance];
    UInt16 port = manager.server.listeningPort;
    
    NSString *serverSites = @"";
    if ([ipAddresses count] > 0) {
        serverSites = [NSString stringWithFormat:@"http://%@:%d", ipAddresses.firstObject, port];
        for (NSUInteger i = 1; i < [ipAddresses count]; i++) {
            NSString *tmp = [NSString stringWithFormat:@"\nhttp://%@:%d", [ipAddresses objectAtIndex:i], port];
            serverSites = [serverSites stringByAppendingString:tmp];
        }
    }
    
    return serverSites;
}

+ (NSString *)fetchWebUploadDirectoryPath
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"web_upload"];
    return path;
}

@end
