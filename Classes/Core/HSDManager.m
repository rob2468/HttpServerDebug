//
//  HSDHttpServerManager.m
//  HttpServerDebug
//
//  Created by chenjun on 07/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "HSDManager.h"
#import "HTTPServer.h"
#import "HSDUtility.h"
#import "HSDHttpConnection.h"
#import "HSDDelegate.h"
#import "HSDConsoleLogController.h"
#import <UIKit/UIKit.h>
#import "HSDDefine.h"

static NSString *const kHttpServerWebIndexFileName = @"index.html";

@interface HSDManager ()

@property (strong, nonatomic) HTTPServer *server;
@property (copy, nonatomic) NSString *dbFilePath;   // default inspect db file path
@property (copy, nonatomic) NSString *serverPort;
@property (weak, nonatomic) id<HSDDelegate> delegate;
@property (nonatomic, strong) HSDConsoleLogController *consoleLogController;

@end

@implementation HSDManager

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

+ (void)applicationDidFinishLaunching:(NSNotification *)notification {
    BOOL isAutoStart = [[NSUserDefaults standardUserDefaults] boolForKey:kHSDUserDefaultsKeyAutoStart];
    if (isAutoStart) {
        if (![self isHttpServerRunning]) {
            [self startHttpServer];
        }
    }
}

- (void)dealloc {
    [self.server stop];
}

+ (instancetype)sharedInstance {
    static HSDManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HSDManager alloc] init];
    });
    return instance;
}

+ (void)updateHttpServerPort:(NSString *)port {
    HSDManager *manager = [HSDManager sharedInstance];
    manager.serverPort = port;
}

+ (BOOL)isHttpServerRunning {
    HSDManager *manager = [HSDManager sharedInstance];
    HTTPServer *server = manager.server;
    BOOL isRunning = server.isRunning;
    return isRunning;
}

+ (void)startHttpServer {
    if ([self isHttpServerRunning]) {
        NSLog(@"http server has already started: %@", [self fetchAlternateServerSites]);
        return;
    }
    
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"HttpServerDebug" ofType:@"bundle"];
    NSString *webPath = [resourcePath stringByAppendingPathComponent:@"web"];
    
    HSDManager *manager = [HSDManager sharedInstance];
    HTTPServer *server = [[HTTPServer alloc] init];
    manager.server = server;
    [manager.server setType:@"_http._tcp."];
    
#ifdef DEBUG
    // develop web in simulator, use files in the project bundle directly
    webPath = @"/Volumes/chenjun_sdcard/workspace/httpserverdebug/Resources/HttpServerDebug.bundle/web";
#endif
    
    [manager.server setDocumentRoot:webPath];
    NSString *port = manager.serverPort;
    if (port.length > 0) {
        [manager.server setPort:port.integerValue];
    }
    [manager.server setConnectionClass:[HSDHttpConnection class]];
    NSError *error;
    BOOL isSucc = [manager.server start:&error];
    
    if (isSucc) {
        NSLog(@"http server started:\n%@", [self fetchAlternateServerSites]);
        NSLog(@"http server root document: %@", webPath);
    } else {
        NSLog(@"Error starting http server: %@", error);
    }
}

+ (void)stopHttpServer {
    HSDManager *manager = [HSDManager sharedInstance];
    [manager.server stop];
    manager.server = nil;
    
    NSLog(@"http server stopped");
}

+ (void)updateDefaultInspectDBFilePath:(NSString *)path {
    HSDManager *manager = [HSDManager sharedInstance];
    manager.dbFilePath = path;
}

+ (NSString *)fetchDefaultInspectDBFilePath {
    return [HSDManager sharedInstance].dbFilePath;
}

+ (void)updateHSDDelegate:(id<HSDDelegate>)delegate {
    HSDManager *manager = [HSDManager sharedInstance];
    manager.delegate = delegate;
}

+ (id<HSDDelegate>)fetchHSDDelegate {
    HSDManager *manager = [HSDManager sharedInstance];
    return manager.delegate;
}

+ (NSString *)fetchAlternateServerSites {
    NSArray *ipAddresses = [HSDUtility fetchLocalAlternateIPAddresses];
    HSDManager *manager = [HSDManager sharedInstance];
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

+ (NSString *)fetchWebUploadDirectoryPath {
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"web_upload"];
    return path;
}

+ (HSDConsoleLogController *)fetchTheConsoleLogController {
    HSDManager *manager = [HSDManager sharedInstance];
    HSDConsoleLogController *ctrl = manager.consoleLogController;
    if (!ctrl) {
        ctrl = [[HSDConsoleLogController alloc] init];
        manager.consoleLogController = ctrl;
    }
    return ctrl;
}

@end
