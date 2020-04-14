//
//  NetworkAPI.m
//  JLLawFirm
//
//  Created by cai on 2017/8/10.
//  Copyright © 2017年 ai.cc. All rights reserved.
//

#import "NetworkAPI.h"
#import "NetworkManager.h"

@implementation NetworkAPI

- (instancetype)initWithURLString:(NSString *)URLString
                       HTTPMethod:(NetworkHTTPMethod)HTTPMethod
                       parameters:(id)parameters
{
    if (self = [super init]) {
        
        self.URLString = URLString;
        self.HTTPMethod = HTTPMethod;
        self.parameters = parameters;
        __weak typeof(self) weakSelf = self;
        self.notConnectionBlock = ^(NetworkAPI *API) {
//            Class cls = NSClassFromString(@"MBProgressHUD");
//            [cls performSelector:NSSelectorFromString(@"showError") withObject:@"当前网络状况不佳，请检查您的网络!"];
            [weakSelf showErrorObj:@"当前网络状况不佳，请检查您的网络!" obj2:[UIApplication sharedApplication].keyWindow];
        };
        self.failureBlock = ^(NetworkAPI *API) {
            if ([API.response.returnCode integerValue] == 104) {
                [weakSelf loginOut];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [MBProgressHUD showError:API.response.msg toView:[UIApplication sharedApplication].keyWindow];
                    [weakSelf showErrorObj:API.response.msg obj2:[UIApplication sharedApplication].keyWindow];

                });
                return;
            }
            if ([API.response.returnCode integerValue] != 100) {
                
                [weakSelf showErrorObj:API.response.msg obj2:[UIApplication sharedApplication].keyWindow];
            }
        };
    }
    return self;
}

- (void)showErrorObj:(id)obj1 obj2:(id)obj2{
    Class cls = NSClassFromString(@"MBProgressHUD");
    [cls performSelector:NSSelectorFromString(@"showError:toView:") withObject:obj1 withObject:obj2];
}


- (instancetype)initWithWholeURLString:(NSString *)URLString
                       HTTPMethod:(NetworkHTTPMethod)HTTPMethod
                       parameters:(id)parameters
{
    if (self = [super init]) {
        
        self.isWholeUrl = YES;
        self.URLString = URLString;
        self.HTTPMethod = HTTPMethod;
        self.parameters = parameters;
        
        __weak typeof(self) weakSelf = self;
        self.notConnectionBlock = ^(NetworkAPI *API) {
            [weakSelf showErrorObj:@"当前网络状况不佳，请检查您的网络!" obj2:[UIApplication sharedApplication].keyWindow];
        };
        self.failureBlock = ^(NetworkAPI *API) {
            if ([API.response.returnCode integerValue] == 104 || [API.response.code integerValue] == 300) {
                [weakSelf loginOut];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf showErrorObj:API.response.msg obj2:[UIApplication sharedApplication].keyWindow];
                });
                return;
            }
            if ([API.response.returnCode integerValue] != 100) {
                
                [weakSelf showErrorObj:API.response.msg obj2:[UIApplication sharedApplication].keyWindow];
            }
            if ([API.response.returnCode integerValue]) {
                [weakSelf showErrorObj:API.response.msg obj2:[UIApplication sharedApplication].keyWindow];
            }
            
        };
    }
    return self;
}

- (void)loginOut{
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGINOUT object:nil];
}


+ (instancetype)apiWithURLString:(NSString *)URLString
                      HTTPMethod:(NetworkHTTPMethod)HTTPMethod
                      parameters:(id)parameters
{
    return [self.alloc initWithURLString:URLString HTTPMethod:HTTPMethod parameters:parameters];
}

+ (instancetype)apiWithWholeURLString:(NSString *)URLString
                      HTTPMethod:(NetworkHTTPMethod)HTTPMethod
                      parameters:(id)parameters
{
    return [self.alloc initWithWholeURLString:URLString HTTPMethod:HTTPMethod parameters:parameters];
}


- (void)request
{
    [NetworkManager.sharedManager requestWithAPI:self];
}

- (void)completion:(NetworkBlock)completion
{
    self.completionBlock = completion;
    [self request];
}

- (BOOL)isRequestSuccess
{
    return _requestResult == NetworkRequestResultSuccess;
}

@end

@implementation NSArray (NetworkAPI)

- (void)n_syncCompletions:(NetworkBlocks)completions
{
    [NetworkManager.sharedManager syncRequestWithAPIs:self completions:completions];
}

- (void)n_asyncCompletions:(NetworkBlocks)completions
{
    [NetworkManager.sharedManager asyncRequestWithAPIs:self completions:completions];
}

@end
