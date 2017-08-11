//
//  BDHttpServerConnection+Upload.h
//  BaiduBrowser
//
//  Created by chenjun on 26/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "BDHttpServerConnection.h"
@protocol MultipartFormDataParserDelegate;

@interface BDHttpServerConnection (Upload)
<MultipartFormDataParserDelegate>

- (NSObject<HTTPResponse> *)fetchWebUploadResponse:(NSDictionary *)params forMethod:method URI:path;

@end
