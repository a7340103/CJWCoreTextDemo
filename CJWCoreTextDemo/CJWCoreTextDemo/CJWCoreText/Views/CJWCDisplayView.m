//
//  CJWCDisplayView.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/6.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import "CJWCDisplayView.h"
#import "CJWCoreTextUtils.h"

NSString *const CTDisplayViewImagePressedNotification = @"CJWCDisplayViewImagePressedNotification";
NSString *const CTDisplayViewLinkPressedNotification = @"CJWCDisplayViewLinkPressedNotification";

typedef enum CTDisplayViewState : NSInteger {
    CTDisplayViewStateNormal,       // 普通状态
    CTDisplayViewStateTouching,     // 正在按下，需要弹出放大镜
    CTDisplayViewStateSelecting     // 选中了一些文本，需要弹出复制菜单
}CTDisplayViewState;

@interface CJWCDisplayView()
@property (nonatomic) NSInteger selectionStartPosition;
@property (nonatomic) NSInteger selectionEndPosition;
@property (nonatomic) CTDisplayViewState state;
@property (strong, nonatomic) UIImageView *leftSelectionAnchor;
@property (strong, nonatomic) UIImageView *rightSelectionAnchor;
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
    
    UIGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(userLongPressedGuestureDetected:)];
    [self addGestureRecognizer:longPressRecognizer];
    self.userInteractionEnabled = YES;

}
- (void)userLongPressedGuestureDetected:(UILongPressGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
//    debugLog(@"state = %d", recognizer.state);
//    debugLog(@"point = %@", NSStringFromCGPoint(point));
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        CFIndex index = [CJWCoreTextUtils touchContentOffsetInView:self atPoint:point data:self.data];
        if (index != -1 && index < self.data.content.length) {//[0,168] 合理的范围应该在[0,167]
            debugLog(@"index = %d", index);
            debugLog(@"endindex = %d",index+1);
            _selectionStartPosition = index;
            _selectionEndPosition = index+1;
        }
        self.state = CTDisplayViewStateTouching;
    }else{
        if (_selectionStartPosition >= 0 && _selectionEndPosition <= self.data.content.length) {
            self.state = CTDisplayViewStateSelecting;
        }else{
            self.state = CTDisplayViewStateNormal;
        }
    }
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
    //点击链接
    CJWCoreTextLinkData *linkData = [CJWCoreTextUtils touchLinkInView:self atPoint:point data:self.data];
    if (linkData) {
        NSLog(@"hint link!");
        NSDictionary *userInfo = @{ @"linkData": linkData };
        [[NSNotificationCenter defaultCenter] postNotificationName:CTDisplayViewLinkPressedNotification
                                                            object:self userInfo:userInfo];
        return;

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

    if (self.state == CTDisplayViewStateTouching || self.state == CTDisplayViewStateSelecting) {
        [self drawSelectionArea];
        [self drawAnchors];
    }
    
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

- (void)drawSelectionArea{
    if (_selectionStartPosition < 0 || _selectionEndPosition > self.data.content.length) {
        return;
    }
    CTFrameRef textFrame = self.data.ctFrame;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        return;
    }
    CFIndex count = CFArrayGetCount(lines);
    // 获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);
        // 1. start和end在一个line,则直接弄完break
        if ([self isPosition:_selectionStartPosition inRange:range] && [self isPosition:_selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, leading, offset, offset2;
            offset = CTLineGetOffsetForStringIndex(line, _selectionStartPosition, NULL);
            offset2 = CTLineGetOffsetForStringIndex(line, _selectionEndPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, offset2 - offset, ascent+descent);
            [self fillSelectionAreaInRect:lineRect];
            break;
        }

        
    }
}

- (void)fillSelectionAreaInRect:(CGRect)rect {

    UIColor *bgColor = RGB(204, 221, 236);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextFillRect(context, rect);
}

- (void)drawAnchors{
    if (_selectionStartPosition < 0 || _selectionEndPosition > self.data.content.length) {
        return;
    }
    // 翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    CTFrameRef frameRef = self.data.ctFrame;
    NSArray *linesArray = (NSArray *) CTFrameGetLines(frameRef);
    NSInteger lineCount = linesArray.count;
    CGPoint point[lineCount];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), point);
    for (NSInteger i = 0; i<lineCount; i++) {
        CGPoint linePoint = point[i];
        CTLineRef lineRef = (__bridge CTLineRef)(linesArray[i]);
        CFRange range = CTLineGetStringRange(lineRef);
        
        if ([self isPosition:_selectionStartPosition inRange:range]) {
            CGFloat ascent, descent, leading, offset;
            offset = CTLineGetOffsetForStringIndex(lineRef, _selectionStartPosition, NULL);
            CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
            CGPoint originPoint = CGPointMake(linePoint.x + offset - 5, linePoint.y + ascent + 11);
            originPoint = CGPointApplyAffineTransform(originPoint, transform);
            self.leftSelectionAnchor.origin = originPoint;
        }
        if ([self isPosition:_selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, leading, offset;
            offset = CTLineGetOffsetForStringIndex(lineRef, _selectionEndPosition, NULL);
            CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
            CGPoint originPoint = CGPointMake(linePoint.x + offset - 5, linePoint.y + ascent + 11);
            originPoint = CGPointApplyAffineTransform(originPoint, transform);
            self.rightSelectionAnchor.origin = originPoint;
        }
        
    }
}


- (BOOL)isPosition:(NSInteger)position inRange:(CFRange)range {
    if (position >= range.location && position <= range.location + range.length) {
        return YES;
    } else {
        return NO;
    }
}

//根据触摸状态设置不同的东西
- (void)setState:(CTDisplayViewState)state{
    if (_state == state) {
        return;
    }
    _state = state;
    
    if (_state == CTDisplayViewStateNormal) {
        
    }else if (_state == CTDisplayViewStateTouching){
        if (_leftSelectionAnchor == nil && _rightSelectionAnchor == nil) {
            [self setupAnchors];
        }
        
    }else if (_state == CTDisplayViewStateSelecting){
        
    }
    [self setNeedsDisplay];
}

#pragma mark - 设置游标
#define FONT_HEIGHT  40

- (void)setupAnchors{
    _leftSelectionAnchor = [self createSelectionAnchorWithTop:YES];
    _rightSelectionAnchor =  [self createSelectionAnchorWithTop:NO];
    [self addSubview:_leftSelectionAnchor];
    [self addSubview:_rightSelectionAnchor];
}

- (UIImageView *)createSelectionAnchorWithTop:(BOOL)isTop {
    UIImage *image = [self cursorWithFontHeight:FONT_HEIGHT isTop:isTop];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, 11, FONT_HEIGHT);
    return imageView;
}

- (UIImage *)cursorWithFontHeight:(CGFloat)height isTop:(BOOL)top {
    
    CGRect rect = CGRectMake(0, 0, 22, height * 2);
    UIColor *color = RGB(28, 107, 222);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (top) {
        CGContextAddEllipseInRect(context, CGRectMake(0, 0, 22, 22));
    }else{
        CGContextAddEllipseInRect(context, CGRectMake(0, height * 2 - 22, 22, 22));
    }
    //设置填充颜色
    CGContextSetFillColorWithColor(context, color.CGColor);
    //渲染当前context上绘制的内容
    CGContextFillPath(context);
    // draw line
    [color set];
    //设置线宽
    CGContextSetLineWidth(context, 4);
    //移动画笔到point(11,22)
    CGContextMoveToPoint(context, 11, 22);
    //从point(11,22）和point(11,height*2-22)之间画根直线
    CGContextAddLineToPoint(context, 11, height * 2 - 22);
    //渲染画笔画过的颜色
    CGContextStrokePath(context);
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
