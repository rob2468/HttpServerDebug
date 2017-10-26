//
//  BDHttpServerConnection+Preview.m
//  BDPhoneBrowser
//
//  Created by chenjun on 03/08/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "BDHttpServerConnection+Preview.h"
#import "HTTPDataResponse.h"
#import "BDHttpServerUtility.h"

@implementation BDHttpServerConnection (Preview)

- (NSObject<HTTPResponse> *)fetchFilePreviewResponse:(NSDictionary *)params forMethod:(NSString *)method URI:(NSString *)path
{
    BDHttpServerDataResponse *response;
    NSString *contentType = @"text/plain;charset=utf-8";
    if (params) {
        NSString *filePath = [params objectForKey:@"file_path"];
        NSData *data;
        if ([filePath isEqualToString:@"standardUserDefaults"]) {
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
            NSString *str = [dict description];
            data = [str dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            filePath = [filePath stringByRemovingPercentEncoding];
            NSString *extension = filePath.pathExtension;
            
            data = [[NSData alloc] initWithContentsOfFile:filePath];
            contentType = [BDHttpServerUtility fetchContentTypeWithFilePathExtension:extension];
        }
        if (data) {
            response = [[BDHttpServerDataResponse alloc] initWithData:data contentType:contentType];
        }
    }
    if (!response) {
        NSString *prompt = @"文件不存在或不支持预览";
        NSData *data = [prompt dataUsingEncoding:NSUTF8StringEncoding];
        response = [[BDHttpServerDataResponse alloc] initWithData:data contentType:contentType];
    }
    return response;
}

@end
