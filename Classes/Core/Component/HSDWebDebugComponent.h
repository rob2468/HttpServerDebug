//
//  HSDWebDebugComponent.h
//  HttpServerDebug
//
//  Created by jam.chenjun on 2019/12/1.
//  Copyright © 2019 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HSDWebDebugWebViewInfo;

@interface HSDWebDebugComponent : NSObject

- (NSArray<HSDWebDebugWebViewInfo *> *)allWebViewInfo;

@end

@interface HSDWebDebugWebViewInfo : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;

@end
