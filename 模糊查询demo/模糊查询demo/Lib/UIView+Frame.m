//
//  UIView+Frame.m
//  高仿微博
//
//  Created by yangxiaofei on 16/3/6.
//  Copyright (c) 2016年 yangxiaofei. All rights reserved.
//
/*
 给UIView增加分类的作用是：当想要获取一个继承自UIView的控件的时候，得要.好大一串才能点出来，现在将.语法封装好，用的时候直接.就可以
 注意：如果在分类（类别，category）里面增加一个成员属性的话，必须得给这个成员属性的setter和getter方法一个实现，否则会报错
 
 */

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (void)setX:(CGFloat)x
{
    //注意点：在这里，不能直接对CGFolat类型的和结构体类型的数据直接赋值，应该采用如下的间接的方式
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    //注意点：在这里，不能直接对CGFolat类型的和结构体类型的数据直接赋值，应该采用如下的间接的方式
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    //注意点：在这里，不能直接对CGFolat类型的和结构体类型的数据直接赋值，应该采用如下的间接的方式
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    //注意点：在这里，不能直接对CGFolat类型的和结构体类型的数据直接赋值，应该采用如下的间接的方式
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

@end
