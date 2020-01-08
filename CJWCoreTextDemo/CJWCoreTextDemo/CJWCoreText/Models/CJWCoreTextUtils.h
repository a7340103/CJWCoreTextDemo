//
//  CJWCoreTextUtils.h
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/8.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJWCoreTextLinkData.h"
#import "CJWCoreTextData.h"

NS_ASSUME_NONNULL_BEGIN

@interface CJWCoreTextUtils : NSObject
+ (CJWCoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(CJWCoreTextData *)data;
+ (CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point data:(CJWCoreTextData *)data;
@end

NS_ASSUME_NONNULL_END
