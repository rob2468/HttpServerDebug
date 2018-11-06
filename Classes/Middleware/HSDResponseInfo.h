//
//  HSDResponseInfo.h
//  HttpServerDebug
//
//  Created by 陈军 on 2018/11/5.
//  Copyright © 2018 chenjun. All rights reserved.
//
//  http server framework independent data model, representing http response information

#import <Foundation/Foundation.h>

@interface HSDResponseInfo : NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy) NSString *contentType;

- (instancetype)init;

@end
