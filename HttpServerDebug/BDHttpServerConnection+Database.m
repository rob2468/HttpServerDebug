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

- (NSObject<HTTPResponse> *)fetchDatabaseHTMLResponse:(NSDictionary *)params {
    NSObject<HTTPResponse> *response;
    NSString *dbPath = [params objectForKey:@"db_path"];
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    if (dbPath.length > 0 && [database open]) {
        // all tables
        NSMutableString *selectHtml = [[NSMutableString alloc] init];
        NSString *stat = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type='table';"];
        FMResultSet *rs = [database executeQuery:stat];
        while ([rs next]) {
            NSString *tblName = [rs stringForColumn:@"tbl_name"];
            tblName = tblName.length > 0? tblName: @"";
            NSString *optionHtml = @"<option value='%@' %@>%@</option>";
            if (selectHtml.length == 0) {
                // default select first table
                optionHtml = [NSString stringWithFormat:optionHtml, tblName, @"selected='selected'", tblName];
            } else {
                optionHtml = [NSString stringWithFormat:optionHtml, tblName, @"", tblName];
            }
            [selectHtml appendString:optionHtml];
        }
        [rs close];
        [database close];
        
        NSString *htmlPath = [[config documentRoot] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.html", kBDHttpServerDBInspect]];
        NSDictionary *replacementDict =
        @{@"DB_FILE_PATH": dbPath,
          @"SELECT_HTML": selectHtml
          };
        response = [[HTTPDynamicFileResponse alloc] initWithFilePath:htmlPath forConnection:self separator:kBDHttpServerTemplateSeparator replacementDictionary:replacementDict];
    }
    return response;
}

- (NSObject<HTTPResponse> *)fetchDatabaseAPIResponse:(NSDictionary *)params {
    NSString *dbPath = [params objectForKey:@"db_path"];
    NSString *tableName = [params objectForKey:@"table_name"];
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    NSMutableArray *allData = [[NSMutableArray alloc] init];
    if (dbPath.length > 0 && tableName.length > 0 && [database open]) {
        NSMutableArray *record = [[NSMutableArray alloc] init];
        // field names
        NSString *stat = [NSString stringWithFormat:@"PRAGMA TABLE_INFO(%@)", tableName];
        FMResultSet *rs = [database executeQuery:stat];
        while ([rs next]) {
            NSString *fieldName = [rs stringForColumn:@"name"];
            fieldName = fieldName.length > 0? fieldName: @"";
            [record addObject:fieldName];
        }
        [rs close];
        [allData addObject:record];
        
        // query data
        stat = [NSString stringWithFormat:@"SELECT * FROM %@;", tableName];
        rs = [database executeQuery:stat];
        int columnCount = [rs columnCount];
        while ([rs next]) {
            record = [[NSMutableArray alloc] init];
            for (int i = 0; i < columnCount; i++) {
                NSString *tmp = [rs stringForColumnIndex:i];
                tmp = tmp.length > 0? tmp: @"";
                [record addObject:tmp];
            }
            [allData addObject:record];
        }
        [rs close];
        [database close];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:allData options:0 error:nil];
    HTTPDataResponse *response = [[HTTPDataResponse alloc] initWithData:data];
    return response;
}

@end
