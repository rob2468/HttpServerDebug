//
//  CJHomeController.m
//  Closet
//
//  Created by chenjun on 2018/4/26.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "CJHomeController.h"
#import "CJCategoryController.h"
#import "CJCategoryManageController.h"
#import "HSDHttpServerControlPannelController.h"
#import "HSDSampleViewDebugViewController.h"

static NSString * const kHSDCtrlPannel = @"HSD Control Pannel";
static NSString * const kHSDViewDebug = @"View Debug";

@interface CJHomeController ()
<UITableViewDataSource, UITableViewDelegate, CJCategoryControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (copy, nonatomic) NSArray<NSString *> *dataList;

@property (strong, nonatomic) UIButton *expandButton;// 展开分类面板按钮
@property (strong, nonatomic) CJCategoryController *categoryController;// 分类面板视图控制器

@end

@implementation CJHomeController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataList = @[kHSDCtrlPannel, kHSDViewDebug];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"HSD";
    
    // tableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];

    // expandButton
    self.expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.expandButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.expandButton setTitle:@"展开分类" forState:UIControlStateNormal];
    [self.expandButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.expandButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.2f] forState:UIControlStateHighlighted];
    [self.expandButton addTarget:self action:@selector(expandButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.expandButton];
    
    [self.view addConstraints:[NSArray arrayWithObjects:[NSLayoutConstraint constraintWithItem:self.expandButton attribute:(NSLayoutAttributeLeading) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeLeading) multiplier:1 constant:17], [NSLayoutConstraint constraintWithItem:self.expandButton attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeTop) multiplier:1 constant:20], nil]];
}

- (void)expandButtonPressed {
    // 显示分类面板
    self.categoryController = [[CJCategoryController alloc] init];
    self.categoryController.delegate = self;
    self.categoryController.view.frame = self.view.bounds;
    self.categoryController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.categoryController.view];
    [self addChildViewController:self.categoryController];
}

- (void)closePannel {
    // 关闭分类面板
    [self.categoryController.view removeFromSuperview];
    self.categoryController = nil;
}

- (void)showCategoryManage {
    CJCategoryManageController *manageController = [[CJCategoryManageController alloc] init];
    [self.navigationController pushViewController:manageController animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSInteger row = [indexPath row];
    NSString *title = [self.dataList objectAtIndex:row];
    cell.textLabel.text = title;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    NSString *title = [self.dataList objectAtIndex:row];
    if ([title isEqualToString:kHSDCtrlPannel]) {
        HSDHttpServerControlPannelController *vc = [[HSDHttpServerControlPannelController alloc] init];
        vc.backBlock = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:kHSDViewDebug]) {
        HSDSampleViewDebugViewController *vc = [[HSDSampleViewDebugViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
