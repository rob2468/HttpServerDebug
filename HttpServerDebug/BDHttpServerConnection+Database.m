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
#import "HTTPDynamicFileResponse.h"

@implementation BDHttpServerConnection (Database)

- (NSObject<HTTPResponse> *)fetchDatabaseResponse:(NSDictionary *)params
{
    NSObject<HTTPResponse> *response;
    NSString *dbPath = [params objectForKey:@"db_path"];
    NSString *tableName = [params objectForKey:@"table_name"];
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    if (dbPath.length > 0 && [database open]) {
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
        
        NSString *htmlPath = [[config documentRoot] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.html", kBDHttpServerDBInspect]];
        NSDictionary *replacementDict =
        @{@"DB_FILE_PATH": dbPath,
          @"SELECT_HTML": selectHtml,
          @"HEAD_TABLE": headTable,
          @"BODY_TABLE": bodyTable
          };
        response = [[HTTPDynamicFileResponse alloc] initWithFilePath:htmlPath forConnection:self separator:kBDHttpServerTemplateSeparator replacementDictionary:replacementDict];
    }
    return response;
}

@end
