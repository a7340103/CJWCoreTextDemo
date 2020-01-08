//
//  CJWCoreTextLinkData.h
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/1/8.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJWCoreTextLinkData : NSObject
@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * url;
@property (assign, nonatomic) NSRange range;
@end

NS_ASSUME_NONNULL_END
