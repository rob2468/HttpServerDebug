//
//  HSDWebDebugDomainDOM.m
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/11/5.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import "HSDWebDebugDomainDOM.h"

@interface HSDWebDebugDomainDOM()

@end

@implementation HSDWebDebugDomainDOM

- (void)handleMethodWithName:(NSString *)methodName parameters:(NSDictionary *)params responseCallback:(void(^)(NSDictionary *result, NSError *error))responseCallback {
    NSDictionary *result = nil;
    if ([methodName isEqualToString:@"getDocument"]) {
        NSString *a = @"/Users/jam/Desktop/workspace/ios-app/HttpServerDebug/Resources/HttpServerDebug.bundle/data.json";
        NSData *d = [[NSData alloc] initWithContentsOfFile:a];
        NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
        result = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
        result = [result objectForKey:@"result"];
    }
    if (responseCallback) {
        responseCallback(result, nil);
    }
}

@end
