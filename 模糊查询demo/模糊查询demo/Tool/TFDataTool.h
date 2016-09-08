//
//  TFDataTool.h
//  模糊查询demo
//
//  Created by yangxiaofei on 16/9/8.
//  Copyright (c) 2016年 yangxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
@class TFContact;

@interface TFDataTool : NSObject

singleton_interface(TFDataTool);

//存
- (void)save:(TFContact *)contact;

//取
- (NSArray *)getData;

//模糊查询
- (NSArray *)select:(NSString *)name;

@end
