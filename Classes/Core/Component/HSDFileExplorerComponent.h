//
//  HSDFileExplorerComponent.h
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSDFileExplorerComponent : NSObject

/**
 *  enumarate directory and construct json data
 *  @param filePath  the objective directory file path
 *  @return  json data
 */
+ (NSArray<NSDictionary *> *)constructFilesDataListInDirectory:(NSString *)filePath;

/**
 *  get file attribute
 */
+ (NSDictionary *)constructFileAttribute:(NSString *)filePath;

@end
