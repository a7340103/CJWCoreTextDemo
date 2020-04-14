//
//  globalConfig.h
//  AiYu
//
//  Created by Jiawei Dong on 2018/10/18.
//  Copyright © 2018年 ai.cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#define env @"env"
#define format @"format"
#define test @"test"

NS_ASSUME_NONNULL_BEGIN

@interface globalConfig : NSObject
+ (instancetype)sharedInstance;
- (NSMutableDictionary *)getConfigDic;
- (void)setCustom:(NSDictionary *)dic;
- (NSString *)getCurEnv;
- (NSString *)getCurEnvEx:(NSString *)modelName;
@end

NS_ASSUME_NONNULL_END
