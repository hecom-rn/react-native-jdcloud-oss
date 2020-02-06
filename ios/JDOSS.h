//
//  JDOSS.h
//  Pods
//
//  Created by LJJ on 2020/2/5.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface JDOSS : RCTEventEmitter <RCTBridgeModule>

@property (nonatomic, assign) BOOL hasListeners;

- (NSString *)getTemporaryDirectory;

@end

