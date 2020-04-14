//
//  JWCrachModel.h
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/4/10.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWCrachModel : NSObject
@property (nonatomic,   copy) NSString *exceptionType;
@property (nonatomic,   copy) NSString *exceptionTime;
@property (nonatomic,   copy) NSString *exceptionName;
@property (nonatomic,   copy) NSString *exceptionReason;
@property (nonatomic,   copy) NSString *fuzzyLocalization;    // OC exp only..
@property (nonatomic,   copy) NSString *exceptionCallStack;
@end

NS_ASSUME_NONNULL_END
