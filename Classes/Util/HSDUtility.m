//
//  HSDUtility.m
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/11/5.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import "HSDUtility.h"

@implementation HSDUtility

+ (NSArray<NSString *> *)parsePathComponents:(NSString *)path {
    if (path.length == 0) {
        return @[];
    }

    // parse paths
    NSString *p = [path copy];
    if ([p hasPrefix:@"/"]) {
        p = [p substringFromIndex:1];
    }
    if ([p hasSuffix:@"/"]) {
        p = [p substringToIndex:p.length - 1];
    }

    // path components
    NSArray<NSString *> *pathComps = [[NSArray alloc] init];
    if (p.length > 0) {
        pathComps = [p componentsSeparatedByString:@"/"];
    }
    return pathComps;
}

@end
