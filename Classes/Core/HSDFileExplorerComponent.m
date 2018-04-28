//
//  HSDFileExplorerComponent.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDFileExplorerComponent.h"
#import "HTTPDataResponse.h"

@implementation HSDFileExplorerComponent

#pragma mark - Response

- (NSObject<HTTPResponse> *)fetchFileExplorerAPIResponsePaths:(NSArray *)paths parameters:(NSDictionary *)params {
    // parse data
    NSString *filePath = [params objectForKey:@"file_path"];
    
    id json;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (filePath.length == 0) {
        // request root path
        NSString *homeDirectory = NSHomeDirectory();
        NSArray *filesDataList = [self constructFilesDataListInDirectory:homeDirectory];
        json = [filesDataList copy];
    } else {
        // request specific file path
        BOOL isDir;
        if ([fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
            if (isDir) {
                // directory, construct directory contents
                NSArray *filesDataList = [self constructFilesDataListInDirectory:filePath];
                json = [filesDataList copy];
            } else {
                // normal file, construct file attribute
                NSDictionary<NSFileAttributeKey, id> *attrs = [fileManager attributesOfItemAtPath:filePath error:nil];
                NSString *fileType = [attrs objectForKey:NSFileType];
                NSNumber *fileSize = [attrs objectForKey:NSFileSize];   // unit, Byte
                NSDate *fileModificationDate = [attrs objectForKey:NSFileModificationDate];
                NSDate *fileCreationDate = [attrs objectForKey:NSFileCreationDate];
                
                // file type
                fileType = fileType.length > 0 ? fileType : @"";
                // file size
                NSString *sizeStr;
                long size = fileSize.longValue;
                long KB = 1024;
                long MB = 1024 * 1024;
                long GB = 1024 * 1024 * 1024;
                if (size >= GB) {
                    double num = (size * 1.0f) / GB;
                    sizeStr = [NSString stringWithFormat:@"%.1fGB", num];
                } else if (size >= MB) {
                    double num = (size * 1.0f) / MB;
                    sizeStr = [NSString stringWithFormat:@"%.1fMB", num];
                } else if (size >= KB) {
                    double num = (size * 1.0f) / KB;
                    sizeStr = [NSString stringWithFormat:@"%.1fKB", num];
                } else {
                    sizeStr = [NSString stringWithFormat:@"%ldB", size];
                }
                // file modification date
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy/M/d H:mm"];
                NSString *modificationTime = @"";
                if (fileModificationDate) {
                    modificationTime = [dateFormatter stringFromDate:fileModificationDate];
                }
                // file creation date
                NSString *creationTime = @"";
                if (fileCreationDate) {
                    creationTime = [dateFormatter stringFromDate:fileCreationDate];
                }
                json =
                @{
                  @"file_type": fileType,
                  @"file_size": sizeStr,
                  @"modification_time": modificationTime,
                  @"creation_time": creationTime
                  };
            }
        }
    }
    // serialization
    NSData *data;
    if (json) {
        data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    }
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
