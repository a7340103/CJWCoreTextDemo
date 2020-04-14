//
//  UIViewController+JWNavigationBarTransition_internal.h
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/4/13.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (JWNavigationBarTransition_internal)
@property (nonatomic, strong) UINavigationBar *jw_transitionNavigationBar;

- (void)jw_addTransitionNavigationBarIfNeeded;
@end

NS_ASSUME_NONNULL_END
