//
//  HSDFilePreviewComponent.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDFilePreviewComponent.h"
#import "HSDZipArchive.h"
#import "HSDManager+Private.h"

@implementation HSDFilePreviewComponent

+ (NSData *)fetchContentsWithFilePath:(NSString *)filePath contentType:(NSString **)contentType {
    NSData *data;
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
    
    NSString *fileContentType;

    if (isExist) {
        if (isDirectory) {
            // request directory, zip archive directory and response
            NSString *tmpFileName = [NSString stringWithFormat:@"hsd_file_preview_%@.zip", filePath.lastPathComponent];
            NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:tmpFileName];
            [HSDZipArchive createZipFileAtPath:tmpPath withContentsOfDirectory:filePath keepParentDirectory:YES];
            data = [[NSData alloc] initWithContentsOfFile:tmpPath];

            // content type
            NSString *fileExtension = tmpPath.pathExtension;
            fileContentType = [HSDManager fetchContentTypeWithFilePathExtension:fileExtension];

            // clean tmp file
            [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
        } else {
            // request file
            data = [[NSData alloc] initWithContentsOfFile:filePath];
            
            // content type
            NSString *fileExtension = filePath.pathExtension;
            fileContentType = [HSDManager fetchContentTypeWithFilePathExtension:fileExtension];
        }
    }
    *contentType = fileContentType;
    return data;
}

@end
