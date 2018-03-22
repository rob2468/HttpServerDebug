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
    NSMutableArray<NSDictionary *> *itemList = [[NSMutableArray alloc] init];
    if ([params count] == 0) {
        // request root path
        NSString *homeDirectory = NSHomeDirectory();
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:homeDirectory error:nil];
        for (NSString *fileName in fileNames) {
            // files in home directory
            NSString *filePath = [homeDirectory stringByAppendingPathComponent:fileName];
            BOOL isExist;
            BOOL isDir;
            isExist = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
            if (isExist) {
                // construct file item
                NSString *tmpFileName = fileName.length > 0 ? fileName : @"";
                filePath = filePath.length > 0 ? filePath : @"";
                NSDictionary *itemDict =
                @{
                  @"file_name": tmpFileName,
                  @"file_path": filePath,
                  @"is_directory": @(isDir)
                };
                [itemList addObject:itemDict];
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

- (NSArray *)fetchFileSystemTree {
    // 顶级目录
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *tmpPath = NSTemporaryDirectory();
    
    // 构造jstree node
    BDHttpServerJSTreeNode *documentNode = [self createJSTreeNodeWithFilePath:documentPath];
    [documentNode.state setObject:[NSNumber numberWithBool:YES] forKey:@"opened"];
    BDHttpServerJSTreeNode *libraryNode = [self createJSTreeNodeWithFilePath:libraryPath];
    [libraryNode.state setObject:[NSNumber numberWithBool:YES] forKey:@"opened"];
    BDHttpServerJSTreeNode *tmpNode = [self createJSTreeNodeWithFilePath:tmpPath];
    [tmpNode.state setObject:[NSNumber numberWithBool:YES] forKey:@"opened"];
    NSMutableArray *fileSystem = [[NSMutableArray alloc] init];
    [fileSystem addObjectsFromArray:@[[documentNode serialize], [libraryNode serialize], [tmpNode serialize]]];
    return fileSystem;
}

- (BDHttpServerJSTreeNode *)createJSTreeNodeWithFilePath:(NSString *)path {
    BDHttpServerJSTreeNode *node;
    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        path = path.length > 0? path: @"";
        NSString *text = path.lastPathComponent;
        text = text.length > 0? text: @"";
        NSString *href = kBDHttpServerFilePreview;
        href = [href stringByAppendingPathComponent:text];
        href = [href stringByAppendingFormat:@"?file_path=%@", path];
        
        node = [[BDHttpServerJSTreeNode alloc] init];
        node.text = text;
        [node.data setObject:path forKey:@"path"];
        [node.a_attr setObject:href forKey:@"href"];

        if (isDir) {
            NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:path error:nil];
            for (NSString *fileName in fileNames) {
                NSString *subPath = [path stringByAppendingPathComponent:fileName];
                BDHttpServerJSTreeNode *subNode = [self createJSTreeNodeWithFilePath:subPath];
                [node.children addObject:subNode];
            }
            [node.data setObject:[NSNumber numberWithBool:YES] forKey:@"is_directory"];
        } else {
            node.icon = @"jstree-file";
            [node.data setObject:[NSNumber numberWithBool:NO] forKey:@"is_directory"];
        }
    }
    
    return node;
}

@end
