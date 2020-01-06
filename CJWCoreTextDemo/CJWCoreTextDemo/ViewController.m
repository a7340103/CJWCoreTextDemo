//
//  ViewController.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/6.
//  Copyright © 2020 ai.cc. All rights reserved.
//

#import "ViewController.h"
#import "CJWCDisplayView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor = [UIColor redColor];
    
}

-(void)injected{
    NSLog(@"I've been injected: %@", self);
    //此处的代码想怎么写就怎么写，完事了按下Ctrl+S保存一下就能再模拟器里面看到刚刚改的代码了，是不是很神奇？
    self.view.backgroundColor = [UIColor blueColor];
}

@end
