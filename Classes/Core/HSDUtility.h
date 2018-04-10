//
//  HSDUtility.h
//  HttpServerDebug
//
//  Created by chenjun on 18/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSDUtility : NSObject

/**
 *  local ip address
 */
+ (NSArray *)fetchLocalAlternateIPAddresses;

/**
 *  Content-Type according to file extension, default return value text/plain;charset=utf-8
 */
+ (NSString *)fetchContentTypeWithFilePathExtension:(NSString *)pathExtension;

@end
