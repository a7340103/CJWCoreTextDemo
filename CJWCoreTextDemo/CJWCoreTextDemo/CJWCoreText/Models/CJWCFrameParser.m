//
//  CJWCFrameParser.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/7.
//  Copyright © 2020 djw.cc. All rights reserved.
//  用于生成最后绘制界面需要的CTFrameRef实例

#import "CJWCFrameParser.h"

@implementation CJWCFrameParser

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

+ (CJWCoreTextData *)parseHtml:(NSString *)localPath config:(CJWCFrameParserConfig*)config {
    NSString *path = [[NSBundle mainBundle] pathForResource:localPath ofType:@"html"];
    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    // Load HTML data
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:nil documentAttributes:NULL];
    
    NSString *plainString = [string string];
    NSRegularExpression *regUnicodeBlank = [NSRegularExpression regularExpressionWithPattern:@"[\\u200b\\u200B]" options:0 error:NULL];
    
    NSMutableAttributedString *mutableAttributedString = [string mutableCopy];
    
    NSArray *results = [regUnicodeBlank matchesInString:plainString options:0 range:NSMakeRange(0, [plainString length])];
    
    for (NSInteger i = results.count - 1; i >= 0; i --) {
        NSTextCheckingResult *result = [results objectAtIndex:i];
        [mutableAttributedString deleteCharactersInRange:result.range];
    }
    
    return  [self parseAttributedContent:mutableAttributedString config:config];}

// 方法一
+ (CJWCoreTextData *)parseTemplateFile:(NSString *)path config:(CJWCFrameParserConfig*)config {
    NSMutableArray *imageArray = [NSMutableArray array];
    NSMutableArray *linkArray = [NSMutableArray array];
    NSAttributedString *content = [self loadTemplateFile:path config:config imageArray:imageArray linkArray:linkArray];
    CJWCoreTextData *data = [self parseAttributedContent:content config:config];
    data.imageArray = imageArray;
    data.linkArray = linkArray;
    data.content = content;
    return data;
}
// 方法二
+ (NSAttributedString *)loadTemplateFile:(NSString *)path config:(CJWCFrameParserConfig*)config imageArray:(NSMutableArray *)imageArray linkArray:(NSMutableArray *)linkArray{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    if (data) {
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
        if ([array isKindOfClass:[NSArray class]]) {
            for(NSInteger i = 0; i < array.count; i++) {
                NSDictionary *dict = array[i];
                NSString *type = dict[@"type"];
                if ([type isEqualToString:@"txt"]) {
                    if ([dict objectForKey:@"algin"] && i > 0) {
                         //拼接换行
                         [self appendPreLineStr:result];
                    }
                    NSAttributedString *as =
                    [self parseAttributedContentFromNSDictionary:dict
                                                          config:config];
                    [result appendAttributedString:as];
                    if ([dict objectForKey:@"algin"] && i > 0) {
                         //拼接换行
                         [self appendNewLineStr:i lineCount:array.count content:result];
                    }
                }else if ([type isEqualToString:@"img"]){
                    //拼接换行
//                    [self appendPreLineStr:result];
                    // 创建 CoreTextImageData
                    CJWCoreTextImageData *imageData = [[CJWCoreTextImageData alloc] init];
                    imageData.name = dict[@"name"];
                    imageData.position = (int)[result length];
                    [imageArray addObject:imageData];
                    // 创建空白占位符，并且设置它的 CTRunDelegate 信息
                    NSAttributedString *as = [self parseImageDataFromNSDictionary:dict config:config];
                    [result appendAttributedString:as];
                    //拼接换行
//                    [self appendNewLineStr:i lineCount:array.count content:result];
                }else if ([type isEqualToString:@"link"]){
                    NSUInteger startPos = result.length;
                    NSAttributedString *as =
                       [self parseAttributedContentFromNSDictionary:dict
                                                             config:config];
                    [result appendAttributedString:as];
                    NSUInteger length = result.length - startPos;
                    NSRange linkRange = NSMakeRange(startPos, length);
                    CJWCoreTextLinkData *linkData = [[CJWCoreTextLinkData alloc] init];
                    linkData.title = dict[@"content"];
                    linkData.url = dict[@"url"];
                    linkData.range = linkRange;
                    [linkArray addObject:linkData];
                    
                }
            }
        }
    }
    return result;
}
// 方法三
+ (NSAttributedString *)parseAttributedContentFromNSDictionary:(NSDictionary *)dict
                                                        config:(CJWCFrameParserConfig*)config {
    NSMutableDictionary *attributes = [self attributesWithConfig:config];
    // set color
    UIColor *color = [self colorFromTemplate:dict[@"color"]];
    if (color) {
        attributes[(id)kCTForegroundColorAttributeName] = (id)color.CGColor;
    }
    // set font size
    CGFloat fontSize = [dict[@"size"] floatValue];
    if (fontSize > 0) {
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        attributes[(id)kCTFontAttributeName] = (__bridge id)fontRef;
        CFRelease(fontRef);
    }
    //set algin
    if ([dict objectForKey:@"align"]) {
        NSDictionary *alignDic = @{@"left":@"0",@"right":@"1",@"center":@"2"};
        NSString *align = [alignDic objectForKey:[dict objectForKey:@"align"]];
        if (align.length) {
            NSInteger alignIndex = [align integerValue];
            [self setAlign:attributes alignment:alignIndex];
            
        }
    }
    //设置图片居中绘制
    if ([[dict objectForKey:@"type"] isEqualToString:@"img"]) {
        [self setAlign:attributes alignment:2];
    }
    NSString *content = dict[@"content"];
    return [[NSAttributedString alloc] initWithString:content attributes:attributes];
}

+ (void)setAlign:(NSMutableDictionary *)attributes alignment:(NSInteger)alignIndex{
    NSParameterAssert(attributes);
    NSParameterAssert(alignIndex);
    CTTextAlignment alignment = alignIndex;
    CTParagraphStyleSetting alignmentStyle;
    alignmentStyle.spec=kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
    alignmentStyle.valueSize=sizeof(alignment);
    alignmentStyle.value=&alignment;
    CTParagraphStyleRef paragrapStyle = CTParagraphStyleCreate(&alignmentStyle, sizeof(alignmentStyle ));
    attributes[(id)kCTParagraphStyleAttributeName] = (__bridge id)paragrapStyle;
    CFRelease(paragrapStyle);
}

// 方法四
+ (UIColor *)colorFromTemplate:(NSString *)name {
    if ([name isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    } else if ([name isEqualToString:@"red"]) {
        return [UIColor redColor];
    } else if ([name isEqualToString:@"black"]) {
        return [UIColor blackColor];
    } else {
        return nil;
    }
}
// 方法五
+ (CJWCoreTextData *)parseAttributedContent:(NSAttributedString *)content config:(CJWCFrameParserConfig*)config {
    // 创建 CTFramesetterRef 实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    // 获得要缓制的区域的高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    // 生成 CTFrameRef 实例
    CTFrameRef frame = [self createFrameWithFramesetter:framesetter config:config height:textHeight];
    // 将生成好的 CTFrameRef 实例和计算好的缓制高度保存到 CoreTextData 实例中，最后返回 CoreTextData 实例
    CJWCoreTextData *data = [[CJWCoreTextData alloc] init];
    data.ctFrame = frame;
    data.height = textHeight;
    // 释放内存
    CFRelease(frame);
    CFRelease(framesetter);
    return data;
}
// 方法六
+ (CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter
                                  config:(CJWCFrameParserConfig *)config
                                  height:(CGFloat)height {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}

#pragma mark - 解析图片
static CGFloat ascentCallback(void *ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}
static CGFloat descentCallback(void *ref){
    return 0;
}
static CGFloat widthCallback(void* ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}

+ (NSAttributedString *)parseImageDataFromNSDictionary:(NSDictionary *)dict
                                                config:(CJWCFrameParserConfig*)config {
    
  /*
  设置一个回调结构体，告诉代理该回调那些方法
  */
    CTRunDelegateCallbacks callBacks;//创建一个回调结构体，设置相关参数
    //memset将已开辟内存空间 callbacks 的首 n 个字节的值设为值 0, 相当于对CTRunDelegateCallbacks内存空间初始化
    memset(&callBacks, 0, sizeof(CTRunDelegateCallbacks));
    //设置回调版本，默认这个
    callBacks.version = kCTRunDelegateVersion1;
    callBacks.getAscent = ascentCallback;
    callBacks.getDescent = descentCallback;
    callBacks.getWidth = widthCallback;
    //创建代理
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callBacks, (__bridge void*)dict);
    //创建空白字符
    unichar placeHolde = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&placeHolde length:1];
    NSDictionary * attributes = [self attributesWithConfig:config];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return space;
}

+ (void)appendPreLineStr:(NSMutableAttributedString *)result{
    NSAttributedString *newline = [[NSAttributedString alloc] initWithString:@"\n"];
    if (result.length) {
        [result appendAttributedString:newline];
    }
}

+ (void)appendNewLineStr:(NSInteger)idx lineCount:(NSInteger)lineCount content:(NSMutableAttributedString *)result{
    NSAttributedString *newline = [[NSAttributedString alloc] initWithString:@"\n"];
    if (idx < lineCount - 1) {
        [result appendAttributedString:newline];
    }
}


@end
