//
//  JDOSS.m
//  Pods
//
//  Created by LJJ on 2020/2/5.
//

#import "JDOSS.h"
#import <React/RCTLog.h>
#import <React/RCTConvert.h>

@implementation JDOSS

RCT_EXPORT_MODULE()

- (void)startObserving {
    _hasListeners = YES;
}

- (void)stopObserving {
    _hasListeners = NO;
}

- (NSString*)getTemporaryDirectory {
    NSString *TMP_DIRECTORY = @"react-native/";
    NSString *filepath = [NSTemporaryDirectory() stringByAppendingString:TMP_DIRECTORY];
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:&isDir];
    if (!exists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filepath
                                  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filepath;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"uploadProgress", @"downloadProgress"];
}

@end
