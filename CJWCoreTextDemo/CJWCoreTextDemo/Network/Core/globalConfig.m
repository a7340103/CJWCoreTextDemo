//
//  globalConfig.m
//  AiYu
//
//  Created by Jiawei Dong on 2018/10/18.
//  Copyright © 2018年 ai.cc. All rights reserved.
//

#import "globalConfig.h"
#define formatPrefix @"https://www.ai.cc/"
#define testPrefix @"http://192.168.2.200/"

@interface globalConfig()

@property (nonatomic, strong) NSMutableDictionary *configDic;
@property (nonatomic, strong) NSDictionary *prefixDic;

@end

@implementation globalConfig
+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    static id __singleton__;
    dispatch_once( &once, ^{ __singleton__ = [[self alloc] init];
    } );
    return __singleton__;
}

- (NSMutableDictionary *)getConfigDic{
    return self.configDic;
}

- (void)setCustom:(NSDictionary *)dic{
    if (dic && [[dic allKeys] count]) {
        [self.configDic setValuesForKeysWithDictionary:dic];
    }
}

- (NSString *)getCurEnvEx:(NSString *)modelName{
    NSString *envKey = [self.configDic objectForKey:env] ?  : @"";
    if (envKey.length) {
        NSString *resutl = [[self.prefixDic objectForKey:modelName] objectForKey:envKey];
        return resutl;
    }
    return @"";
}



- (NSString *)getCurEnv{
    NSString *result = [self.configDic objectForKey:env] ?  : @"";
    if ([result isEqualToString:format]) {
        return formatPrefix;
    }
    if ([result isEqualToString:test]) {
        return testPrefix;
    }
    return @"";
}

- (NSMutableDictionary *)configDic{
    if(!_configDic){
        _configDic = [NSMutableDictionary dictionary];
    }
    return _configDic;
}

- (NSDictionary *)prefixDic{
    if (!_prefixDic) {
        _prefixDic = @{
                       @"QA":@{ format : @"https://ref.ai.cc/", test : @"http://192.168.2.200:88/"}
                      };
    }
    return _prefixDic;
}



@end
