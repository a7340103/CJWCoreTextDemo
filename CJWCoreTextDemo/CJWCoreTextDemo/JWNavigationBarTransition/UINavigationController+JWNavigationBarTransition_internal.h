//
//  UINavigationController+JWNavigationBarTransition_internal.h
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/4/13.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (JWNavigationBarTransition_internal)
@property (nonatomic, assign) BOOL jw_backgroundViewHidden;
@property (nonatomic, weak) UIViewController *jw_transitionContextToViewController;

@end

NS_ASSUME_NONNULL_END
