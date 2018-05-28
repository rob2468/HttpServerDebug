//
//  HSDHostNameResolveComponent.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDHostNameResolveComponent.h"
#import <arpa/inet.h>

@interface HSDHostNameResolveComponent ()
<NSNetServiceDelegate>

@property (strong, nonatomic) NSNetService *netService; // used to resolve hostname
@property (assign, nonatomic) BOOL isResolving;
@property (strong, nonatomic) HSDHostNameResolveBlock resolveBlock;

@end

@implementation HSDHostNameResolveComponent

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isResolving = NO;
    }
    return self;
}

- (void)resolveHostName:(HSDHostNameResolveBlock)block {
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
        self.resolveBlock(HSDHostNameResolveStateReady, nil, nil);
    }
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    if (self.resolveBlock) {
        NSMutableArray<NSString *> *results = [[NSMutableArray alloc] init];
        NSInteger port = sender.port;

        // parse ip address
        NSArray<NSData *> *addresses = sender.addresses;
        char addressBuffer[INET6_ADDRSTRLEN];
        for (NSData *data in addresses) {
            memset(addressBuffer, 0, INET6_ADDRSTRLEN);
            typedef union {
                struct sockaddr sa;
                struct sockaddr_in ipv4;
                struct sockaddr_in6 ipv6;
            } ip_socket_address;
            
            ip_socket_address *socketAddress = (ip_socket_address *)[data bytes];
            if (socketAddress) {
                sa_family_t saFamily = socketAddress->sa.sa_family;
                if (saFamily == AF_INET) {
                    // filter only ipv4 address
                    void *src = (void *)&(socketAddress->ipv4.sin_addr);
                    const char *addressCStr = inet_ntop(saFamily, src, addressBuffer, sizeof(addressBuffer));
                    NSString *addressStr = [[NSString alloc] initWithCString:addressCStr encoding:NSUTF8StringEncoding];
                    if (addressStr.length > 0) {
                        NSString *tmp = [[NSString alloc] initWithFormat:@"http://%@:%ld", addressStr, (long)port];
                        [results addObject:tmp];
                    }
                }
            }
        }
        // parse host name
        NSString *hostName = sender.hostName;
        if (hostName.length > 0) {
            NSString *tmp = [[NSString alloc] initWithFormat:@"http://%@:%ld", hostName, (long)port];
            [results addObject:tmp];
        }
        self.resolveBlock(HSDHostNameResolveStateSuccess, results, nil);
    }
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    if (self.resolveBlock) {
        self.resolveBlock(HSDHostNameResolveStateFail, nil, errorDict);
    }
    [sender stop];
}

- (void)netServiceDidStop:(NSNetService *)sender {
    self.isResolving = NO;
    if (self.resolveBlock) {
        self.resolveBlock(HSDHostNameResolveStateStop, nil, nil);
    }
    
    self.netService = nil;
}

@end
