//
//  CJWCLayer.h
//  CJWCoreTextDemo
//
//  Created by djw on 2020/2/25.
//  Copyright © 2020年 djw.cc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJWCLayer : CALayer

@property (nonatomic, copy) BOOL (^cancelBlock)(void);
@property (nonatomic ,copy) void (^displayBlock)(CGContextRef context,BOOL(^isCanceled)(void));

@end

@interface CJWCLayerSentinel:NSObject

@end

NS_ASSUME_NONNULL_END
