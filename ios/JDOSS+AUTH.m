//
//  JDOSS+AUTH.m
//  Pods
//
//  Created by LJJ on 2020/2/5.
//

#import "JDOSS+AUTH.h"
#import "AWSCore.h"


@implementation JDOSS (AUTH)

/**
 * initWithPlainTextAccessKey
 */
RCT_EXPORT_METHOD(initWithPlainTextAccessKey:(NSString *)accessKey
                  secretKey:(NSString *)secretKey
                  endPoint:(NSString *)endPoint
                  configuration:(NSDictionary *)configuration) {
    
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accessKey secretKey:secretKey];
    AWSEndpoint *aEndPoint = [[AWSEndpoint alloc] initWithURLString:endPoint];
    
    AWSServiceConfiguration *conf = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                                    endpoint:aEndPoint
                                                                         credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = conf;
}

RCT_EXPORT_METHOD(initWithSecurityToken:(NSString *)securityToken
                  accessKey:(NSString *)accessKey
                  secretKey:(NSString *)secretKey
                  endPoint:(NSString *)endPoint
                  configuration:(NSDictionary *)configuration) {
    
    AWSBasicSessionCredentialsProvider *credentialsProvider = [[AWSBasicSessionCredentialsProvider alloc] initWithAccessKey:accessKey secretKey:secretKey sessionToken:securityToken];
//    AWSEndpoint *aEndPoint = [[AWSEndpoint alloc] initWithURLString:endPoint];
    AWSEndpoint *aEndPoint = [[AWSEndpoint alloc] initWithURLString:@"http://s3.cn-north-1.jdcloud-oss.com"];
    
    AWSServiceConfiguration *conf = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                                    endpoint:aEndPoint
                                                                         credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = conf;
}

@end
