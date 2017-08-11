//
//  BDHttpServerConnection+Database.m
//  BaiduBrowser
//
//  Created by chenjun on 26/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "BDHttpServerConnection+Database.h"
#import "HTTPDataResponse.h"
#import "BDHttpServerDefine.h"
#import "FMDB.h"
#import "BDHttpServerManager.h"

@implementation BDHttpServerConnection (Database)

- (NSObject<HTTPResponse> *)fetchDatabaseResponse:(NSDictionary *)params
{
    HTTPDataResponse *response;
    NSString *dbPath = [BDHttpServerManager fetchDatabaseFilePath];
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    NSString *tableName = [params objectForKey:@"table_name"];
    if ([database open]) {
        // 获取所有表
        NSMutableString *selectHtml = [[NSMutableString alloc] initWithString:@"<option></option>"];
        NSString *stat = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type='table';"];
        FMResultSet *rs = [database executeQuery:stat];
        while ([rs next]) {
            NSString *tblName = [rs stringForColumn:@"tbl_name"];
            tblName = tblName.length > 0? tblName: @"";
            NSString *optionHtml = @"<option value='%@' %@>%@</option>";
            if ([tableName isEqualToString:tblName]) {
                optionHtml = [NSString stringWithFormat:optionHtml, tblName, @"selected='selected'", tblName];
            } else {
                optionHtml = [NSString stringWithFormat:optionHtml, tblName, @"", tblName];
            }
            [selectHtml appendString:optionHtml];
        }
        [rs close];
        
        NSMutableString *headTable = [[NSMutableString alloc] initWithString:@""];
        NSMutableString *bodyTable = [[NSMutableString alloc] initWithString:@""];
        if (tableName.length > 0) {
            // 获取字段名
            stat = [NSString stringWithFormat:@"PRAGMA TABLE_INFO(%@)", tableName];
            rs = [database executeQuery:stat];
            while ([rs next]) {
                NSString *fieldName = [rs stringForColumn:@"name"];
                fieldName = fieldName.length > 0? fieldName: @"";
                NSString *fieldHtml = [NSString stringWithFormat:@"<th>%@</th>", fieldName];
                [headTable appendString:fieldHtml];
            }
            [rs close];
            
            // 检索数据条目
            stat = [NSString stringWithFormat:@"SELECT * FROM %@;", tableName];
            rs = [database executeQuery:stat];
            int columnCount = [rs columnCount];
            while ([rs next]) {
                NSMutableString *htmlRow = [[NSMutableString alloc] initWithString:@""];
                for (int i = 0; i < columnCount; i++) {
                    NSString *tmp = [rs stringForColumnIndex:i];
                    tmp = tmp.length > 0? tmp: @"";
                    NSString *htmlField = [NSString stringWithFormat:@"<td>%@</td>", tmp];
                    [htmlRow appendString:htmlField];
                }
                [bodyTable appendString:[NSString stringWithFormat:@"<tr>%@</tr>", htmlRow]];
            }
            [rs close];
        }
        [database close];
        
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"HttpServerDebug" ofType:@"bundle"];
        NSString *webPath = [resourcePath stringByAppendingPathComponent:@"web"];
        NSString *htmlPath = [webPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.html", kBDHttpServerDBInspect]];
        NSString *htmlStr = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
        htmlStr = [NSString stringWithFormat:htmlStr, selectHtml, headTable, bodyTable];
        NSData *htmlData = [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
        response = [[HTTPDataResponse alloc] initWithData:htmlData];
    }
    return response;
}

@end
