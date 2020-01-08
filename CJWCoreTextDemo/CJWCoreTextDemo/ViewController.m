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
@property (strong, nonatomic) CJWCDisplayView *display;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.

    CJWCFrameParserConfig *config = [[CJWCFrameParserConfig alloc] init];
    config.width = self.display.width;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    CJWCoreTextData *data = [CJWCFrameParser parseTemplateFile:path config:config];
    self.display.data = data;
    self.display.height = data.height;
    self.display.backgroundColor = [UIColor yellowColor];
    
}

- (CJWCDisplayView *)display{
    if (!_display) {
        CGRect rect = self.view.bounds;
        rect.origin.y = 200;
        _display = [[CJWCDisplayView alloc] initWithFrame:rect];
        
        _display.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_display];
    }
    return _display;
}

//-(void)injected{
//    NSLog(@"I've been injected: %@", self);
//    //此处的代码想怎么写就怎么写，完事了按下Ctrl+S保存一下就能再模拟器里面看到刚刚改的代码了，是不是很神奇？
//    self.view.backgroundColor = [UIColor blueColor];
//}

@end
