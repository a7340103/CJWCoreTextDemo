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

    if (self.data) {
        CTFrameDraw(self.data.ctFrame, context);
    }
    for (CJWCoreTextImageData * imageData in self.data.imageArray) {
        UIImage *image = [UIImage imageNamed:imageData.name];
        if (image) {
            CGContextDrawImage(context, imageData.imagePosition, image.CGImage);
        }
    }
}

@end
