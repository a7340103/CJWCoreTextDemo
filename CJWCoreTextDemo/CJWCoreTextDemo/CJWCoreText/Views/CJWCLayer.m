//
//  CJWCLayer.m
//  CJWCoreTextDemo
//
//  Created by djw on 2020/2/25.
//  Copyright © 2020年 djw.cc. All rights reserved.
//

#import "CJWCLayer.h"
#import <libkern/OSAtomic.h>

//@interface CJWCLayerSentinel ()
//@property (nonatomic, assign) NSInteger sentinel;
//@end
//
//@implementation CJWCLayerSentinel
//
//
//@end

static dispatch_queue_t CWCoreTextLayerGetDisplayQueue() {
#define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            for (NSUInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
                queues[i] = dispatch_queue_create("com.codeWicky.DWCoreTextLabel.render", attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.codeWicky.DWCoreTextLabel.render", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            }
        }
    });
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    uint32_t cur = (uint32_t)OSAtomicIncrement32(&counter);
#pragma clang diagnostic pop
    return queues[(cur) % queueCount];
#undef MAX_QUEUE_COUNT
}

@interface CJWCLayer ()
//@property (nonatomic,strong) CJWCLayerSentinel *sentinelObj;
@property (atomic, readonly) int32_t signal;
@property (nonatomic ,assign) BOOL displaysAsynchronously;

@end

@implementation CJWCLayer


- (instancetype)init{
    
    if (self = [super init]) {
        _signal = 0;
        _displaysAsynchronously = YES;

    }
    return self;
}

-(void)setNeedsDisplay
{
    [self cancelPreviousDisplayCalculate];
    [super setNeedsDisplay];
}

-(void)cancelPreviousDisplayCalculate
{
    [self signalIncrease];
}

-(void)signalIncrease
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    OSAtomicIncrement32(&_signal);
#pragma clang diagnostic pop
}

- (void)display{
    super.contents = super.contents;
    [self displayAsyn:YES];
}

static dispatch_queue_t CWCoreTextLayerGetReleaseQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

- (void)displayAsyn:(BOOL)async{
    
    if (!self.displayBlock) {
        self.contents = nil;
        return;
    }
    if (async) {
        int32_t signal = self.signal;
        BOOL (^isCancelled)(void) = ^BOOL(void) {
            return signal != self.signal;
        };
        CGSize size = self.bounds.size;
        BOOL opaque = self.opaque;
        CGFloat scale = self.contentsScale;
        CGColorRef backgroundColor = (opaque && self.backgroundColor) ? CGColorRetain(self.backgroundColor) : NULL;
        if (size.width < 1 || size.height < 1) {
            CGImageRef image = (__bridge_retained CGImageRef)(self.contents);
            self.contents = nil;
            if (image) {
                dispatch_async(CWCoreTextLayerGetReleaseQueue(), ^{
                    CFRelease(image);
                });
            }
            CGColorRelease(backgroundColor);
            return;
        }
        dispatch_async(CWCoreTextLayerGetDisplayQueue(), ^{
            if (isCancelled()) {
                CGColorRelease(backgroundColor);
                return;
            }
            UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            if (opaque) {
                fillContextWithColor(context, backgroundColor, size);
                CGColorRelease(backgroundColor);
            }
            //绘制
            self.displayBlock(context,isCancelled);
            if (isCancelled()) {
                UIGraphicsEndImageContext();
                return;
            }
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (isCancelled()) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!isCancelled()) {
                    self.contents = (__bridge id)(image.CGImage);
                }
            });
        });
    }
}

static inline void fillContextWithColor(CGContextRef context,CGColorRef color,CGSize size){
    CGContextSaveGState(context); {
        if (!color || CGColorGetAlpha(color) < 1) {
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
            CGContextFillPath(context);
        }
        if (color) {
            CGContextSetFillColorWithColor(context, color);
            CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
            CGContextFillPath(context);
        }
    } CGContextRestoreGState(context);
};

@end
