//
//  HSDDefine.m
//  HttpServerDebug
//
//  Created by chenjun on 22/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "HSDDefine.h"

NSString *const kHSDComponentFileExplorer = @"file_explorer";
NSString *const kHSDComponentDBInspect = @"database_inspect";
NSString *const kHSDComponentSendInfo = @"send_info";
NSString *const kHSDComponentFilePreview = @"file_preview";
NSString *const kHSDComponentViewDebug = @"view_debug";
NSString *const kHSDComponentConsoleLog = @"console_log";

NSString *const kHSDTemplateSeparator = @"%%";

NSString *const kHSDUserDefaultsKeyAutoStart = @"hsd_userdefaultskey_is_started_automatically";
NSString *const kHSDUserDefaultsKeyServerPort = @"hsd_userdefaultskey_server_port";

const UInt16 kHSDServerPortUserSettingMin = 1025;
const UInt16 kHSDServerPostUserSettingMax = 65534;
