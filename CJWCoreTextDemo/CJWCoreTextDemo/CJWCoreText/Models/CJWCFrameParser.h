//
//  CJWCFrameParser.h
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/7.
//  Copyright © 2020 djw.cc. All rights reserved.
// 用于生成最后绘制界面需要的CTFrameRef实

#import <Foundation/Foundation.h>
#import "CJWCoreTextData.h"
#import "CJWCFrameParserConfig.h"
#import "CJWCoreTextImageData.h"
#import "CJWCoreTextLinkData.h"

NS_ASSUME_NONNULL_BEGIN

@interface CJWCFrameParser : NSObject

+ (NSMutableDictionary *)attributesWithConfig:(CJWCFrameParserConfig *)config;
+ (CJWCoreTextData *)parseContent:(NSString *)content config:(CJWCFrameParserConfig*)config;
+ (CJWCoreTextData *)parseAttributedContent:(NSAttributedString *)content config:(CJWCFrameParserConfig*)config;
+ (CJWCoreTextData *)parseTemplateFile:(NSString *)path config:(CJWCFrameParserConfig*)config;
//显示html
+ (CJWCoreTextData *)parseHtml:(NSString *)localPath config:(CJWCFrameParserConfig*)config;

@end

NS_ASSUME_NONNULL_END
