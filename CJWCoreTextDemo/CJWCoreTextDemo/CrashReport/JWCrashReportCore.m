//
//  JWCrashReportCore.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/4/10.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import "JWCrashReportCore.h"
#import "JWCrachModel.h"


/**
 * @internal
 * Fatal signals to be monitored.
 */
static int monitored_signals[] = {
    SIGABRT,
    SIGBUS,
    SIGFPE,
    SIGILL,
    SIGSEGV,
    SIGTRAP
};

static int monitored_signals_count = sizeof(monitored_signals) / sizeof(monitored_signals[0]);

@implementation JWCrashReportCore
+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    static id __singleton__;
    dispatch_once( &once, ^{
        __singleton__ = [[self alloc] init];
    } );
    return __singleton__;
}


- (void)thaw{
    for (int i = 0; i < monitored_signals_count; i++) {
        signal(monitored_signals[i], &machSignalExceptionHandler);
    }
    //捕获oc层面异常
    NSSetUncaughtExceptionHandler(&ocExceptionHandler);
}

#pragma mark - private
static void machSignalExceptionHandler(int signal) {

}

static void ocExceptionHandler(NSException *exception) {
    JWCrachModel *crash = [[JWCrachModel alloc] init];
    crash.exceptionName = [exception name];
    crash.exceptionReason = [exception reason];
    crash.exceptionCallStack = [NSString stringWithFormat:@"%@", [[exception callStackSymbols] componentsJoinedByString:@"\n"]];
    
    abort();
    
//    NSLog(@"%@", crash.debugDescription);
}


@end
