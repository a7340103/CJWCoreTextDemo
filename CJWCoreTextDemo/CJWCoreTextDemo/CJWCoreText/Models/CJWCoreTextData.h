//
//  CJWCoreTextData.h
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/7.
//  Copyright © 2020 djw.cc. All rights reserved.
// 用于保存由CTFrameParser类生成的CTFrameRef实例以及CTFrameRef实际绘制需要的高度

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJWCoreTextData : NSObject

@property (assign, nonatomic) CTFrameRef ctFrame;
@property (assign,nonatomic)  CGFloat height;
@property (strong, nonatomic) NSAttributedString *content;
@property (strong, nonatomic) NSArray * imageArray;

@property (strong, nonatomic) NSArray * linkArray;

@end

NS_ASSUME_NONNULL_END
