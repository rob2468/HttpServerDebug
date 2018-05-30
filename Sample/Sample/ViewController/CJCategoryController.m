//
//  CJCategoryController.m
//  Closet
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "CJCategoryController.h"
#import "CJCategoryDataModel.h"
#import "CJDBCategoryManager.h"
#import "CJCategoryManageController.h"

static NSString * const kCJCategoryTableViewCellReuseIdentifier = @"kCJCategoryTableViewCellReuseIdentifier";

@interface CJCategoryController ()
<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray<CJCategoryDataModel *> *dataList;

@end

@implementation CJCategoryController

- (instancetype)init {
    self = [super init];
    if (self) {
        // 数据库检索所有分类
        self.dataList = [CJDBCategoryManager fetchAllCategories];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"分类";
    
    // “管理”
    UIBarButtonItem *manageButton = [[UIBarButtonItem alloc] initWithTitle:@"管理" style:UIBarButtonItemStyleDone target:self action:@selector(manageButtonPressed)];
    self.navigationItem.rightBarButtonItem = manageButton;
    
    // tableView
    self.tableView = [[UITableView alloc] init];
    self.tableView.frame = self.view.bounds;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCJCategoryTableViewCellReuseIdentifier];
}

- (void)manageButtonPressed {
    CJCategoryManageController *manageController = [[CJCategoryManageController alloc] init];
    [self.navigationController pushViewController:manageController animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCJCategoryTableViewCellReuseIdentifier forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    CJCategoryDataModel *category = [self.dataList objectAtIndex:row];
    cell.textLabel.text = category.name;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
