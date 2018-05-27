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

static const CGFloat kPannelViewWidth = 280.0; // 分类面板宽度
static const CGFloat kHeaderContentViewHeight = 64.0; // 头部引导视图高度
static NSString * const kCJCategoryTableViewCellReuseIdentifier = @"kCJCategoryTableViewCellReuseIdentifier";

@interface CJCategoryController ()
<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIView *pannelView;
@property (strong, nonatomic) UIView *headerContentView;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIButton *closeButton;
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
    self.view.backgroundColor = [UIColor clearColor];
    
    // pannelView
    self.pannelView = [[UIView alloc] init];
    CGRect frame = self.view.bounds;
    frame.origin.x = -kPannelViewWidth;
    frame.size.width = kPannelViewWidth;
    self.pannelView.frame = frame;
    self.pannelView.backgroundColor = [UIColor whiteColor];
    self.pannelView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.pannelView];
    
    // headerContentView
    self.headerContentView = [[UIView alloc] init];
    frame = self.pannelView.bounds;
    frame.size.height = kHeaderContentViewHeight;
    self.headerContentView.frame = frame;
    self.headerContentView.backgroundColor = [UIColor lightGrayColor];
    [self.pannelView addSubview:self.headerContentView];
    
    // “分类”
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.text = @"分类";
    titleLabel.textColor = [UIColor whiteColor];
    [self.headerContentView addSubview:titleLabel];
    
    [self.headerContentView addConstraints:
  @[[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.headerContentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.headerContentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:10]]];
    
    // “管理“
    UIButton *manageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    manageButton.translatesAutoresizingMaskIntoConstraints = NO;
    [manageButton setTitle:@"管理" forState:UIControlStateNormal];
    manageButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [manageButton addTarget:self action:@selector(manageButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.headerContentView addSubview:manageButton];
    
    [self.headerContentView addConstraints:
  @[[NSLayoutConstraint constraintWithItem:manageButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.headerContentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-17],
    [NSLayoutConstraint constraintWithItem:manageButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]]];
    
    // tableView
    self.tableView = [[UITableView alloc] init];
    frame = self.pannelView.bounds;
    frame.origin.y = kHeaderContentViewHeight;
    frame.size.height -= kHeaderContentViewHeight;
    self.tableView.frame = frame;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.pannelView addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCJCategoryTableViewCellReuseIdentifier];
    
    // closeButton
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.backgroundColor = [UIColor clearColor];
    frame = self.view.bounds;
    frame.origin.x = kPannelViewWidth;
    frame.size.width -= kPannelViewWidth;
    self.closeButton.frame = frame;
    [self.closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.3 animations:^{
        // 渐现
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        // 平移
        CGRect frame = self.pannelView.frame;
        frame.origin.x = 0;
        self.pannelView.frame = frame;
    }];
}

- (void)closeButtonPressed {
    [UIView animateWithDuration:0.2 animations:^{
        // 渐隐
        self.view.backgroundColor = [UIColor clearColor];
        // 平移
        CGRect frame = self.pannelView.frame;
        frame.origin.x = -kPannelViewWidth;
        self.pannelView.frame = frame;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(closePannel)]) {
            [self.delegate closePannel];
        }
    }];
}

- (void)manageButtonPressed {
    if ([self.delegate respondsToSelector:@selector(closePannel)]) {
        [self.delegate closePannel];
    }
    if ([self.delegate respondsToSelector:@selector(showCategoryManage)]) {
        [self.delegate showCategoryManage];
    }
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
