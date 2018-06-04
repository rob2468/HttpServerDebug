//
//  HSDFilePreviewComponent.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSDFilePreviewComponent : NSObject

/**
 *
 */
+ (NSData *)fetchContentsWithFilePath:(NSString *)filePath;

@end
