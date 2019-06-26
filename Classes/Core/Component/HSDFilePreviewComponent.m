//
//  HSDFilePreviewComponent.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/28.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDFilePreviewComponent.h"
#import "HSDZipArchive.h"
#import "HSDManager+Project.h"

@implementation HSDFilePreviewComponent

+ (NSData *)fetchContentsOfStandardUserDefaults {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSDictionary *serializableDict = [self fetchSerializableDictionary:dict];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:serializableDict options:(NSJSONWritingPrettyPrinted) error:&error];
    return data;
}

/**
 *  get dictionary, that is valid for [NSJSONSerialization dataWithJSONObject:options:error:];
 */
+ (NSDictionary *)fetchSerializableDictionary:(NSDictionary *)dict {
    NSMutableDictionary *retDict = [[NSMutableDictionary alloc] init];
    NSArray *allKeys = [dict allKeys];
    for (id ele in allKeys) {
        if ([ele isKindOfClass:[NSString class]]) {
            // valid key
            id value = [dict objectForKey:ele];
            id val = [self fetchSerializableObject:value];
            if (val) {
                [retDict setObject:val forKey:ele];
            }
        }
    }
    return retDict;
}

/**
 *  get arrary, that is valid for [NSJSONSerialization dataWithJSONObject:options:error:];
 */
+ (NSArray *)fetchSerializableArray:(NSArray *)arr {
    NSMutableArray *retArr = [[NSMutableArray alloc] init];
    for (id value in arr) {
        id val = [self fetchSerializableObject:value];
        if (val) {
            [retArr addObject:val];;
        }
    }
    return retArr;
}

/**
 *  get object, that is valid for [NSJSONSerialization dataWithJSONObject:options:error:];
 */
+ (id)fetchSerializableObject:(id)value {
    id retVal;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];

    if ([value isKindOfClass:[NSString class]]
        || [value isKindOfClass:[NSNumber class]]) {
        // NSString or NSNumber value
        retVal = value;
    } else if ([value isKindOfClass:[NSData class]]) {
        // NSDate value
        NSString *str = [[NSString alloc] initWithData:value encoding:(NSASCIIStringEncoding)];
        if (str) {
            retVal = str;
        }
    } else if ([value isKindOfClass:[NSDate class]]) {
        // NSDate value
        NSString *dateStr = [dateFormatter stringFromDate:(NSDate *)value];
        retVal = dateStr;
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        // NSDictionary value
        NSDictionary *dictVal = [self fetchSerializableDictionary:(NSDictionary *)value];
        if (dictVal) {
            retVal = dictVal;
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        // NSArray value
        NSArray *arrVal = [self fetchSerializableArray:(NSArray *)value];
        if (arrVal) {
            retVal = arrVal;
        }
    }
    return retVal;
}

+ (NSData *)fetchContentsWithFilePath:(NSString *)filePath contentType:(NSString **)contentType {
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
    
    NSString *fileContentType;

    if (isExist) {
        if (isDirectory) {
            // request directory, zip archive directory and response
            NSString *tmpFileName = [NSString stringWithFormat:@"hsd_file_preview_%@.zip", filePath.lastPathComponent];
            NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:tmpFileName];
            [HSDZipArchive createZipFileAtPath:tmpPath withContentsOfDirectory:filePath keepParentDirectory:YES];
            data = [[NSData alloc] initWithContentsOfFile:tmpPath];

            // content type
            NSString *fileExtension = tmpPath.pathExtension;
            fileContentType = [HSDManager fetchContentTypeWithFilePathExtension:fileExtension];

            // clean tmp file
            [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
        } else {
            // request file
            data = [[NSData alloc] initWithContentsOfFile:filePath];
            
            // content type
            NSString *fileExtension = filePath.pathExtension;
            fileContentType = [HSDManager fetchContentTypeWithFilePathExtension:fileExtension];
        }
    }
    *contentType = fileContentType;
    return data;
}

@end
