//
//  JDOSSTool.m
//  Pods
//
//  Created by LJJ on 2020/2/6.
//

#define kDefautCacheUrl @"react-native-jdcloud-oss"

#import "JDOSSTool.h"

@implementation JDOSSTool

+ (NSString * _Nullable)getFilePathWithData:(NSData *)data
                                   fileName:(NSString *)fileName {
    NSString *returnPath;
    if (data.length > 0) {
        NSString *uuid = [JDOSSTool uuidString];
        NSString *suffix = [fileName pathExtension];
        if (suffix) {
            uuid = [NSString stringWithFormat:@"%@.%@", uuid, suffix];
        }
        returnPath = [self getFilePath:uuid];
        if (![JDOSSTool isEmpty:returnPath]) {
            BOOL succ = [data writeToFile:returnPath atomically:YES];
            if (!succ) {
                return nil;
            }
        }
    }
    return returnPath;
}

+ (NSString *)uuidString {
    
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

static BOOL _isClean = NO;
+ (NSString *)getFilePath:(NSString *)fileName {
    fileName = [fileName lastPathComponent];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathArrOne = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:kDefautCacheUrl];
    
    if([fileManager fileExistsAtPath:pathArrOne] && !_isClean){
        [fileManager removeItemAtPath:pathArrOne error:nil];
    }
    _isClean = YES;
    
    if(![fileManager fileExistsAtPath:pathArrOne]){
        BOOL succ = [fileManager createDirectoryAtPath:pathArrOne withIntermediateDirectories:YES attributes:nil error:nil];
        if (!succ) {
            return nil;
        }
    }
    
    if ([JDOSSTool isEmpty:fileName]) {
        return nil;
    }else {
        NSString *filePath = [pathArrOne stringByAppendingPathComponent:fileName];
        return filePath;
    }
}

+ (BOOL)isEmpty:(NSString *)string {
    if (![string isKindOfClass:[NSString class]]) {
        string = [string description];
    }
    if (string == nil) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return YES;
    }
    if ([string isEqualToString:@"(null)(null)"] || [string isEqualToString:@"<null>"]) {
        return YES;
    }
    return NO;
}

@end
