//
//  TFDataTool.m
//  模糊查询demo
//
//  Created by yangxiaofei on 16/9/8.
//  Copyright (c) 2016年 yangxiaofei. All rights reserved.
//

#import "TFDataTool.h"
#import "TFContact.h"
#import <sqlite3.h>

@interface TFDataTool ()

@property (nonatomic,strong) NSMutableArray *items;

@end

@implementation TFDataTool
singleton_implementation(TFDataTool);

static sqlite3 *_db;


- (NSMutableArray *)items
{
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

//1. 创建数据库
+ (void)initialize
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    NSString *filePath = [path stringByAppendingPathComponent:@"data.sqlite"];
    
    //打开数据库
    if(sqlite3_open(filePath.UTF8String, &_db) == SQLITE_OK){ //打开数据库成功
        //建表
        const char *sql = "create table if not exists t_contact (id integer primary key AUTOINCREMENT,name text,tel text);";
        char *error;
        sqlite3_exec(_db, sql, NULL, NULL, &error);
        if (!error) {
            //创表成功
            NSLog(@"创建表格成功");
        }else{
            //创表失败
            NSLog(@"创建表格失败");
        }
    }else{
        //打开数据库失败
        NSLog(@"打开数据库失败");
    }
}

//存
//直接不同项目不同处理，把模型对象作为参数传递插入到数据库中
- (void)save:(TFContact *)contact
{
    //往表格里面插入数据
    NSString *str = [NSString stringWithFormat:@"insert into t_contact (name,tel) values ('%@','%@');",contact.name,contact.tel];
    char *error;
    sqlite3_exec(_db, str.UTF8String, NULL, NULL, &error);
    if (error) {
       //插入失败
        NSLog(@"插入失败");
    }else{
        NSLog(@"插入成功");
    }
}

//取
- (NSArray *)getData
{
    //查询数据
    //注意：此处查询数据的时候不能盲目的全都查，只有有新数据的时候才执行查询操作，这样不用每次都查询一次数据库
    //下面是获取总的纪录数
    //1. 创建句柄 和 查询语句
    const char *sql = "select count(*) from t_contact;";
    sqlite3_stmt *stmt;
    int count = 0;
    
    //2. 准备查询
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) == SQLITE_OK) {
        //循环查询，一行一行的
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            //获取总的记录数
            count = sqlite3_column_int(stmt, 0);
            NSLog(@"count%d",count);
        }
    }
    
    NSMutableArray *array = [self.items mutableCopy];
    NSLog(@"self.items.count%ld",self.items.count);
    NSLog(@"array%ld",array.count);
    
    //有新数据，查询
    if (count > array.count) {
        [self.items removeAllObjects];
        //查询
        NSString *sql = [NSString stringWithFormat:@"select * from t_contact where t_contact.id > %ld;",array.count];
        // 句柄
        sqlite3_stmt *stmt1;
        
        //准备查询
        if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt1, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt1) == SQLITE_ROW) {
                
                TFContact *contact = [[TFContact alloc] init];
                contact.name = [NSString stringWithUTF8String:sqlite3_column_text(stmt1, 1)];
                contact.tel = [NSString stringWithUTF8String:sqlite3_column_text(stmt1, 2)];
                [self.items addObject:contact];
            }
        }
        NSLog(@"self.items.count%ld",self.items.count);
        return self.items;
    }else{
        return nil;
    }
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}


- (NSArray *)select:(NSString *)name
{
    NSMutableArray *arrays = [NSMutableArray array];
    
    NSString *str = [NSString stringWithFormat:@"select * from t_contact where t_contact.name LIKE '%%%@%%';",name];
    
    //句柄
    sqlite3_stmt *stmt;
    //准备
    if (sqlite3_prepare_v2(_db, str.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            TFContact *contact = [[TFContact alloc] init];
            contact.name = [NSString stringWithUTF8String:sqlite3_column_text(stmt, 1)];
            contact.tel = [NSString stringWithUTF8String:sqlite3_column_text(stmt, 2)];
            [arrays addObject:contact];
        }
    }
    return arrays;
}

@end
