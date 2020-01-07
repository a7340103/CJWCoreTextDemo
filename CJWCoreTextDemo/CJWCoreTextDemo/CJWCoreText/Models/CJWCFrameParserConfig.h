//
//  CJWCFrameParserConfig.h
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/7.
//  Copyright © 2020 djw.cc. All rights reserved.
//  用于配置绘制的参数，例如：文字颜色，大小，行间距等。

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface CJWCFrameParserConfig : NSObject
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, strong) UIColor *textColor;
@end

NS_ASSUME_NONNULL_END
