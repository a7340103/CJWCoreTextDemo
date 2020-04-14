//
//  UIViewController+JWNavigationBarTransition.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/4/13.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import "UIViewController+JWNavigationBarTransition.h"
#import <objc/runtime.h>
#import "UINavigationBar+JWNavigationBarTransition.h"
#import "UINavigationBar+JWNavigationBarTransition_internal.h"
#import "JWSwizzle.h"
#import "UINavigationController+JWNavigationBarTransition.h"
#import "UINavigationController+JWNavigationBarTransition_internal.h"


@implementation UIViewController (JWNavigationBarTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        JWSwizzleMethod([self class],
                        @selector(viewWillLayoutSubviews),
                        [self class],
                        @selector(jw_viewWillLayoutSubviews));
        
        JWSwizzleMethod([self class],
                        @selector(viewWillAppear:),
                        [self class],
                        @selector(jw_viewWillAppear:));
        
        JWSwizzleMethod([self class],
                        @selector(viewDidAppear:),
                        [self class],
                        @selector(jw_viewDidAppear:));
    });
}

- (void)jw_viewWillAppear:(BOOL)animated {
    [self jw_viewWillAppear:animated];
    id<UIViewControllerTransitionCoordinator> tc = self.transitionCoordinator;
    UIViewController *toViewController = [tc viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if ([self isEqual:self.navigationController.viewControllers.lastObject] && [toViewController isEqual:self]  && tc.presentationStyle == UIModalPresentationNone) {
//        [self km_adjustScrollViewContentInsetAdjustmentBehavior];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.navigationController.navigationBarHidden) {
//                [self km_restoreScrollViewContentInsetAdjustmentBehaviorIfNeeded];
            }
        });
    }
}

- (void)jw_viewDidAppear:(BOOL)animated {
//    [self km_restoreScrollViewContentInsetAdjustmentBehaviorIfNeeded];
    UIViewController *transitionViewController = self.navigationController.jw_transitionContextToViewController;
    if (self.jw_transitionNavigationBar) {
        self.navigationController.navigationBar.barTintColor = self.jw_transitionNavigationBar.barTintColor;
        [self.navigationController.navigationBar setBackgroundImage:[self.jw_transitionNavigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:self.jw_transitionNavigationBar.shadowImage];
        if (!transitionViewController || [transitionViewController isEqual:self]) {
            [self.jw_transitionNavigationBar removeFromSuperview];
            self.jw_transitionNavigationBar = nil;
        }
    }
    if ([transitionViewController isEqual:self]) {
        self.navigationController.jw_transitionContextToViewController = nil;
    }
    self.navigationController.jw_backgroundViewHidden = NO;
    [self jw_viewDidAppear:animated];
}

- (void)jw_viewWillLayoutSubviews {
    id<UIViewControllerTransitionCoordinator> tc = self.transitionCoordinator;
    UIViewController *fromViewController = [tc viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [tc viewControllerForKey:UITransitionContextToViewControllerKey];

    if ([self isEqual:self.navigationController.viewControllers.lastObject] && [toViewController isEqual:self] && tc.presentationStyle == UIModalPresentationNone) {
        if (self.navigationController.navigationBar.translucent) {
            [tc containerView].backgroundColor = [self.navigationController jw_containerViewBackgroundColor];
        }
        fromViewController.view.clipsToBounds = NO;
        toViewController.view.clipsToBounds = NO;
        if (!self.jw_transitionNavigationBar) {
            [self jw_addTransitionNavigationBarIfNeeded];
            self.navigationController.jw_backgroundViewHidden = YES;
        }
        [self jw_resizeTransitionNavigationBarFrame];
    }
    if (self.jw_transitionNavigationBar) {
        [self.view bringSubviewToFront:self.jw_transitionNavigationBar];
    }
    [self jw_viewWillLayoutSubviews];
}



- (UINavigationBar *)jw_transitionNavigationBar {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setJw_transitionNavigationBar:(UINavigationBar *)navigationBar {
    objc_setAssociatedObject(self, @selector(jw_transitionNavigationBar), navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)jw_addTransitionNavigationBarIfNeeded {
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
    if (!self.navigationController.navigationBar) {
        return;
    }
//    [self km_adjustScrollViewContentOffsetIfNeeded];
    UINavigationBar *bar = [[UINavigationBar alloc] init];

    
    bar.jw_isFakeBar = YES;
    bar.barStyle = self.navigationController.navigationBar.barStyle;
    if (bar.translucent != self.navigationController.navigationBar.translucent) {
        bar.translucent = self.navigationController.navigationBar.translucent;
    }
    bar.barTintColor = self.navigationController.navigationBar.barTintColor;
    [bar setBackgroundImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    bar.shadowImage = self.navigationController.navigationBar.shadowImage;
    [self.jw_transitionNavigationBar removeFromSuperview];
    self.jw_transitionNavigationBar = bar;
    [self jw_resizeTransitionNavigationBarFrame];//设置UINavigationBar的位置
    if (!self.navigationController.navigationBarHidden && !self.navigationController.navigationBar.hidden) {
        [self.view addSubview:self.jw_transitionNavigationBar];
    }
}

- (void)jw_resizeTransitionNavigationBarFrame {
    if (!self.view.window) {
        return;
    }
    [self getAllProperties];
    UIView *backgroundView = [self.navigationController.navigationBar valueForKey:@"_backgroundView"];

    CGRect rect = [backgroundView.superview convertRect:backgroundView.frame toView:self.view];
    self.jw_transitionNavigationBar.frame = rect;
}

- (NSArray *)getAllProperties

{

    u_int count;

    objc_property_t *properties  =class_copyPropertyList([self.navigationController.navigationBar class], &count);

    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];

    for (int i = 0; i<count; i++)

    {

        const char* propertyName =property_getName(properties[i]);
            

        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];

    }

    free(properties);

    return propertiesArray;

}

@end
