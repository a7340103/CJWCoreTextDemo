//
//  UINavigationController+JWNavigationBarTransition.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/4/13.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import "UINavigationController+JWNavigationBarTransition.h"
#import "JWSwizzle.h"
#import "UIViewController+JWNavigationBarTransition.h"
#import "UIViewController+JWNavigationBarTransition_internal.h"
#import "JWWeakObjectContainer.h"
#import <objc/runtime.h>


@implementation UINavigationController (JWNavigationBarTransition)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        JWSwizzleMethod([self class],
                        @selector(pushViewController:animated:),
                        [self class],
                        @selector(jw_pushViewController:animated:));
        
        JWSwizzleMethod([self class],
                        @selector(popViewControllerAnimated:),
                        [self class],
                        @selector(jw_popViewControllerAnimated:));
        
        JWSwizzleMethod([self class],
                        @selector(popToViewController:animated:),
                        [self class],
                        @selector(jw_popToViewController:animated:));
        
        JWSwizzleMethod([self class],
                        @selector(popToRootViewControllerAnimated:),
                        [self class],
                        @selector(jw_popToRootViewControllerAnimated:));
        
        JWSwizzleMethod([self class],
                        @selector(setViewControllers:animated:),
                        [self class],
                        @selector(jw_setViewControllers:animated:));
    });
}

- (void)jw_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (!disappearingViewController) {
        return [self jw_pushViewController:viewController animated:animated];
    }
    if (!self.jw_transitionContextToViewController || !disappearingViewController.jw_transitionNavigationBar) {
        [disappearingViewController jw_addTransitionNavigationBarIfNeeded];
    }
    if (animated) {
        self.jw_transitionContextToViewController = viewController;
        if (disappearingViewController.jw_transitionNavigationBar) {
            disappearingViewController.navigationController.jw_backgroundViewHidden = YES;
        }
    }
    return [self jw_pushViewController:viewController animated:animated];
}

- (UIViewController *)jw_popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count < 2) {
        return [self jw_popViewControllerAnimated:animated];
    }
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    [disappearingViewController jw_addTransitionNavigationBarIfNeeded];
    UIViewController *appearingViewController = self.viewControllers[self.viewControllers.count - 2];
    if (appearingViewController.jw_transitionNavigationBar) {
        UINavigationBar *appearingNavigationBar = appearingViewController.jw_transitionNavigationBar;
        self.navigationBar.barTintColor = appearingNavigationBar.barTintColor;
        [self.navigationBar setBackgroundImage:[appearingNavigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = appearingNavigationBar.shadowImage;
    }
    if (animated) {
        disappearingViewController.navigationController.jw_backgroundViewHidden = YES;
    }
    return [self jw_popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)jw_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (![self.viewControllers containsObject:viewController] || self.viewControllers.count < 2) {
        return [self jw_popToViewController:viewController animated:animated];
    }
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    [disappearingViewController jw_addTransitionNavigationBarIfNeeded];
    if (viewController.jw_transitionNavigationBar) {
        UINavigationBar *appearingNavigationBar = viewController.jw_transitionNavigationBar;
        self.navigationBar.barTintColor = appearingNavigationBar.barTintColor;
        [self.navigationBar setBackgroundImage:[appearingNavigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = appearingNavigationBar.shadowImage;
    }
    if (animated) {
        disappearingViewController.navigationController.jw_backgroundViewHidden = YES;
    }
    return [self jw_popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)jw_popToRootViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count < 2) {
        return [self jw_popToRootViewControllerAnimated:animated];
    }
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    [disappearingViewController jw_addTransitionNavigationBarIfNeeded];
    UIViewController *rootViewController = self.viewControllers.firstObject;
    if (rootViewController.jw_transitionNavigationBar) {
        UINavigationBar *appearingNavigationBar = rootViewController.jw_transitionNavigationBar;
        self.navigationBar.barTintColor = appearingNavigationBar.barTintColor;
        [self.navigationBar setBackgroundImage:[appearingNavigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = appearingNavigationBar.shadowImage;
    }
    if (animated) {
        disappearingViewController.navigationController.jw_backgroundViewHidden = YES;
    }
    return [self jw_popToRootViewControllerAnimated:animated];
}

- (void)jw_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (animated && disappearingViewController && ![disappearingViewController isEqual:viewControllers.lastObject]) {
        [disappearingViewController jw_addTransitionNavigationBarIfNeeded];
        if (disappearingViewController.jw_transitionNavigationBar) {
            disappearingViewController.navigationController.jw_backgroundViewHidden = YES;
        }
    }
    return [self jw_setViewControllers:viewControllers animated:animated];
}


- (UIViewController *)jw_transitionContextToViewController {
    return jw_objc_getAssociatedWeakObject(self, _cmd);
}

- (void)setJw_transitionContextToViewController:(UIViewController *)viewController {
    jw_objc_setAssociatedWeakObject(self, @selector(jw_transitionContextToViewController), viewController);
}

- (BOOL)jw_backgroundViewHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setJw_backgroundViewHidden:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(jw_backgroundViewHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[self.navigationBar valueForKey:@"_backgroundView"]
     setHidden:hidden];
}

- (UIColor *)jw_containerViewBackgroundColor {
    return [UIColor whiteColor];
}

@end
