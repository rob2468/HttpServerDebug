//
//  HSDHttpServerUtility.m
//  HttpServerDebug
//
//  Created by chenjun on 18/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "HSDHttpServerUtility.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation HSDHttpServerUtility

+ (NSArray *)fetchLocalAlternateIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    
    NSMutableArray *address = [[NSMutableArray alloc] init];
    for (NSString *key in addresses) {
        NSArray *comps = [key componentsSeparatedByString:@"/"];
        NSString *interface = comps.firstObject;
        NSString *type = comps.lastObject;
        if ([interface hasPrefix:@"en"] && [type isEqualToString:IP_ADDR_IPv4]) {
            [address addObject:[addresses objectForKey:key]];
        }
    }
    return address;
}

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
    }
    return contentType;
}

@end
