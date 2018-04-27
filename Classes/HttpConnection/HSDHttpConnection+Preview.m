//
//  HSDHttpConnection+Preview.m
//  HttpServerDebug
//
//  Created by chenjun on 03/08/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "HSDHttpConnection+Preview.h"
#import "HTTPDataResponse.h"
#import "ZipArchive.h"
#import "HSDManager+Private.h"

@implementation HSDHttpConnection (Preview)

- (NSObject<HTTPResponse> *)fetchFilePreviewResponse:(NSDictionary *)params forMethod:(NSString *)method URI:(NSString *)path
{
    HSDHttpDataResponse *response;
    NSString *contentType = @"text/plain;charset=utf-8";
    NSString *filePath = [params objectForKey:@"file_path"];
    if (filePath.length > 0) {
        filePath = [filePath stringByRemovingPercentEncoding];
        NSData *data;
        if ([filePath isEqualToString:@"standardUserDefaults"]) {
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
            NSString *str = [dict description];
            data = [str dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            // response content type
            NSString *extension = filePath.pathExtension;
            contentType = [HSDManager fetchContentTypeWithFilePathExtension:extension];
            
            // generate response data
            if (![filePath hasPrefix:@"/"]) {
                // relative path, get full path
                NSString *firstPathComp = [[filePath pathComponents] firstObject];
                NSString *remainPath = [filePath substringFromIndex:firstPathComp.length];
                if ([firstPathComp isEqualToString:@"Documents"]) {
                    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                    filePath = [documents stringByAppendingPathComponent:remainPath];
                } else if ([firstPathComp isEqualToString:@"Library"]) {
                    NSString *library = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
                    filePath = [library stringByAppendingPathComponent:remainPath];
                } else if ([firstPathComp isEqualToString:@"tmp"]) {
                    NSString *tmp = NSTemporaryDirectory();
                    filePath = [tmp stringByAppendingPathComponent:remainPath];
                } else {
                    filePath = @"";
                }
            }
            
            // file or directory
            BOOL isDirectory;
            BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];

            if (isExist) {
                if (isDirectory) {
                    // request directory, zip archive directory and response
                    NSString *tmpFileName = [NSString stringWithFormat:@"hsd_file_preview_%@", filePath.lastPathComponent];
                    NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:tmpFileName];
                    ZipArchive *zipFile = [[ZipArchive alloc] init];
                    [zipFile CreateZipFile2:tmpPath];
                    // add
                    [self zip:zipFile baseDirectoryPath:filePath fromDirectoryPath:filePath];
                    [zipFile CloseZipFile2];
                    data = [[NSData alloc] initWithContentsOfFile:tmpPath];
                    // clean tmp file
                    [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
                } else {
                    // request file
                    data = [[NSData alloc] initWithContentsOfFile:filePath];
                }
            }
        }
        if (data) {
            response = [[HSDHttpDataResponse alloc] initWithData:data contentType:contentType];
        }
    }
    if (!response) {
        NSString *prompt = @"文件不存在或不支持预览";
        NSData *data = [prompt dataUsingEncoding:NSUTF8StringEncoding];
        response = [[HSDHttpDataResponse alloc] initWithData:data contentType:contentType];
    }
    return response;
}

- (void)zip:(ZipArchive *)zipFile baseDirectoryPath:(NSString *)basePath fromDirectoryPath:(NSString *)directoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray<NSString *> *fileNames = [fileManager contentsOfDirectoryAtPath:directoryPath error:nil];
    for (NSString *fileName in fileNames) {
        NSString *fullPath = [directoryPath stringByAppendingPathComponent:fileName];
        BOOL isDirectory;
        [fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory];
        if (isDirectory) {
            // zip recursively
            [self zip:zipFile baseDirectoryPath:basePath fromDirectoryPath:fullPath];
        } else {
            NSInteger idx = basePath.length;
            if (![basePath hasSuffix:@"/"]) {
                idx++;
            }
            NSString *newName = [fullPath substringFromIndex:idx];
            [zipFile addFileToZip:fullPath newname:newName];
        }
    }
}

@end
