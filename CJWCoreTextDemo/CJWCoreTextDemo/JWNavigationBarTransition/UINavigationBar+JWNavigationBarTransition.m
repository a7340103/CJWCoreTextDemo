//
//  UINavigationBar+JWNavigationBarTransition.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/4/13.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import "UINavigationBar+JWNavigationBarTransition.h"
#import <objc/runtime.h>
#import "JWSwizzle.h"


@implementation UINavigationBar (JWNavigationBarTransition)

- (BOOL)jw_isFakeBar {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setJw_isFakeBar:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(jw_isFakeBar), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
