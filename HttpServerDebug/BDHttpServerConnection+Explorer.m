//
//  BDHttpServerConnection+Explorer.m
//  BDPhoneBrowser
//
//  Created by chenjun on 02/08/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "BDHttpServerConnection+Explorer.h"
#import "HTTPDynamicFileResponse.h"
#import "BDHttpServerDefine.h"
#import "BDHttpServerManager.h"

@interface BDHttpServerJSTreeNode : NSObject

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) NSMutableDictionary *state;
@property (nonatomic, strong) NSMutableDictionary *a_attr;
@property (nonatomic, strong) NSMutableArray *children;

@end

@implementation BDHttpServerJSTreeNode

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.data = [[NSMutableDictionary alloc] init];
        self.state = [[NSMutableDictionary alloc] init];
        self.a_attr = [[NSMutableDictionary alloc] init];
        self.children = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSDictionary *)serialize
{
    NSString *ID = self.ID.length > 0? self.ID: @"";
    NSString *text = self.text.length > 0? self.text: @"";
    NSString *icon = self.icon.length > 0? self.icon: @"";
    NSDictionary *data = self.data;
    NSDictionary *state = self.state;
    NSDictionary *a_attr = self.a_attr;
    NSMutableArray *children = [[NSMutableArray alloc] init];
    for (BDHttpServerJSTreeNode *node in self.children) {
        NSDictionary *dict = [node serialize];
        [children addObject:dict];
    }
    NSDictionary *node =
    @{
      @"id": ID,
      @"text": text,
      @"icon": icon,
      @"data": data,
      @"state": state,
      @"a_attr": a_attr,
      @"children": children,
      };
    return node;
}

@end

@implementation BDHttpServerConnection (Explorer)

#pragma mark - Response

- (NSObject<HTTPResponse> *)fetchFileExplorerResponse:(NSDictionary *)params forMethod:(NSString *)method URI:(NSString *)path {
    NSObject<HTTPResponse> *response = [super httpResponseForMethod:method URI:path];
    return response;
}

- (NSObject<HTTPResponse> *)fetchFileExplorerAPIResponsePaths:(NSArray *)paths parameters:(NSDictionary *)params {
    // parse data
    NSString *filePath = [params objectForKey:@"file_path"];
    
    NSArray<NSDictionary *> *itemList = [[NSArray alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (filePath.length == 0) {
        // request root path
        NSString *homeDirectory = NSHomeDirectory();
        NSArray *filesDataList = [self constructFilesDataListInDirectory:homeDirectory];
        itemList = [filesDataList copy];
    } else {
        // request specific file path
        BOOL isDir;
        if ([fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
            if (isDir) {
                NSArray *filesDataList = [self constructFilesDataListInDirectory:filePath];
                itemList = [filesDataList copy];
            } else {
                
            }
        }
    }
    // serialization
    NSData *data = [NSJSONSerialization dataWithJSONObject:itemList options:0 error:nil];
    HTTPDataResponse *response;
    if (data) {
        response = [[HTTPDataResponse alloc] initWithData:data];
    }
    return response;
}

#pragma mark -

/**
 *  enumarate directory and construct json data
 *  @param filePath  the objective directory file path
 *  @return  json data
 */
- (NSArray<NSDictionary *> *)constructFilesDataListInDirectory:(NSString *)filePath {
    NSMutableArray<NSDictionary *> *itemList = [[NSMutableArray alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
    for (NSString *fileName in fileNames) {
        // files in filePath directory
        NSString *subPath = [filePath stringByAppendingPathComponent:fileName];
        BOOL isExist;
        BOOL isDir;
        isExist = [fileManager fileExistsAtPath:subPath isDirectory:&isDir];
        if (isExist) {
            // construct file item
            NSString *tmpFileName = fileName.length > 0 ? fileName : @"";
            subPath = subPath.length > 0 ? subPath : @"";
            NSDictionary *itemDict =
            @{
              @"file_name": tmpFileName,
              @"file_path": subPath,
              @"is_directory": @(isDir)
              };
            [itemList addObject:itemDict];
        }
    }
    return itemList;
}

@end
