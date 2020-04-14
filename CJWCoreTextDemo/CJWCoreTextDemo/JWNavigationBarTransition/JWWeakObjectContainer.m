//
//  KMWeakObjectContainer.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/4/13.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import "JWWeakObjectContainer.h"
#import <objc/runtime.h>


@interface JWWeakObjectContainer : NSObject
@property (nonatomic, weak) id object;

@end

@implementation JWWeakObjectContainer

void jw_objc_setAssociatedWeakObject(id container, void *key, id value)
{
    JWWeakObjectContainer *wrapper = [[JWWeakObjectContainer alloc] init];
    wrapper.object = value;
    objc_setAssociatedObject(container, key, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

id jw_objc_getAssociatedWeakObject(id container, void *key)
{
    return [(JWWeakObjectContainer *)objc_getAssociatedObject(container, key) object];
}

@end
