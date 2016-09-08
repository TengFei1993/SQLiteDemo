//
//  TFContactVC.m
//  模糊查询demo
//
//  Created by yangxiaofei on 16/9/8.
//  Copyright (c) 2016年 yangxiaofei. All rights reserved.
//

#import "TFContactVC.h"
#import "TFContact.h"
#import "TFDataTool.h"

@interface TFContactVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameText;

@property (weak, nonatomic) IBOutlet UITextField *telText;
- (IBAction)done:(UIButton *)sender;
@end

@implementation TFContactVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)done:(UIButton *)sender {
    
    //获取姓名，和电话，写入数据库
    TFContact *contact = [[TFContact alloc] init];
    contact.name = self.nameText.text;
    contact.tel = self.telText.text;
    
    [[TFDataTool sharedTFDataTool] save:contact];
    
}
@end
