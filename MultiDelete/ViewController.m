//
//  ViewController.m
//  MultiDelete
//
//  Created by xudandan on 16/1/12.
//  Copyright © 2016年 wulian. All rights reserved.
//

#import "ViewController.h"
#import "CustomCell.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) NSMutableArray * dataArray;
@property (nonatomic,strong) NSMutableArray * deleteArray;
@property (nonatomic,assign) BOOL edit;
@end
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
@implementation ViewController {
    NSMutableArray * cellIndexArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeDeleteBtn];
    self.edit = NO;
    cellIndexArr = [NSMutableArray array];
    self.dataArray = [NSMutableArray array];
    self.deleteArray = [NSMutableArray array];
    [self createData];
    [self createTable];
    
}

-(void)createData {
    for (int i = 0; i < 100; i++) {
        NSString * str = [NSString stringWithFormat:@"%u",arc4random() % 10000 + 10000];
        [self.dataArray addObject:str];
    }
}

-(void)makeDeleteBtn {

    UIImage * image = [UIImage imageNamed:@"album_delete_normal@2x"];
    UIImage * newImage = [self resizeImageWithImage:image Width:25 Height:25];
    UIBarButtonItem * item1 = [[UIBarButtonItem alloc] initWithImage:[newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction:)];
    self.navigationItem.rightBarButtonItems = @[item1];
    
    
    
}

-(UIImage *)resizeImageWithImage:(UIImage *)image Width:(CGFloat)width Height:(CGFloat)height {
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage * newImage = [[UIImage alloc] init];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)back:(UIBarButtonItem *)item {
    self.edit = NO;
    
    [_tableView reloadData];
    UIBarButtonItem * item1 = self.navigationItem.rightBarButtonItems[0];
    self.navigationItem.rightBarButtonItems = @[item1];
    self.navigationItem.leftBarButtonItem = nil;
    [self.deleteArray removeAllObjects];
}

-(void)deleteAction:(UIBarButtonItem *)item1 {
    NSLog(@"删除");
    
    if (self.edit == NO) {
        self.edit = YES;
        UIBarButtonItem * item2 = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(SelectAll:)];
        item2.tintColor = [UIColor grayColor];
        self.navigationItem.rightBarButtonItems = @[item1,item2];
        
        UIBarButtonItem * itemLeft = [[UIBarButtonItem alloc] initWithImage:[self resizeImageWithImage:[UIImage imageNamed:@"返回"] Width:25 Height:25] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
        self.navigationItem.leftBarButtonItem = itemLeft;
        
        [_tableView reloadData];
    }else if (self.edit == YES && self.deleteArray.count > 0) {
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"删除消息" message:@"确定要删除所选消息吗?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"取消");
            [self.deleteArray removeAllObjects];
            UIBarButtonItem * item2 = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(SelectAll:)];
            item2.tintColor = [UIColor grayColor];
            self.navigationItem.rightBarButtonItems = @[item1,item2];
            [_tableView reloadData];
        }];
        
        UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            for (int i = 0; i < self.dataArray.count; i++) {
                NSString * data = self.dataArray[i];
                for (NSString * str in self.deleteArray) {
                    if (data == str) {
                        [self.dataArray replaceObjectAtIndex:i withObject:@"0"];
                    }
                }
            }
            [self.dataArray removeObject:@"0"];
            [self.deleteArray  removeAllObjects];
            self.edit = NO;
            [_tableView reloadData];
            for (NSIndexPath * indexPath in cellIndexArr) {
                CustomCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
                cell.accessCount = 0;
            }
        }];
        [alert addAction:action1];
        [alert addAction:action2];
        [self.navigationController presentViewController:alert animated:YES completion:^{
            
        }];
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = @[item1];
    }else {
        self.edit = NO;
        self.navigationItem.rightBarButtonItems = @[item1];
        [_tableView reloadData];
    }

    
}

-(void)SelectAll:(UIBarButtonItem *)item2 {
    item2.tintColor = [UIColor blueColor];
    self.deleteArray = [NSMutableArray arrayWithArray:self.dataArray];
    [_tableView reloadData];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonindex-----%ld",(long)buttonIndex);
    if (buttonIndex == 1) {
        for (int i = 0; i < self.dataArray.count; i++) {
            NSString * data = self.dataArray[i];
            for (NSString * str in self.deleteArray) {
                if (data == str) {
                    [self.dataArray replaceObjectAtIndex:i withObject:@"0"];
                }
            }
        }

        [self.dataArray removeObject:@"0"];
        [self.deleteArray  removeAllObjects];
        self.edit = NO;
        [_tableView reloadData];
        for (NSIndexPath * indexPath in cellIndexArr) {
            CustomCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
            cell.accessCount = 0;
        }
    }
}

-(void)createTable {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH , SCREEN_HEIGHT)];
    _tableView.backgroundColor = [UIColor grayColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

#pragma  mark - TableviewDataSource,TableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessCount = 0;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _dataArray[indexPath.row];
    if (self.edit) {
        int s = 0;
        NSLog(@"%@",self.deleteArray);
        for (NSString * str in self.deleteArray) {
            if (cell.textLabel.text == str) {
                UIImageView * selectImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
                selectImage.image = [UIImage imageNamed:@"main_safegurd_check_checked"];
                cell.accessoryView = selectImage;
                s = 1;
                cell.accessCount = 1;
            }
        }
        if (s == 0) {
            UIImageView * Image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
            Image.image = [UIImage imageNamed:@"main_safegurd_check_uncheck"];
            cell.accessoryView = Image;
            cell.accessCount = 0;
        }
        
        if (self.deleteArray.count < 1) {
            UIImageView * Image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
            Image.image = [UIImage imageNamed:@"main_safegurd_check_uncheck"];
            cell.accessoryView = Image;
        }
        
        
    }else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

#pragma mark - 编辑相关
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.edit && cell.accessCount == 0) {
        cell.accessCount = 1;
        [self.deleteArray addObject:cell.textLabel.text];
        [cellIndexArr addObject:indexPath];
    }else if (self.edit && cell.accessCount == 1) {
        cell.accessCount = 0;
        for (int i = 0; i < self.deleteArray.count; i++) {
            NSString * str = self.deleteArray[i];
            if (str == cell.textLabel.text) {
                [self.deleteArray replaceObjectAtIndex:i withObject:@"0"];
            }
        }
        [self.deleteArray removeObject:@"0"];
    }
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
