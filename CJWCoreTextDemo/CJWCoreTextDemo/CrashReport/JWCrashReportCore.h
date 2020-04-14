//
//  JWCrashReportCore.h
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/4/10.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWCrashReportCore : NSObject
+ (instancetype)sharedInstance;
- (void)thaw;


@end

NS_ASSUME_NONNULL_END
