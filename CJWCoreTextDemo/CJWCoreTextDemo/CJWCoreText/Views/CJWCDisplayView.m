//
//  CJWCDisplayView.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/6.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import "CJWCDisplayView.h"

NSString *const CTDisplayViewImagePressedNotification = @"CTDisplayViewImagePressedNotification";


@interface CJWCDisplayView()
@end


@implementation CJWCDisplayView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupEvents];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupEvents];
    }
    return self;
}

- (void)setupEvents {
    UIGestureRecognizer * tapRecognizer =
          [[UITapGestureRecognizer alloc] initWithTarget:self
                    action:@selector(userTapGestureDetected:)];
    [self addGestureRecognizer:tapRecognizer];
    self.userInteractionEnabled = YES;
}

- (void)userTapGestureDetected:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    for (CJWCoreTextImageData * imageData in self.data.imageArray) {
        // 翻转坐标系，因为 imageData 中的坐标是 CoreText 的坐标系
        CGRect imageRect = imageData.imagePosition;
        CGPoint imagePosition = imageRect.origin;
        imagePosition.y = self.bounds.size.height - imageRect.origin.y
                          - imageRect.size.height;
        CGRect rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height);
        // 检测点击位置 Point 是否在 rect 之内
        if (CGRectContainsPoint(rect, point)) {
            // 在这里处理点击后的逻辑
            NSLog(@"bingo");
            NSDictionary *userInfo = @{ @"imageData": imageData };
            [[NSNotificationCenter defaultCenter] postNotificationName:CTDisplayViewImagePressedNotification
                                                                object:self userInfo:userInfo];
            return;
        }
    }
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    //获取当前绘制上下文
    //为什么要回去上下文呢？因为我们所有的绘制操作都是在上下文上进行绘制的。
    //UIGraphicsGetCurrentContext()获取的context由系统维护，不需要手动释放
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
