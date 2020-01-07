//
//  CJWCoreTextData.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/7.
//  Copyright © 2020 djw.cc. All rights reserved.
//  用于保存由CTFrameParser类生成的CTFrameRef实例以及CTFrameRef实际绘制需要的高度。

#import "CJWCoreTextData.h"

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

- (void)dealloc{
    if (_ctFrame != nil) {
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }
}

@end
