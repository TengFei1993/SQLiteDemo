
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

/*搜索数组*/
@property (nonatomic,strong) NSMutableArray *arrs;

@property (nonatomic,weak) MBSearchBar *searchBar;

@end

@implementation TFMytableViewVC

- (NSMutableArray *)arrays
{
    if (!_arrays) {
        _arrays = [NSMutableArray array];
    }
    return _arrays;
}

//- (NSMutableArray *)arrs
//{
//    if (!_arrs) {
//        _arrs = [NSMutableArray array];
//    }
//    return _arrs;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self.clearsSelectionOnViewWillAppear = NO;

//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self addtitleView];
    
    //
    [self addBtn];
    
    //刷新
    [self.tableView addHeaderWithTarget:self action:@selector(refreshh)];
    
    //自动刷新
    [self.tableView headerBeginRefreshing];
    
    //注册一个通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
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
    _searchBar = search;
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

- (void)refreshh
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
    NSLog(@"self1%@",self.arrays);
    
    if (self.searchBar.isEditing == YES) {
        return self.arrs.count;
    }else{
        return self.arrays.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"self%@",self.arrays);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    
    
    TFContact *contact = self.arrays[indexPath.row];
    
    if (self.searchBar.isEditing == YES) {
        contact = self.arrs[indexPath.row];
    }
    
    NSLog(@"%@",contact);
    NSLog(@"%@",contact.name);
    
    cell.textLabel.text = contact.name;
    cell.detailTextLabel.text = contact.tel;
    
    
    return cell;
}

/*这个方法监听值的变化的时候有弊端，每次只能获取到一个字符，而且textField.text还获取不到，改用通知的方法*/
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"sssssvvvvv");
    
    NSLog(@"sadfasdfs---%@",textField.text);
    
    //模糊查询 -- 使用sql语言
    NSArray *array = [[TFDataTool sharedTFDataTool] select:string];
        self.arrays = (NSMutableArray *)array;
    
    NSLog(@"%@",string);
    
////    //使用谓词
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name contains [cd] %@",string];
//    
////    BOOL match = [predicate evaluateWithObject:self.arrays[0]];
//    
//    NSLog(@"xxx%d",self.arrs.count);
//    
//     [self.arrs filterUsingPredicate:predicate];
//    
//    self.arrays = self.arrs;
//    
    [self.tableView reloadData];
    
    return YES;
}
*/
- (void)textfieldChange:(NSNotification *)nofi
{
    NSLog(@"%s",__func__);
    
    NSLog(@"%@",self.searchBar.text);
    //模糊查询 -- 使用sql语言
//    NSArray *array = [[TFDataTool sharedTFDataTool] select:self.searchBar.text];
//    self.arrays = (NSMutableArray *)array;
    
    
    ////    //使用谓词

    if (self.searchBar.text.length != 0) {
        //清空搜索数组
        [self.arrs removeAllObjects];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name contains [cd]%@",self.searchBar.text];
    
    NSLog(@"self.arrs%ld",self.arrs.count);
    //
//    NSArray *arr = [self.arrays filteredArrayUsingPredicate:predicate];
    //
        
//        for (TFContact *contact in arr) {
//            NSLog(@"i%@",contact.name);
//        }
        
        
        self.arrs = [[NSMutableArray alloc] initWithArray:[self.arrays filteredArrayUsingPredicate:predicate]];
        int i = 0;
        for (TFContact *contact in self.arrays) {
            NSLog(@"%d,%@",i,contact.name);
            i++;
        }
        
        NSLog(@"sele.arrays%@",self.arrays);
    //
    }else{
        self.arrs = self.arrays;
    }
    [self.tableView reloadData];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}





@end
