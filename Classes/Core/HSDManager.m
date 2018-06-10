//
//  HSDHttpServerManager.m
//  HttpServerDebug
//
//  Created by chenjun on 07/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "HSDManager.h"
#import "HTTPServer.h"
#import "HSDHttpConnection.h"
#import "HSDDelegate.h"
#import <UIKit/UIKit.h>
#import "HSDDefine.h"
#import "HSDHostNameResolveComponent.h"

NSString *kHSDNotificationServerStarted = @"kHSDNotificationServerStarted";
NSString *kHSDNotificationServerStopped = @"kHSDNotificationServerStopped";
static NSString *const kHttpServerWebIndexFileName = @"index.html";

@interface HSDManager ()

@property (strong, nonatomic) HTTPServer *server;
@property (copy, nonatomic) NSString *dbFilePath;   // default inspect db file path
@property (copy, nonatomic) NSString *serverPort;
@property (copy, nonatomic) NSString *serverName;
@property (weak, nonatomic) id<HSDDelegate> delegate;
@property (strong, nonatomic) HSDHostNameResolveComponent *hostNameResolveComponent;

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

+ (int)fetchHttpServerPort {
    int port = 0;
    if ([HSDManager isHttpServerRunning]) {
        HSDManager *manager = [HSDManager sharedInstance];
        port = manager.server.listeningPort;
    }
    return port;
}

+ (void)updateHttpServerName:(NSString *)name {
    HSDManager *manager = [HSDManager sharedInstance];
    manager.serverName = name;
}

+ (NSString *)fetchHttpServerName {
    HSDManager *manager = [HSDManager sharedInstance];
    HTTPServer *server = manager.server;
    NSNetService *netService = [server valueForKey:@"netService"];
    NSString *serviceName = netService.name;
    return serviceName;
}

+ (BOOL)isHttpServerRunning {
    HSDManager *manager = [HSDManager sharedInstance];
    HTTPServer *server = manager.server;
    BOOL isRunning = server.isRunning;
    return isRunning;
}

+ (void)startHttpServer {
    if ([self isHttpServerRunning]) {
        NSLog(@"http server has already started.");
        return;
    }
    
    // front-end resources
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"HttpServerDebug" ofType:@"bundle"];
    NSString *webPath = [resourcePath stringByAppendingPathComponent:@"web"];
#ifdef DEBUG
    // develop web in simulator, use files in the project bundle directly
//    webPath = @"/Volumes/chenjun_sdcard/workspace/HttpServerDebug/Resources/HttpServerDebug.bundle/web";
#endif

    // set http server parameters
    HSDManager *manager = [HSDManager sharedInstance];
    HTTPServer *server = [[HTTPServer alloc] init];
    manager.server = server;
    [manager.server setType:@"_http._tcp."];
    [manager.server setDocumentRoot:webPath];
    NSString *port = manager.serverPort;
    if (port.length > 0) {
        [manager.server setPort:port.integerValue];
    }
    NSString *name = manager.serverName;
    if (name.length > 0) {
        [manager.server setName:name];
    }
    [manager.server setConnectionClass:[HSDHttpConnection class]];
    
    // start
    NSError *error;
    BOOL isSucc = [manager.server start:&error];
    
    if (isSucc) {
        // post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kHSDNotificationServerStarted object:nil];
        
        NSLog(@"http server start, please access with the device ip address and port %d", [HSDManager fetchHttpServerPort]);
        NSLog(@"http server root document: %@", webPath);
    } else {
        NSLog(@"Error starting http server: %@", error);
    }
}

+ (void)stopHttpServer {
    HSDManager *manager = [HSDManager sharedInstance];
    [manager.server stop];
    manager.server = nil;
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kHSDNotificationServerStopped object:nil];
    
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

+ (void)resolveHostName:(HSDHostNameResolveBlock)block {
    HSDHostNameResolveComponent *component = [HSDManager sharedInstance].hostNameResolveComponent;
    [component resolveHostName:block];
}

+ (NSString *)fetchWebUploadDirectoryPath {
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"web_upload"];
    return path;
}

+ (NSString *)fetchDocumentRoot {
    HSDManager *manager = [HSDManager sharedInstance];
    NSString *documentRoot = [manager.server documentRoot];
    return documentRoot;
}

#pragma mark - Getter

- (HSDHostNameResolveComponent *)hostNameResolveComponent {
    if (!_hostNameResolveComponent) {
        _hostNameResolveComponent = [[HSDHostNameResolveComponent alloc] init];
    }
    return _hostNameResolveComponent;
}

#pragma mark - Utility

+ (NSString *)fetchContentTypeWithFilePathExtension:(NSString *)pathExtension {
    pathExtension = [pathExtension lowercaseString];
    
    NSString *contentType = @"text/plain;charset=utf-8";
    if ([pathExtension isEqualToString:@"png"]) {
        contentType = @"image/png";
    } else if ([pathExtension isEqualToString:@"jpg"] ||
               [pathExtension isEqualToString:@"jpeg"]) {
        contentType = @"image/jpeg";
    } else if ([pathExtension isEqualToString:@"svg"]) {
        contentType = @"image/svg+xml";
    } else if ([pathExtension isEqualToString:@"zip"]) {
        contentType = @"application/zip";
    }
    return contentType;
}

@end
