//
//  NetworkManager.h
//  JLLawFirm
//
//  Created by cai on 2017/8/10.
//  Copyright © 2017年 ai.cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkAPI.h"

@interface NetworkManager : NSObject

/**
 *  网络请求单例
 *
 *  @return manager
 */
+ (instancetype)sharedManager;

/**
 *  单个API的请求
 *
 *  @param API 要请求的API
 *
 */
- (void)requestWithAPI:(NetworkAPI *)API;

/**
 *  异步请求队列，队列所有API会同时请求
 *
 *  @param APIs        队列数组
 *  @param completions 全部完成之后的回调
 *
 */
- (void)asyncRequestWithAPIs:(NSArray<NetworkAPI *> *)APIs
                 completions:(NetworkBlocks)completions;

/**
 *  同步请求队列，队列中API按顺序依次请求
 *
 *  @param APIs        队列数组
 *  @param completions 全部完成之后的回调
 *
 */
- (void)syncRequestWithAPIs:(NSArray<NetworkAPI *> *)APIs
                completions:(NetworkBlocks)completions;


@end
