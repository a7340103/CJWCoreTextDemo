//
//  KMWeakObjectContainer.h
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/4/13.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern void jw_objc_setAssociatedWeakObject(id container, void *key, id value);
extern id jw_objc_getAssociatedWeakObject(id container, void *key);

NS_ASSUME_NONNULL_END
