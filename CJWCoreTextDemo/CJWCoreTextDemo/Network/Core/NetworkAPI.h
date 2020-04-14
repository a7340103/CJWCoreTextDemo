//
//  NetworkAPI.h
//  JLLawFirm
//
//  Created by cai on 2017/8/10.
//  Copyright © 2017年 ai.cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkResponse.h"
#import "NetworkUpload.h"


typedef NS_ENUM(NSUInteger, NetworkHTTPMethod) {
    NetworkHTTPMethodGET,
    NetworkHTTPMethodPOST,
    NetworkHTTPMethodPUT,
    NetworkHTTPMethodDELETE,
};

typedef NS_ENUM(NSUInteger, NetworkRequestResult) {
    NetworkRequestResultSuccess,        //  请求结果为成功
    NetworkRequestResultFailure,        //  请求结果为失败
    NetworkRequestResultNotConnection   //  没有连接上服务器
};

#define LOGINOUT @"LOGINOUT"



@class NetworkAPI;

typedef void(^NetworkBlock)(NetworkAPI *API);
typedef void(^NetworkBlocks)(NSArray<NetworkAPI *> *APIs);

@interface NetworkAPI : NSObject

@property (strong, nonatomic) NSString *moduleName;
// url
@property (assign, nonatomic) BOOL isWholeUrl;

//  完整的请求地址
@property (readonly) NSString *fullURLString;
//  请求地址
@property (copy, nonatomic) NSString *URLString;
//  请求参数
@property (strong, nonatomic) id parameters;
//  请求方式
@property (assign, nonatomic) NetworkHTTPMethod HTTPMethod;
//  上传数组，上传文件的话需要实现这个数组
@property (copy, nonatomic) NSArray<NetworkUpload *> *uploads;

//  请求结果
@property (assign, nonatomic) NetworkRequestResult requestResult;
//  服务器返回的数据
@property (strong, nonatomic) NetworkResponse *response;
//  没有连接上的回调
@property (copy, nonatomic) NetworkBlock notConnectionBlock;
//  连接上但请求结果为失败的回调
@property (copy, nonatomic) NetworkBlock failureBlock;
//  请求完成的回调
@property (copy, nonatomic) NetworkBlock completionBlock;
//  请求进度的回调
@property (copy, nonatomic) NetworkBlock progressBlock;

//  请求进度
@property (strong, nonatomic) NSProgress *progress;
//请求开始的时间
@property (strong, nonatomic) NSString *startTime;
//  请求所花费的时间
@property (assign, nonatomic) NSTimeInterval costTime;
//  请求错误
@property (strong, nonatomic) NSError *error;

//  简便方法，是否请求成功
@property (readonly) BOOL isRequestSuccess;

// 服务器直接返回json
@property (strong, nonatomic) NSMutableDictionary *responseDic;

/**
 *  API便利构造器
 *
 *  @param URLString  请求地址
 *  @param HTTPMethod 请求方法
 *  @param parameters 请求参数
 *
 *  @return API
 */
+ (instancetype)apiWithURLString:(NSString *)URLString
                      HTTPMethod:(NetworkHTTPMethod)HTTPMethod
                      parameters:(id)parameters;

/**
 *  API便利构造器
 *
 *  @param URLString  完整请求地址
 *  @param HTTPMethod 请求方法
 *  @param parameters 请求参数
 *
 *  @return API
 */
+ (instancetype)apiWithWholeURLString:(NSString *)URLString
                      HTTPMethod:(NetworkHTTPMethod)HTTPMethod
                      parameters:(id)parameters;

/**
 *  API开始请求
 */
- (void)request;

/**
 *  简便方法，设置请求完成的回调，同时开始进行请求
 *
 *  @param completion  请求地址
 *
 */
- (void)completion:(NetworkBlock)completion;

@end



#pragma mark - 请求队列
@interface NSArray (NetworkAPI)

/**
 *  异步请求队列方法，队列里的API会同时请求
 *
 *  @param completions  全部完成之后的回调
 *
 */
- (void)n_asyncCompletions:(NetworkBlocks)completions;

/**
 *  同步请求队列方法，上一个API请求完之后才会请求下一个
 *
 *  @param completions  全部完成之后的回调
 *
 */
- (void)n_syncCompletions:(NetworkBlocks)completions;

@end
