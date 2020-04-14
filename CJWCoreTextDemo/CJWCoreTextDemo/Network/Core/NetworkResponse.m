//
//  NetworkResponse.m
//  JLLawFirm
//
//  Created by cai on 2017/8/10.
//  Copyright © 2017年 ai.cc. All rights reserved.
//

#import "NetworkResponse.h"

@implementation NetworkResponse

- (NSString *)description
{
    return [NSString stringWithFormat:@"returnCode = %@ \nsecure = %d \nmsg = %@ \ndata = %@", _returnCode, _secure, _msg, _data];
}

- (BOOL)isSuccessful
{
    return _returnCode.integerValue == 200 || _code.integerValue == 200;
}

@end
