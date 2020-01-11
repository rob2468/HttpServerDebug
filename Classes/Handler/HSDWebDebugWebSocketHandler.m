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
#import "HSDWebDebugComponent.h"
#import "HSDUtility.h"

@interface HSDWebDebugWebSocketHandler()

@property (nonatomic, strong) NSNumber *pageId;

@end

@implementation HSDWebDebugWebSocketHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

/**
 * websocket did open
 */
- (void)didOpen:(NSString *)requestPath {
    self.pageId = [NSNumber numberWithInteger:[[requestPath lastPathComponent] integerValue]];
}

- (void)didReceiveMessage:(NSString *)msg {
    HSDDevToolProtocolInfo *devProtocolInfo = [[HSDDevToolProtocolInfo alloc] init];
    devProtocolInfo.pageId = self.pageId;

    // parse received data
    NSDictionary *msgDict = [NSJSONSerialization JSONObjectWithData:[msg dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSString *fullMethodName = [msgDict objectForKey:@"method"];
    NSArray *components = [fullMethodName componentsSeparatedByString:@"."];
    if ([components count] >= 2) {
        devProtocolInfo.domainName = [components objectAtIndex:0];
        devProtocolInfo.methodName = [components objectAtIndex:1];
    }
    NSString *objectId = [msgDict objectForKey:@"id"];
    devProtocolInfo.objectId = objectId;
    devProtocolInfo.params = [msgDict objectForKey:@"params"];

    // callback
    void (^responseCallback)(NSDictionary *result, NSError *error) = ^(NSDictionary *result, NSError *error) {
        // assemble data
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        [response setObject:objectId forKey:@"id"];
        if (result) {
            [response setObject:result forKey:@"result"];
        }
        [response setObject:[NSNull null] forKey:@"error"];
        HSD_LOG_DEBUG(@"[WebDebug][WebSocket]\nrequest:\n%@\nresponse:\n%@", msgDict, response);

        // serialization
        NSData *data = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
        NSString *encodedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self sendMessage:encodedData];
    };

    [HSDComponentMiddleware handleWebDebugDevProtocol:devProtocolInfo parameters:msgDict responseCallback:responseCallback];
}

- (void)didClose {

}

@end
