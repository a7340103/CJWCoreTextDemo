//
//  CJWCFrameParser.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/7.
//  Copyright © 2020 djw.cc. All rights reserved.
//  用于生成最后绘制界面需要的CTFrameRef实例

#import "CJWCFrameParser.h"

@implementation CJWCFrameParser

+ (CJWCoreTextData *)parseAttributedContent:(NSAttributedString *)content config:(CJWCFrameParserConfig*)config{
    // 创建CTFramesetterRef实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    
    // 获得要缓制的区域的高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    // 生成CTFrameRef实例
    CTFrameRef frame = [self createFrameWithFramesetter:framesetter config:config height:textHeight];
    
    // 将生成好的CTFrameRef实例和计算好的缓制高度保存到CoreTextData实例中，最后返回CoreTextData实例
    CJWCoreTextData *data = [[CJWCoreTextData alloc] init];
    data.ctFrame = frame;
    data.height = textHeight;
    data.content = content;
    
    // 释放内存
    CFRelease(frame);
    CFRelease(framesetter);
    return data;
}

+ (NSDictionary *)attributesWithConfig:(CJWCFrameParserConfig *)config{
    CGFloat fontSize = config.fontSize;
       CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
       CGFloat lineSpacing = config.lineSpace;
       const CFIndex kNumberOfSettings = 3;
       CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
           { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing },
           { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
           { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing }
       };
       CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
       UIColor * textColor = config.textColor;
       NSMutableDictionary * dict = [NSMutableDictionary dictionary];
       dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
       dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
       dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
       CFRelease(theParagraphRef);
       CFRelease(fontRef);
       return dict;
}

+ (CJWCoreTextData *)parseContent:(NSString *)content config:(CJWCFrameParserConfig *)config{
    NSDictionary *attributes = [self attributesWithConfig:config];
    NSAttributedString *contentString = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    
    //创建 CTFramesetterRef 实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contentString);
    
    //获得要绘制的区域的高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    // 生成 CTFrameRef 实例
    CTFrameRef frame = [self createFrameWithFramesetter:framesetter config:config height:textHeight];
    
    // 将生成好的 CTFrameRef 实例和计算好的绘制高度保存到 CoreTextData 实例中，最后返回 CoreTextData 实例
    CJWCoreTextData *data = [[CJWCoreTextData alloc] init];
    data.ctFrame = frame;
    data.height = textHeight;
    // 释放内存
    CFRelease(frame);
    CFRelease(framesetter);
    return data;
    
}

+ (CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter config:(CJWCFrameParserConfig *)config height:(CGFloat)height {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}

@end
