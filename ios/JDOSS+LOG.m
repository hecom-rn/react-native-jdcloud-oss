//
//  JDOSS+LOG.m
//  Pods
//
//  Created by LJJ on 2020/2/5.
//

#import "JDOSS+LOG.h"
#import "AWSCore.h"

@implementation JDOSS (LOG)
/**
 * enable the dev mode
 */
RCT_EXPORT_METHOD(enableDevMode) {
    [AWSDDLog addLogger:AWSDDTTYLogger.sharedInstance];
    AWSDDLog.sharedInstance.logLevel = AWSDDLogLevelInfo;
}
@end
