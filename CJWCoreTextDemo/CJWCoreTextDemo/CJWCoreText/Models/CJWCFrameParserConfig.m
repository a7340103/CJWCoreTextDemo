//
//  CJWCFrameParserConfig.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/7.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import "CJWCFrameParserConfig.h"

@implementation CJWCFrameParserConfig

- (id)init{
    if (self == [super init]) {
        _width = 200.0f;
        _fontSize = 16.0f;
        _lineSpace = 8.0f;
        _textColor = RGB(108, 108, 108);
    }
    return self;
}

@end
