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
@property (strong, nonatomic) CJWCDisplayView *display;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];

    CJWCFrameParserConfig *config = [[CJWCFrameParserConfig alloc] init];
    config.width = self.display.width;
    CJWCoreTextData *data = [CJWCFrameParser parseTemplateFile:path config:config];
    self.display.data = data;
    self.display.height = data.height;
    self.display.backgroundColor = [UIColor yellowColor];
//    self.display.delegate = self;
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"test4" ofType:@"html"];
//    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    // Load HTML data
//    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
//    CGSize maxImageSize = CGSizeMake(300 , MAXFLOAT);
//
//    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//
//                                    [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
//
//                                    nil];
//
//    NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
//    self.display.attributedString = string;
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

#pragma mark - DTAttributedTextContentViewDelegate
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame{
    if([attachment isKindOfClass:[DTImageTextAttachment class]])
    {
        NSString *imageURL = [NSString stringWithFormat:@"%@", attachment.contentURL];
        
        CGRect rect = {{(kScreenWidth - frame.size.width )/2.0, frame.origin.y},frame.size};
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
                    imageView.image = [self DTAnimatedGIFFromData:gifData];
                });
            });
        }

        return imageView;
        
    }
    return nil;
}

-(UIImage *) DTAnimatedGIFFromData:(NSData *)data
{
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
    
    if (!source)
    {
        return nil;
    }

    UIImage *image = [self DTAnimatedGIFFromImageSource:source];
    CFRelease(source);
    
    return image;
}

- (UIImage *)DTAnimatedGIFFromImageSource:(CGImageSourceRef )source
{
    size_t const numImages = CGImageSourceGetCount(source);
    
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numImages];
    
    // determine gretest common factor of all image durations
    NSUInteger greatestCommonFactor = [self DTAnimatedGIFFrameDurationForImageAtIndex:source index:0];
    
    for (NSUInteger i=1; i<numImages; i++)
    {
        NSUInteger centiSecs = [self DTAnimatedGIFFrameDurationForImageAtIndex:source index:i];
        greatestCommonFactor = [self DTAnimatedGIFGreatestCommonFactor:greatestCommonFactor num2:centiSecs];
    }
    
    // build array of images, duplicating as necessary
    for (NSUInteger i=0; i<numImages; i++)
    {
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
        UIImage *frame = [UIImage imageWithCGImage:cgImage];
        
        NSUInteger centiSecs = [self DTAnimatedGIFFrameDurationForImageAtIndex:source index:i];
        NSUInteger repeat = centiSecs/greatestCommonFactor;
        
        for (NSUInteger j=0; j<repeat; j++)
        {
            [frames addObject:frame];
        }
        
        CGImageRelease(cgImage);
    }
    
    // create animated image from the array
    NSTimeInterval totalDuration = [frames count] * greatestCommonFactor / 100.0;
    return [UIImage animatedImageWithImages:frames duration:totalDuration];
}

- (NSUInteger) DTAnimatedGIFFrameDurationForImageAtIndex:(CGImageSourceRef) source index:(NSUInteger) index
{
    NSUInteger frameDuration = 10;
    
    NSDictionary *frameProperties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source,index,nil));
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    
    if(delayTimeUnclampedProp)
    {
        frameDuration = [delayTimeUnclampedProp floatValue]*100;
    }
    else
    {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        
        if(delayTimeProp)
        {
            frameDuration = [delayTimeProp floatValue]*100;
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 1)
    {
        frameDuration = 10;
    }
    
    return frameDuration;
}

// returns the great common factor of two numbers
- (NSUInteger) DTAnimatedGIFGreatestCommonFactor:(NSUInteger) num1 num2:(NSUInteger) num2
{
    NSUInteger t, remainder;
    
    if (num1 < num2)
    {
        t = num1;
        num1 = num2;
        num2 = t;
    }
    
    remainder = num1 % num2;
    
    if (!remainder)
    {
        return num2;
    }
    else
    {
        return [self DTAnimatedGIFGreatestCommonFactor:num2 num2:remainder];
    }
}



@end
