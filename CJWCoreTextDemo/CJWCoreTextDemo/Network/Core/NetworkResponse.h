//
//  NetworkResponse.h
//  JLLawFirm
//
//  Created by cai on 2017/8/10.
//  Copyright © 2017年 ai.cc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkResponse : NSObject

@property (copy, nonatomic) NSString *returnCode;
@property (copy, nonatomic) NSString *msg;
@property (assign, nonatomic) BOOL secure;
@property (strong, nonatomic) id data;
@property (copy, nonatomic) NSString *code;


@property (readonly) BOOL isSuccessful;

@end
