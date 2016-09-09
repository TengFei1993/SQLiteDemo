//
//  MBTextField.m
//  高仿微博
//
//  Created by yangxiaofei on 16/3/7.
//  Copyright (c) 2016年 yangxiaofei. All rights reserved.
//

#import "MBSearchBar.h"
#import "UIView+Frame.h"

@implementation MBSearchBar

+ (instancetype)initWithString:(NSString *)placeStr
{
    //创建textField
    MBSearchBar *textField = [[self alloc] init];
    //textField.frame = CGRectMake(0, 0, 100, 100);
    textField.placeholder = placeStr;
//    UIImage *image = [UIImage imageWithStretchableName:@"searchbar_textfield_background"];
//    textField.background = image;
    
    //设置字体大小
    textField.font = [UIFont systemFontOfSize:13];
    
    //设置leftView,就是搜索镜那玩意
    //initWithImage：实例化UIImageView的方法，默认是UIImageView和图片的大小一样大
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchbar_textfield_search_icon"]];
    
    //图片居中显示
    imageView.contentMode = UIViewContentModeCenter;
    
    /*
     如图，当在UIImageView上添加UIImage，而且UIImage较小的话，设置了图片居中显示，如果显示效果看起来比较紧凑，则将UIImageView的宽度或者高度扩大一些就可以，显示效果会好好多
     */
    imageView.width += 10;
    
    textField.leftView = imageView;
    //UITextField，的左边控件要想显示，除了设置左边的控件以外，还要设置左边view的模式，一定要设置，要不然不会显示
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    return textField;
}

@end
