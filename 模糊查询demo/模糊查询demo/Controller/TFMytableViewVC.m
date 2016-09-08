
//  TFMytableViewVC.m
//  模糊查询demo
//
//  Created by yangxiaofei on 16/9/7.
//  Copyright (c) 2016年 yangxiaofei. All rights reserved.
//

#import "TFMytableViewVC.h"
#import "MBSearchBar.h"
#import "UIView+Frame.h"
#import "TFContact.h"
#import "TFDataTool.h"
#import "TFContactVC.h"
#import "MJRefresh.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height


@interface TFMytableViewVC ()<UITextFieldDelegate>

@property (nonatomic,weak) UIButton *btn;

@property (nonatomic,strong) NSMutableArray *arrays;

@end

@implementation TFMytableViewVC

- (NSMutableArray *)arrays
{
    if (!_arrays) {
        _arrays = [NSMutableArray array];
    }
    return _arrays;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self.clearsSelectionOnViewWillAppear = NO;

//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self addtitleView];
    
    //
    [self addBtn];
    
    //刷新
    [self.tableView addHeaderWithTarget:self action:@selector(refresh)];
    
    //自动刷新
    [self.tableView headerBeginRefreshing];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.btn.hidden = NO;
}

/**添加中间标题*/
- (void)addtitleView
{
    MBSearchBar *search = [MBSearchBar initWithString:@"请输入要查找的名字"];
    search.delegate = self;
    search.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 35);
    search.layer.borderColor = [UIColor lightGrayColor].CGColor;
    search.layer.borderWidth = 1;
    
    search.layer.cornerRadius = 5;
    search.layer.masksToBounds = YES;
    
    self.navigationItem.titleView = search;
}

/**添加btn按钮*/
- (void)addBtn
{
    //添加添加联系人按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundColor:[UIColor redColor]];
    btn.frame = CGRectMake(50, 200, 160, 50);
    [btn setTitle:@"添加联系人" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow insertSubview:btn aboveSubview:self.tableView];
    //下面方式添加按钮的话，按钮会随着tablview滚动
    //    [self.view insertSubview:btn aboveSubview:self.tableView];
    
    //添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    
    [btn addGestureRecognizer:pan];
    _btn = btn;
}

- (void)refresh
{
    NSMutableArray *newItems = (NSMutableArray *)[[TFDataTool sharedTFDataTool] getData];
    
    NSLog(@"ssss%ld",newItems.count);

    if (newItems.count > 0) {
        for (int i = 0; i < newItems.count;i++) {
#warning 在表格中，为了保证新插入的数据显示在第一行，必须得用insertObject:newItems[i] atIndex:0方法，不断的累加在第一行插入，这样顺序才不会错
            [self.arrays insertObject:newItems[i] atIndex:0];
        }
        [self.tableView reloadData];
    }

    //1s后结束
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView headerEndRefreshing];
    });
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%ld",self.arrays.count);
    return self.arrays.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    TFContact *contact = self.arrays[indexPath.row];
    
    
    cell.textLabel.text = contact.name;
    cell.detailTextLabel.text = contact.tel;
    
    
    return cell;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //模糊查询
    NSArray *array = [[TFDataTool sharedTFDataTool] select:string];
    
    self.arrays = array;
    
    [self.tableView reloadData];
    
    return YES;
}

#pragma mark - 添加联系人按钮
- (void)addContact:(UIButton *)btn
{
    [btn setHidden:YES];
    
    NSLog(@"添加按钮");
    //往数据库添加数据
    TFContactVC *vc = [[TFContactVC alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
        
}

- (void)panView:(UIPanGestureRecognizer *)pan
{
    //图片的移动 ,因为这个是累加的，类似于放大，也要将移动的距离清0，加－ 清0  ，乘－－ 清1
    //    self.imageView.transform = CGAffineTransformTranslate(self.imageView.transform, point.x, point.y);
    //
    //    [pangesture setTranslation:CGPointZero inView:self.imageView];
    //
    //方法2，移动中心点的方法
    CGPoint changepoint = [pan translationInView:self.btn];
    CGPoint center = self.btn.center;
    center.x += changepoint.x;
    center.y += changepoint.y;
    
    self.btn.center = center;
    
    [pan setTranslation:CGPointZero inView:self.btn];
    
    NSLog(@"%@",NSStringFromCGRect(self.btn.frame));
    
    //判断btn的位置
    [self refreshBtnFrame:pan];
}

/**判断btn的位置的方法*/
- (void)refreshBtnFrame:(UIGestureRecognizer *)gesture
{
    //对btn的位置做一个判断
    CGPoint btnCenter = self.btn.center;
    
    CGFloat x = WIDTH - btnCenter.x;
    CGFloat y = HEIGHT - btnCenter.y;
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"手势结束");
        if (x < 0) { //超出右边界
            [UIView animateWithDuration:1.0 animations:^{
                self.btn.x = WIDTH - self.btn.width;
            }];
        }else if (x > WIDTH){//超出左边届
            [UIView animateWithDuration:1.0 animations:^{
                self.btn.x = 0;
            }];
        }
        if (y < 0) { //超出下边界
            [UIView animateWithDuration:1.0 animations:^{
                self.btn.y = HEIGHT - self.btn.height;
            }];
        }else if (y > HEIGHT){ // 超出上边界
            [UIView animateWithDuration:1.0 animations:^{
                self.btn.y = 0;
            }];
        }
    }
}

@end
