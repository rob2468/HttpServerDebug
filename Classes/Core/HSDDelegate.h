//
//  HSDDelegate.h
//  HttpServerDebug
//
//  Created by chenjun on 2017/12/26.
//  Copyright © 2017年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HSDDelegate <NSObject>

@optional

/**
 *  send information to app
 *  @param info  information
 *  @return results, returned in response data
 */
- (NSDictionary *)onHSDReceiveInfo:(NSString *)info;

@end
