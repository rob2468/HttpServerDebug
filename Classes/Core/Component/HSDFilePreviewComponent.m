//
//  HSDFilePreviewComponent.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDFilePreviewComponent.h"
#import "ZipArchive.h"

@implementation HSDFilePreviewComponent

+ (NSData *)fetchContentsWithFilePath:(NSString *)filePath {
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
    
    if (isExist) {
        if (isDirectory) {
            // request directory, zip archive directory and response
            if ([[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil].count > 0) {
                NSString *tmpFileName = [NSString stringWithFormat:@"hsd_file_preview_%@", filePath.lastPathComponent];
                NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:tmpFileName];
                [SSZipArchive createZipFileAtPath:tmpPath withContentsOfDirectory:filePath];
                data = [[NSData alloc] initWithContentsOfFile:tmpPath];
                // clean tmp file
                [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
            }
        } else {
            // request file
            data = [[NSData alloc] initWithContentsOfFile:filePath];
        }
    }
    return data;
}

@end
