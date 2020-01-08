//
//  CJWCoreTextData.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/7.
//  Copyright © 2020 djw.cc. All rights reserved.
//  用于保存由CTFrameParser类生成的CTFrameRef实例以及CTFrameRef实际绘制需要的高度。

#import "CJWCoreTextData.h"
#import "CJWCoreTextImageData.h"

@implementation CJWCoreTextData

- (void)setCtFrame:(CTFrameRef)ctFrame{
    if (_ctFrame != ctFrame) {
        if (_ctFrame != nil) {
            CFRelease(_ctFrame);
        }
        CFRetain(ctFrame);
        _ctFrame = ctFrame;
    }
}

- (void)setImageArray:(NSArray *)imageArray{
    _imageArray = imageArray;
    [self fillImagePosition];
}

- (void)fillImagePosition{
    if (self.imageArray.count == 0) {
        return;
    }
    NSArray *lines = (NSArray *)CTFrameGetLines(self.ctFrame);
    int lineCount = (int)[lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    int imgIndex = 0;
    CJWCoreTextImageData *imageData = self.imageArray[0];
    //遍历线的数组
    for (int i = 0; i < lineCount; ++i) {
        if (imageData == nil) {
            break;
        }
        CTLineRef line = (__bridge CTLineRef)lines[i];
        //获取GlyphRun数组（GlyphRun：高效的字符绘制方案）
        NSArray *runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        //遍历CTRun数组
        for (id runObj in runObjArray) {
            //获取CTRun
            CTRunRef run = (__bridge CTRunRef)runObj;
            //获取CTRun的属性
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            //获取代理
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)([runAttributes valueForKey:(id)kCTRunDelegateAttributeName]);
            if (delegate == nil) {
                continue;
            }
            //获取创建字典时用的字典
            NSDictionary *metaDic = CTRunDelegateGetRefCon(delegate);
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, 0);
            runBounds.size.height = ascent+descent;
            //获取x偏移量
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            //point是行起点位置，加上每个字的偏移量得到每个字的x
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            //计算原点
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;
            
            //runBounds获取到的是当前CTRun相对于当前绘制path的坐标，要加上path本身的原点才是屏幕的坐标系统
            //获取绘制区域
            CGPathRef pathRef = CTFrameGetPath(self.ctFrame);
            //获取父view rect
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            
            imageData.imagePosition = delegateBounds;
            
            //设置下个imageData
            imgIndex++;
            if (imgIndex == self.imageArray.count) {
                imageData = nil;
                break;
            }else{
                imageData = self.imageArray[imgIndex];
            }
        }
    }
    
    
}

- (void)dealloc{
    if (_ctFrame != nil) {
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }
}

@end
