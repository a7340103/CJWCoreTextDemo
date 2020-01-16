//
//  ViewController.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/6.
//  Copyright © 2020 ai.cc. All rights reserved.
//

#import "ViewController.h"
#import "CJWCDisplayView.h"

@interface ViewController ()<DTAttributedTextContentViewDelegate>
@property (strong, nonatomic) DTAttributedTextContentView *display;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
//    CJWCFrameParserConfig *config = [[CJWCFrameParserConfig alloc] init];
//    config.width = self.display.width;
//    CJWCoreTextData *data = [CJWCFrameParser parseHtml:@"test3" config:config];
//    self.display.data = data;
//    self.display.height = data.height;
    self.display.backgroundColor = [UIColor yellowColor];
    self.display.delegate = self;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test3" ofType:@"html"];
    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    // Load HTML data
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    CGSize maxImageSize = CGSizeMake(300 , MAXFLOAT);

    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   
                                    [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
                                  
                                    nil];

    NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
    self.display.attributedString = string;
}

- (DTAttributedTextContentView *)display{
    if (!_display) {
        CGRect rect = self.view.bounds;
        rect.origin.y = 200;
        _display = [[DTAttributedTextContentView alloc] initWithFrame:rect];
        
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

#pragma mark - DTAttributedTextContentViewDelegate
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame{
    if([attachment isKindOfClass:[DTImageTextAttachment class]])
    {
        NSString *imageURL = [NSString stringWithFormat:@"%@", attachment.contentURL];
        CGRect rect = {{(frame.size.width - 2)/2.0, (frame.size.height - 2)/2.0},frame.size};
//        CGRect rect = CGRectMake((frame.size.width - 2)/2.0, (frame.size.height - 2)/2.0, frame.size.width, fra)
        DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:rect];
        imageView.frame = rect;
//        imageView.delegate = self;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [(DTImageTextAttachment *)attachment image];
        imageView.url = attachment.contentURL;
        
        if ([imageURL containsString:@"gif"]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *gifData = [NSData dataWithContentsOfURL:attachment.contentURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = DTAnimatedGIFFromData(gifData);
                });
            });
        }
        
        return imageView;
        
    }
    return nil;
}

@end
