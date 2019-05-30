//
//  HSDWebSocket.m
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/4/17.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import "HSDWebSocket.h"

@implementation HSDWebSocket

+ (BOOL)isWebSocketRequest:(NSDictionary *)requestHeaders {
    // Request (Draft 75):
    //
    // GET /demo HTTP/1.1
    // Upgrade: WebSocket
    // Connection: Upgrade
    // Host: example.com
    // Origin: http://example.com
    // WebSocket-Protocol: sample
    //
    //
    // Request (Draft 76):
    //
    // GET /demo HTTP/1.1
    // Upgrade: WebSocket
    // Connection: Upgrade
    // Host: example.com
    // Origin: http://example.com
    // Sec-WebSocket-Protocol: sample
    // Sec-WebSocket-Key1: 4 @1  46546xW%0l 1 5
    // Sec-WebSocket-Key2: 12998 5 Y3 1  .P00
    //
    // ^n:ds[4U

    // Look for Upgrade: and Connection: headers.
    // If we find them, and they have the proper value,
    // we can safely assume this is a websocket request.

    NSString *upgradeHeaderValue = [requestHeaders objectForKey:@"Upgrade"];
    NSString *connectionHeaderValue = [requestHeaders objectForKey:@"Connection"];

    BOOL isWebSocket = YES;

    if (!upgradeHeaderValue || !connectionHeaderValue) {
        isWebSocket = NO;
    } else if ([upgradeHeaderValue caseInsensitiveCompare:@"WebSocket"] != NSOrderedSame) {
        isWebSocket = NO;
    } else if ([connectionHeaderValue rangeOfString:@"Upgrade" options:NSCaseInsensitiveSearch].location == NSNotFound) {
        isWebSocket = NO;
    }
    return isWebSocket;
}

@end
