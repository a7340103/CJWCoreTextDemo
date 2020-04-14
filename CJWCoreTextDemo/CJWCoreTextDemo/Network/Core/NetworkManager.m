//
//  NetworkManager.m
//  JLLawFirm
//
//  Created by cai on 2017/8/10.
//  Copyright © 2017年 ai.cc. All rights reserved.
//

#import "NetworkManager.h"
#import "AFNetworking.h"

@interface NetworkManager ()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation NetworkManager

+ (instancetype)sharedManager
{
    static NetworkManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = NetworkManager.new;
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        [AFNetworkReachabilityManager.sharedManager startMonitoring];
//        AFNetworkActivityIndicatorManager.sharedManager.enabled = YES;
        
        _sessionManager = AFHTTPSessionManager.manager;
        _sessionManager.requestSerializer.timeoutInterval = 15;
        [_sessionManager.requestSerializer setValue:@"2" forHTTPHeaderField:@"platform"];
    }
    return self;
}

- (void)writeToFileAboutDealyRequest:(NSTimeInterval)interval API:(NetworkAPI *)API{
#ifdef DEBUG
    if (interval > 0.2) {
//        [[JWLog sharedInstance] writeUrlToLocalFile:@{@"url":API.fullURLString, @"params":API.parameters == nil ? @{}: API.parameters, @"interval" : @(interval)}];
    }
#endif
}

-(NSString*)getCurrentTimes{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];

    //现在时间,你可以输出来看下是什么格式

    NSDate *datenow = [NSDate date];

    //----------将nsdate按formatter格式转成nsstring

    NSString *currentTimeString = [formatter stringFromDate:datenow];

    NSLog(@"currentTimeString =  %@",currentTimeString);

    return currentTimeString;

}


- (void)requestWithAPI:(NetworkAPI *)API
{
    __weak typeof(self) weakSelf = self;
    NSString *URLString = API.fullURLString;
    id parameters = API.parameters;
    API.startTime = [self getCurrentTimes];
    NSTimeInterval startTime = NSDate.date.timeIntervalSince1970;
    
    id success = ^(NSURLSessionDataTask *task, id responseObject) {
        NSTimeInterval endTime = NSDate.date.timeIntervalSince1970;
        API.costTime = endTime - startTime;
        [weakSelf writeToFileAboutDealyRequest:API.costTime API:API];
        if ([NetworkResponse respondsToSelector:@selector(mj_objectWithKeyValues:)]) {
            API.response = [NetworkResponse performSelector:@selector(mj_objectWithKeyValues:) withObject:responseObject];
        }else{
            NSLog(@"Need Import MJEXTENSION Library");
            return;
        }
        if (API.response.isSuccessful) {
            API.requestResult = NetworkRequestResultSuccess;
        } else {
            API.requestResult = NetworkRequestResultFailure;
            if (API.failureBlock) {
                API.failureBlock(API);
            }
        }
        
        API.completionBlock(API);
    };
    
    id failure = ^(NSURLSessionDataTask *task, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NETWORKFAIL" object:@{@"obj":API, @"error":error}];
        NSTimeInterval endTime = NSDate.date.timeIntervalSince1970;
        API.costTime = endTime - startTime;
        API.error = error;
        API.requestResult = NetworkRequestResultNotConnection;
        
        if (API.notConnectionBlock) {
            API.notConnectionBlock(API);
        }
        
        API.completionBlock(API);
    };
    
    id progress = ^(NSProgress *progress) {
        NSTimeInterval endTime = NSDate.date.timeIntervalSince1970;
        API.costTime = endTime - startTime;
        API.progress = progress;
        if (API.progressBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                API.progressBlock(API);
            });
        }
    };
    
    id constructingBody = ^(id<AFMultipartFormData> formData) {
        for (NetworkUpload *upload in API.uploads) {
            [formData appendPartWithFileData:upload.data name:upload.name fileName:upload.fileName mimeType:upload.mimeType];
        }
    };
//    [[JWLog sharedInstance] setHTTPRequestStart:URLString params:parameters];
    switch (API.HTTPMethod) {
        case NetworkHTTPMethodGET:
            [_sessionManager GET:URLString parameters:parameters progress:progress success:success failure:failure];
            break;
        case NetworkHTTPMethodPOST:
            [_sessionManager POST:URLString parameters:parameters constructingBodyWithBlock:constructingBody progress:progress success:success failure:failure];
            break;
        case NetworkHTTPMethodPUT:
            [_sessionManager PUT:URLString parameters:parameters success:success failure:failure];
            break;
        case NetworkHTTPMethodDELETE:
            [_sessionManager DELETE:URLString parameters:parameters success:success failure:failure];
            break;
    }
}

- (void)asyncRequestWithAPIs:(NSArray<NetworkAPI *> *)APIs
                 completions:(NetworkBlocks)completions
{
    dispatch_group_t group = dispatch_group_create();
    for (NetworkAPI *api in APIs) {
        dispatch_group_enter(group);
        NetworkBlock completion = [api.completionBlock copy];
        [api completion:^(NetworkAPI *API) {
            if (completion) {
                completion(API);
            }
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completions) {
            completions(APIs);
        }
    });
}

- (void)syncRequestWithAPIs:(NSArray<NetworkAPI *> *)APIs
                completions:(NetworkBlocks)completions
{
    NSEnumerator *enumerator = APIs.objectEnumerator;
    [self requestWithAPIs:APIs completions:completions enumerator:enumerator];
}

- (void)requestWithAPIs:(NSArray<NetworkAPI *> *)APIs
            completions:(NetworkBlocks)completions
             enumerator:(NSEnumerator *)enumerator
{
    __weak NSArray<NetworkAPI *> *weakAPIs = APIs;
    NetworkAPI *api = enumerator.nextObject;
    
    if (api == nil) {
        completions(APIs);
        return;
    }
    
    NetworkBlock completion = [api.completionBlock copy];
    [api completion:^(NetworkAPI *API) {
        if (completion) {
            completion(API);
        }
        [self requestWithAPIs:weakAPIs completions:completions enumerator:enumerator];
    }];
}

- (void)setDevicetoken:(NSString *)devicetoken{
   NSString *str = [_sessionManager.requestSerializer valueForHTTPHeaderField:@"User-Agent"];
   NSString *now =  [str stringByAppendingString:[NSString stringWithFormat:@"/%@",devicetoken]];
    [_sessionManager.requestSerializer setValue:now forHTTPHeaderField:@"User-Agent"];
}

- (void)setPrefix:(NSDictionary *)params{
    
}

@end
