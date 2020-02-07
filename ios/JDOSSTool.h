//
//  JDOSSTool.h
//  Pods
//
//  Created by LJJ on 2020/2/6.
//

#import <Foundation/Foundation.h>

@interface JDOSSTool : NSObject

+ (NSString * _Nullable)getFilePathWithData:(NSData *)data
                                   fileName:(NSString *)fileName;

@end
