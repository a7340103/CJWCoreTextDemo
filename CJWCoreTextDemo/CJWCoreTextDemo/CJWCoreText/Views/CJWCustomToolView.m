//
//  CJWCustomToolView.m
//  CJWCoreTextDemo
//
//  Created by djw on 2020/1/9.
//  Copyright © 2020年 djw.cc. All rights reserved.
//

#import "CJWCustomToolView.h"

@interface CJWCustomToolView ()
@property (nonatomic, strong) UIButton *clickButton;
@end

@implementation CJWCustomToolView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor redColor];
        [self createContent:frame];
    }
    return self;
}

- (void)createContent:(CGRect)frame{
    UIButton *butoon = [[UIButton alloc]initWithFrame:frame];
    butoon.backgroundColor = [UIColor whiteColor];
    [butoon setTitle:@"点赞" forState:UIControlStateNormal];
    [butoon setFont:[UIFont systemFontOfSize:12]];
    [butoon setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [butoon addTarget:self action:@selector(clickForSuggest) forControlEvents:UIControlEventTouchUpInside];
    butoon.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    _clickButton = butoon;
    [self addSubview:butoon];
}

- (void)clickForSuggest{
    NSLog(@"工具栏点赞");
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

@end
