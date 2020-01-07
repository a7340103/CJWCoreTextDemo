//
//  CJWCoreTextImageData.h
//  CJWCoreTextDemo
//
//  Created by djw on 2020/1/7.
//  Copyright © 2020年 djw.cc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJWCoreTextImageData : NSObject
@property (strong, nonatomic) NSString * name;
@property (nonatomic) int position;

// 此坐标是 CoreText 的坐标系，而不是UIKit的坐标系
@property (nonatomic) CGRect imagePosition;
@end

NS_ASSUME_NONNULL_END
