//
//  HSDHttpServerManager.m
//  HttpServerDebug
//
//  Created by chenjun on 07/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "HSDManager.h"
#import "HSDDelegate.h"
#import "HSDDefine.h"
#import "HSDHostNameResolveComponent.h"
#import "HSDGWebServer.h"
#import "HSDGWebServerRequest.h"
#import "HSDGWebServerDataRequest.h"
#import "HSDGWebServerMultiPartFormRequest.h"
#import "HSDGWebServerResponse.h"
#import "HSDGWebServerHTTPStatusCodes.h"
#import "HSDRequestHandler.h"
#import "HSDWebSocketHandler.h"

NSString *kHSDNotificationServerStarted = @"kHSDNotificationServerStarted";
NSString *kHSDNotificationServerStopped = @"kHSDNotificationServerStopped";
static NSString *const kHttpServerWebIndexFileName = @"index.html";
static NSUInteger kHttpServerPortDefault = 0;

@interface HSDManager ()

@property (nonatomic, strong) HSDGWebServer *server;
@property (nonatomic, copy) NSString *dbFilePath;       // default inspect db file path
@property (nonatomic, assign) NSUInteger serverPort;        // serverPort
@property (nonatomic, copy) NSString *serverName;
@property (nonatomic, weak) id<HSDDelegate> delegate;
@property (nonatomic, strong) HSDHostNameResolveComponent *hostNameResolveComponent;

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

- (instancetype)init {
    self = [super init];
    if (self) {
        self.serverPort = kHttpServerPortDefault;
        self.serverName = @"";
    }
    return self;
}

+ (void)updateHttpServerPort:(NSUInteger)port {
    HSDManager *manager = [HSDManager sharedInstance];
    manager.serverPort = port;
}

+ (NSUInteger)fetchHttpServerPort {
    NSUInteger port = kHttpServerPortDefault;
    if ([HSDManager isHttpServerRunning]) {
        HSDManager *manager = [HSDManager sharedInstance];
        port = manager.server.port;
    }
    return port;
}

+ (void)updateHttpServerName:(NSString *)name {
    HSDManager *manager = [HSDManager sharedInstance];
    manager.serverName = name;
}

+ (NSString *)fetchHttpServerName {
    HSDManager *manager = [HSDManager sharedInstance];
    HSDGWebServer *server = manager.server;
    NSString *serviceName = server.bonjourName;
    return serviceName;
}

+ (BOOL)isHttpServerRunning {
    HSDManager *manager = [HSDManager sharedInstance];
    HSDGWebServer *server = manager.server;
    BOOL isRunning = server.isRunning;
    return isRunning;
}

+ (void)startHttpServer {
    if ([self isHttpServerRunning]) {
        NSLog(@"http server has already started.");
        return;
    }

    HSDManager *manager = [HSDManager sharedInstance];
    HSDGWebServer *server = [[HSDGWebServer alloc] init];

    // set http server parameters
    // add handler
    [server addHandlerWithMatchBlock:^HSDGWebServerRequest * _Nullable(NSString * _Nonnull requestMethod, NSURL * _Nonnull requestURL, NSDictionary * _Nonnull requestHeaders, NSString * _Nonnull urlPath, NSDictionary * _Nonnull urlQuery) {
        HSDGWebServerRequest *request;
        if ([requestMethod isEqualToString:@"POST"]) {
            NSString *action = [urlQuery objectForKey:@"action"];
            if ([action isEqualToString:@"upload"]) {
                request = [[HSDGWebServerMultiPartFormRequest alloc] initWithMethod:requestMethod url:requestURL headers:requestHeaders path:urlPath query:urlQuery];
            }

            if (!request) {
                request = [[HSDGWebServerDataRequest alloc] initWithMethod:requestMethod url:requestURL headers:requestHeaders path:urlPath query:urlQuery];
            }
        }

        if (!request) {
            // generic request
            request = [[HSDGWebServerRequest alloc] initWithMethod:requestMethod url:requestURL headers:requestHeaders path:urlPath query:urlQuery];
        }
        return request;
    } asyncProcessBlock:^(__kindof HSDGWebServerRequest * _Nonnull request, HSDGWebServerCompletionBlock  _Nonnull completionBlock) {
        HSDGWebServerResponse *response;
        response = [HSDRequestHandler handleRequest:request];
        if (completionBlock) {
            completionBlock(response);
        }
    }];

    // add WebSocket handler
    [server setWebSocketHandlerClassWithBlock:^Class _Nullable{
        return [HSDWebSocketHandler class];
    }];

    // port
    NSUInteger port;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults valueForKey:kHSDUserDefaultsKeyServerPort]) {
        // user setting value exists
        port = [userDefaults integerForKey:kHSDUserDefaultsKeyServerPort];
    } else {
        // method calling value
        port = manager.serverPort;
    }
    if (port < kHSDServerPortUserSettingMin || port > kHSDServerPostUserSettingMax) {
        port = kHttpServerPortDefault;
    }

    // bonjour name
    NSString *bonjourName = manager.serverName;

    // server log level
    [HSDGWebServer setLogLevel:4];

    // start server
    BOOL isSucc = [server startWithPort:port bonjourName:bonjourName];
    manager.server = server;

    if (isSucc) {
        // post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kHSDNotificationServerStarted object:nil];
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
    // front-end resources
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"HttpServerDebug" ofType:@"bundle"];
    NSString *documentRoot = [resourcePath stringByAppendingPathComponent:@"web"];
#ifdef DEBUG
    // develop web in simulator, use files in the project bundle directly
//    documentRoot = @"/Volumes/chenjun_sdcard/workspace/HttpServerDebug/Resources/HttpServerDebug.bundle/web";
#endif
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:documentRoot], @"root document not exist");
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
    
    NSString *contentType = @"text/plain;charset=utf-8";    // default Content-Type
    if ([pathExtension isEqualToString:@"html"]) {
        contentType = @"text/html";
    } else if ([pathExtension isEqualToString:@"js"]) {
        contentType = @"text/javascript";
    } else if ([pathExtension isEqualToString:@"css"]) {
        contentType = @"text/css";
    } else if ([pathExtension isEqualToString:@"png"]) {
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

+ (id)instanceOfMemoryAddress:(NSString *)memoryAddress {
    id obj;
    if (memoryAddress.length > 0) {
        unsigned long long addressPtr = ULONG_LONG_MAX;
        [[NSScanner scannerWithString:memoryAddress] scanHexLongLong:&addressPtr];

        if (addressPtr != ULONG_LONG_MAX) {
            // get oc object according to memory address
            void *rawObj = (void *)(intptr_t)addressPtr;
            obj = (__bridge id)rawObj;
        }
    }
    return obj;
}

@end
