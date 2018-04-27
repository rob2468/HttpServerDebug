//
//  HSDHostNameResolveController.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDHostNameResolveController.h"

@interface HSDHostNameResolveController ()
<NSNetServiceDelegate>

@property (strong, nonatomic) NSNetService *netService; // used to resolve hostname
@property (assign, nonatomic) BOOL isResolving;
@property (strong, nonatomic) HostNameResolveBlock resolveBlock;

@end

@implementation HSDHostNameResolveController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isResolving = NO;
    }
    return self;
}

- (void)resolveHostName:(HostNameResolveBlock)block {
    if (self.isResolving) {
        [self.netService stop];
    }
    self.resolveBlock = block;
    
    NSString *name = [HSDManager fetchHttpServerName];
    self.netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_http._tcp" name:name];
    self.netService.delegate = self;
    [self.netService resolveWithTimeout:5];
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceWillResolve:(NSNetService *)sender {
    self.isResolving = YES;
    if (self.resolveBlock) {
        self.resolveBlock(HostNameResolveStateReady, nil, nil);
    }
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    if (self.resolveBlock) {
        NSString *res;
        NSString *hostName = sender.hostName;
        if (hostName.length > 0) {
            NSInteger port = sender.port;
            res = [NSString stringWithFormat:@"http://%@:%ld", hostName, (long)port];
        }
        self.resolveBlock(HostNameResolveStateSuccess, res, nil);
    }
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    if (self.resolveBlock) {
        self.resolveBlock(HostNameResolveStateFail, nil, errorDict);
    }
    [sender stop];
}

- (void)netServiceDidStop:(NSNetService *)sender {
    self.isResolving = NO;
    if (self.resolveBlock) {
        self.resolveBlock(HostNameResolveStateStop, nil, nil);
    }
    
    self.netService = nil;
}

@end
