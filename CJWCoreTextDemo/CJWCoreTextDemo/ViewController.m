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
@property (weak, nonatomic) IBOutlet CJWCDisplayView *display;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CJWCFrameParserConfig *config = [[CJWCFrameParserConfig alloc] init];
    config.textColor = [UIColor blackColor];
    config.width = self.display.width;
    NSString *content =
    @" 对于上面的例子，我们给 CTFrameParser 增加了一个将 NSString 转 "
     " 换为 CoreTextData 的方法。"
     " 但这样的实现方式有很多局限性，因为整个内容虽然可以定制字体 "
     " 大小，颜色，行高等信息，但是却不能支持定制内容中的某一部分。"
     " 例如，如果我们只想让内容的前三个字显示成红色，而其它文字显 "
     " 示成黑色，那么就办不到了。"
     "\n\n"
     " 解决的办法很简单，我们让`CTFrameParser`支持接受 "
     "NSAttributeString 作为参数，然后在 NSAttributeString 中设置好 "
     " 我们想要的信息。";
    NSDictionary *attr = [CJWCFrameParser attributesWithConfig:config];
    NSMutableAttributedString *attributedString =
         [[NSMutableAttributedString alloc] initWithString:content
                                                attributes:attr];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor redColor]
                             range:NSMakeRange(0, 7)];

    CJWCoreTextData *data = [CJWCFrameParser parseAttributedContent:attributedString
    config:config];
    self.display.data = data;
    self.display.height = data.height;
//    self.display.backgroundColor = [UIColor yellowColor];
    
}

//-(void)injected{
//    NSLog(@"I've been injected: %@", self);
//    //此处的代码想怎么写就怎么写，完事了按下Ctrl+S保存一下就能再模拟器里面看到刚刚改的代码了，是不是很神奇？
//    self.view.backgroundColor = [UIColor blueColor];
//}

@end
