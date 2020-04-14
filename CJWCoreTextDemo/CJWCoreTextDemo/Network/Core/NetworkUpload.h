//
//  NetworkUpload.h
//  JLLawFirm
//
//  Created by cai on 2017/8/10.
//  Copyright © 2017年 ai.cc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkUpload : NSObject

@property (copy, nonatomic) NSData *data;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *mimeType;

/**
 上传接口

 @param data 图片数据
 @param name 需和服务端保持一致, 上传数据的key
 @param fileName 文件名称
 @param mimeType 文件类型
 */
- (instancetype)initWithData:(NSData *)data
                        name:(NSString *)name
                    fileName:(NSString *)fileName
                    mimeType:(NSString *)mimeType;

@end
