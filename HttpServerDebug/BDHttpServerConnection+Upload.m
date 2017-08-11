//
//  BDHttpServerConnection+Upload.m
//  BaiduBrowser
//
//  Created by chenjun on 26/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "BDHttpServerConnection+Upload.h"
#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "BDHttpServerManager.h"

@implementation BDHttpServerConnection (Upload)

- (NSObject<HTTPResponse> *)fetchWebUploadResponse:(NSDictionary *)params forMethod:method URI:path
{
    id response;
    response = [super httpResponseForMethod:method URI:path];
    return response;
}

#pragma mark - MultipartFormDataParserDelegate

- (void)processStartOfPartWithHeader:(MultipartMessageHeader *)header
{
    MultipartMessageHeaderField *disposition = [header.fields objectForKey:@"Content-Disposition"];
    NSString *filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    
    if (filename.length > 0) {
        NSString *uploadDirPath = [BDHttpServerManager fetchWebUploadDirectoryPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:uploadDirPath isDirectory:nil]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *filePath = [uploadDirPath stringByAppendingPathComponent:filename];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        self.storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
}

- (void)processContent:(NSData *)data WithHeader:(MultipartMessageHeader *)header
{
    if (self.storeFile) {
        [self.storeFile writeData:data];
    }
}

- (void)processEndOfPartWithHeader:(MultipartMessageHeader *)header
{
    [self.storeFile closeFile];
    self.storeFile = nil;
}

@end
