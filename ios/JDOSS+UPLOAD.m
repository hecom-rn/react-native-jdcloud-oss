//
//  JDOSS+UPLOAD.m
//  Pods
//
//  Created by LJJ on 2020/2/5.
//

#import "JDOSS+UPLOAD.h"
#import <AWSCore.h>
#import <AWSS3.h>
#import "JDOSSTool.h"

@import Photos;
@import MobileCoreServices;

@implementation JDOSS (UPLOAD)

RCT_REMAP_METHOD(upload,
                 asyncUploadWithBucketName:(NSString *)bucketName
                 objectKey:(NSString *)objectKey
                 filepath:(NSString *)filepath
                 options:(NSDictionary*)options
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    
    [self beginUploadingWithFilepath:filepath resultBlock:^(NSURL *url) {
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.bucket = bucketName;
        uploadRequest.key = objectKey;
        uploadRequest.body = url;
        __weak typeof(self) weakSelf = self;
        uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            
            NSLog(@"%lld, %lld, %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
            if (self.hasListeners) {
                [self sendEventWithName:@"uploadProgress" body:@{
                    @"currentSize": [NSString stringWithFormat:@"%lld",totalBytesSent],
                    @"totalSize": [NSString stringWithFormat:@"%lld",totalBytesExpectedToSend]}];
            }
        };

        [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
            if (task.error) {
                NSLog(@"upload object failed, error: %@" , task.error);
                reject(@"Error", @"Upload failed", task.error);
            } else {
                if (uploadRequest.state == AWSS3TransferManagerRequestStateCompleted) {
                    NSLog(@"upload object success!");
                    resolve(@"success");
                }
            }
            return nil;
        }];
        
    }];
}

- (void)beginUploadingWithFilepath:(NSString *)filepath resultBlock:(void (^) (NSURL *))callback {
    // read asset data from filepath
    if ([filepath hasPrefix:@"assets-library://"]) {
        PHAsset *asset = [PHAsset fetchAssetsWithALAssetURLs:@[[NSURL URLWithString:filepath]] options:nil].firstObject;
        [self convertToNSDataFromAsset:asset withHandler:callback];
    } else if ([filepath hasPrefix:@"localIdentifier://"]) {
        NSString *localIdentifier = [filepath stringByReplacingOccurrencesOfString:@"localIdentifier://" withString:@""];
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil].firstObject;
        [self convertToNSDataFromAsset:asset withHandler:callback];
        
    } else {
//        filepath = [filepath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:filepath];
        callback(url);
    }
}

- (void)convertToNSDataFromAsset:(PHAsset *)asset withHandler:(void (^) (NSURL *))handler {
    PHImageManager *imageManager = [PHImageManager defaultManager];
    switch (asset.mediaType) {
        case PHAssetMediaTypeImage: {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            [imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeJPEG]) {
                    NSString *fileName = [asset valueForKey:@"filename"];
                    NSString *path = [JDOSSTool getFilePathWithData:imageData fileName:fileName];
                    if (path) {
                        NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
                        handler(url);
                    } else {
                        handler(nil);
                    }
                } else {
                    //if the image UTI is not JPEG, then do the convertion to make sure its compatibility
                    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
                    NSDictionary *imageInfo = (__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
                    NSDictionary *metadata = [imageInfo copy];
                    
                    NSMutableData *imageDataJPEG = [NSMutableData data];
                    
                    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageDataJPEG, kUTTypeJPEG, 1, NULL);
                    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef)metadata);
                    CGImageDestinationFinalize(destination);
                    
                    NSString *fileName = [asset valueForKey:@"filename"];
                    NSDate *imageD = [NSData dataWithData:imageDataJPEG];
                    NSString *path = [JDOSSTool getFilePathWithData:imageD fileName:fileName];
                    if (path) {
                        NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
                        handler(url);
                    } else {
                        handler(nil);
                    }
                }
            }];
            break;
        }
        case PHAssetMediaTypeVideo:{
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            [imageManager requestExportSessionForVideo:asset options:options exportPreset:AVAssetExportPresetHighestQuality resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
                
                //generate a temporary directory for caching the video (MP4 Only)
                NSString *filePath = [[self getTemporaryDirectory] stringByAppendingString:[[NSUUID UUID] UUIDString]];
                filePath = [filePath stringByAppendingString:@".mp4"];
                
                exportSession.shouldOptimizeForNetworkUse = YES;
                exportSession.outputFileType = AVFileTypeMPEG4;
                exportSession.outputURL = [NSURL fileURLWithPath:filePath];
                
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    if (filePath) {
                        NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
                        handler(url);
                    } else {
                        handler(nil);
                    }
                }];
            }];
            break;
        }
        default:
            break;
    }
}
@end
