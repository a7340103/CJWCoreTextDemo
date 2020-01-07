//
//  CJWCDisplayView.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/6.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import "CJWCDisplayView.h"

@interface CJWCDisplayView()
@end


@implementation CJWCDisplayView

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    //获取当前绘制上下文
    //为什么要回去上下文呢？因为我们所有的绘制操作都是在上下文上进行绘制的。
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置字形的变换矩阵为不做图形变换
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    //平移方法，将画布向上平移一个屏幕高
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    //缩放方法，x轴缩放系数为1，则不变，y轴缩放系数为-1，则相当于以x轴为轴旋转180度
    CGContextScaleCTM(context, 1.0, -1.0);
    
//    //创建绘制区域
//    CGMutablePathRef path = CGPathCreateMutable();
//    //添加绘制尺寸
////    CGPathAddRect(path, NULL, self.bounds);
//    CGPathAddEllipseInRect(path, NULL, self.bounds);
//    // 步骤 4
//    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"Hello World!"];
//    attString = [[NSAttributedString alloc] initWithString:@"Hello World! "
//                                     " 创建绘制的区域，CoreText 本身支持各种文字排版的区域，"
//                                     " 我们这里简单地将 UIView 的整个界面作为排版的区域。"
//                                     " 为了加深理解，建议读者将该步骤的代码替换成如下代码，"
//                                     " 测试设置不同的绘制区域带来的界面变化。"];
//
//    //一个frame的工厂，负责生成frame
//    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
//    //工厂根据绘制区域及富文本（可选范围，多次设置）设置frame
//    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
//    CFRangeMake(0, [attString length]), path, NULL);
//
//    CTFrameDraw(frame, context);
//
//    CFRelease(frame);
//    CFRelease(path);
//    CFRelease(framesetter);
    if (self.data) {
        CTFrameDraw(self.data.ctFrame, context);
    }
}

@end
