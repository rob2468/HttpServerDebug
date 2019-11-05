//
//  HSDDefine.h
//  HttpServerDebug
//
//  Created by chenjun on 22/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// http request path
extern NSString *const kHSDComponentFileExplorer;
extern NSString *const kHSDComponentDBInspect;
extern NSString *const kHSDComponentSendInfo;
extern NSString *const kHSDComponentFilePreview;
extern NSString *const kHSDComponentViewDebug;
extern NSString *const kHSDComponentConsoleLog;
extern NSString *const kHSDComponentWebDebug;

extern NSString *const kHSDMarkFormatString;            // mark format strings
extern NSString *const kHSDMarkLocalizationString;      // mark localization strings

extern NSString *const kHSDUserDefaultsKeyAutoStart;    // should hsd start automatically
extern NSString *const kHSDUserDefaultsKeyServerPort;   // server port

// user setting max and min port number
extern const UInt16 kHSDServerPortUserSettingMin;
extern const UInt16 kHSDServerPostUserSettingMax;
