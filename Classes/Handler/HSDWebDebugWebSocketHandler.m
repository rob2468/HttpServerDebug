//
//  HSDWebDebugWebSocketHandler.m
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/11/5.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import "HSDWebDebugWebSocketHandler.h"
#import "HSDComponentMiddleware.h"
#import "HSDWebDebugDomainBrowser.h"
#import "HSDWebDebugDomainNetwork.h"
#import "HSDWebDebugDomainDOM.h"
#import "HSDWebDebugDomainPage.h"
#import "HSDWebDebugDomainTarget.h"
#import "HSDWebDebugDomain.h"

@interface HSDWebDebugWebSocketHandler()

@property (nonatomic, strong) NSDictionary *webDebugDomains;    // key: domain name, value: handler instance

@end

@implementation HSDWebDebugWebSocketHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        self.webDebugDomains = @{
            @"Browser": [[HSDWebDebugDomainBrowser alloc] init],
            @"Network": [[HSDWebDebugDomainNetwork alloc] init],
            @"DOM": [[HSDWebDebugDomainDOM alloc] init],
            @"Page": [[HSDWebDebugDomainPage alloc] init],
            @"Target": [[HSDWebDebugDomainTarget alloc] init],
        };
    }
    return self;
}

/**
 * websocket did open
 */
- (void)didOpen:(NSString *)requestPath {

}

- (void)didReceiveMessage:(NSString *)msg {
    NSLog(@"HSDWEBSOCKET: didReceiveMessage: \n%@", msg);

    // parse received data
    NSDictionary *msgDict = [NSJSONSerialization JSONObjectWithData:[msg dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSString *fullMethodName = [msgDict objectForKey:@"method"];
    NSArray *components = [fullMethodName componentsSeparatedByString:@"."];
    NSString *domainName;
    NSString *methodName;
    if ([components count] >= 2) {
        domainName = [components objectAtIndex:0];
        methodName = [components objectAtIndex:1];
    }
    NSString *objectID = [msgDict objectForKey:@"id"];

    // get handler
    HSDWebDebugDomain *handler = nil;
    if (domainName.length > 0) {
        handler = [self.webDebugDomains objectForKey:domainName];
    }

    // callback
    void (^responseCallback)(NSDictionary *result, NSError *error) = ^(NSDictionary *result, NSError *error) {
        // assemble data
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        [response setObject:objectID forKey:@"id"];
        if (result) {
            [response setObject:result forKey:@"result"];
        }
        [response setObject:[NSNull null] forKey:@"error"];
        NSLog(@"request: \n%@ \nresponse: \n%@", msgDict, response);

        // serialization
        NSData *data = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
        NSString *encodedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self sendMessage:encodedData];
    };

    if (handler) {
        // handle received data
        [handler handleMethodWithName:methodName parameters:[msgDict objectForKey:@"params"] responseCallback:responseCallback];
    } else {
        responseCallback(nil, nil);
    }
}

- (void)didClose {

}

@end
