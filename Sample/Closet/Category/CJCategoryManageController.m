//
//  CJCategoryManageController.m
//  Closet
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "CJCategoryManageController.h"
#import "CJCategoryEditController.h"
#import "CJCategoryManageCell.h"
#import "CJCategoryDataModel.h"
#import "CJDBCategoryManager.h"
#import "CJRootController.h"

static const CGFloat kHeaderContentViewHeight = 64.0;     // 头部引导视图高度
static const CGFloat kFooterContentViewHeight = 44.0;
static const CGFloat kAddButtonEdgeLength = 34.0;
static NSString * const kCollectionViewCellReuseIdentifier = @"kCollectionViewCellReuseIdentifier";

@interface CJCategoryManageController ()
<CJCategoryEditControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CJCategoryManageCellDelegate>

@property (strong, nonatomic) UIView *headerContentView;
@property (strong, nonatomic) UIView *footerContentView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray<CJCategoryDataModel *> *dataList;

@end

@implementation CJCategoryManageController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataList = [[CJDBCategoryManager fetchAllCategories] mutableCopy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // headerContentView
    self.headerContentView = [[UIView alloc] init];
    CGRect frame = self.view.bounds;
    frame.size.height = kHeaderContentViewHeight;
    self.headerContentView.frame = frame;
    self.headerContentView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.headerContentView];
     
    // “分类管理”
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.text = @"分类管理";
    titleLabel.textColor = [UIColor whiteColor];
    [self.headerContentView addSubview:titleLabel];

    [self.view addConstraints:
  @[[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.headerContentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.headerContentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:10]]];

    // "完成"
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    doneButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.headerContentView addSubview:doneButton];
    
    [self.view addConstraints:
     @[[NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.headerContentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-17],
       [NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]]];

    // footerContentView
    self.footerContentView = [[UIView alloc] init];
    frame = self.view.frame;
    frame.origin.y = frame.size.height - kFooterContentViewHeight;
    frame.size.height = kFooterContentViewHeight;
    self.footerContentView.frame = frame;
    self.footerContentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.footerContentView];

    // addButton
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.translatesAutoresizingMaskIntoConstraints = NO;
    UIColor *addButtonColor = [UIColor blackColor];
    addButton.layer.borderColor = addButtonColor.CGColor;
    addButton.layer.borderWidth = 1.0;
    addButton.layer.cornerRadius = kAddButtonEdgeLength / 2.0;
    [addButton setTitleColor:addButtonColor forState:UIControlStateNormal];
    [addButton setTitle:@"+" forState:UIControlStateNormal];
    addButton.titleLabel.font = [UIFont systemFontOfSize:25.0];
    [addButton addTarget:self action:@selector(addButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.footerContentView addSubview:addButton];

    [self.footerContentView addConstraints:
  @[[NSLayoutConstraint constraintWithItem:addButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.footerContentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:addButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.footerContentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:addButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.footerContentView attribute:NSLayoutAttributeWidth multiplier:0 constant:kAddButtonEdgeLength],
    [NSLayoutConstraint constraintWithItem:addButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.footerContentView attribute:NSLayoutAttributeHeight multiplier:0 constant:kAddButtonEdgeLength]]];

    // collectionView
    frame = self.view.bounds;
    frame.origin.y = kHeaderContentViewHeight;
    frame.size.height -= kHeaderContentViewHeight + kFooterContentViewHeight;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[CJCategoryManageCell class] forCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier];
}

// 重新读取分类数据，并刷新视图
- (void)reloadCollectionView {
    self.dataList = [[CJDBCategoryManager fetchAllCategories] mutableCopy];
    [self.collectionView reloadData];
}

- (void)doneButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addButtonPressed {
    [self showCategoryEditVC:nil];
}

- (void)showCategoryEditVC:(CJCategoryDataModel *)category {
    CJCategoryEditController *addController = [[CJCategoryEditController alloc] initWithCategory:category];
    addController.delegate = self;
    CJRootController *rootController = [CJRootController fetchRootVC];
    [rootController presentViewController:addController animated:YES completion:nil];
}

#pragma mark - CJCategoryEditControllerDelegate

- (void)onCategoryEditControllerDismiss {
    // 移除添加分类视图
    UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootController dismissViewControllerAnimated:YES completion:nil];
    
    // 重新加载数据并更新视图
    [self reloadCollectionView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CJCategoryManageCell *cell = (CJCategoryManageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    NSInteger item = indexPath.item;
    CJCategoryDataModel *category = [self.dataList objectAtIndex:item];
    cell.nameLabel.text = category.name;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = indexPath.item;
    CJCategoryDataModel *category = [self.dataList objectAtIndex:idx];
    [self showCategoryEditVC:category];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat top = 10.0f;
    CGFloat left = 17.0f;
    CGFloat bottom = 10.0f;
    CGFloat right = 17.0f;
    return UIEdgeInsetsMake(top, left, bottom, right);
}

#pragma mark - CJCategoryManageCellDelegate

- (void)onManageCellDeleteButtonPressed:(CJCategoryManageCell *)cell {
    NSIndexPath *idxPath = [self.collectionView indexPathForCell:cell];
    if (idxPath) {
        NSIndexPath *indexPath = idxPath;
        // 获取分类
        NSInteger item = indexPath.item;
        CJCategoryDataModel *category = [self.dataList objectAtIndex:item];
        NSInteger ID = category.ID;
        NSString *name = category.name;
        
        // 二次确认
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"确定删除分类“%@”？", name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancelAction];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (ID != NSNotFound) {
                NSInteger localID = ID;
                // 删除数据库中指定分类
                [CJDBCategoryManager deleteCategoryWithID:localID];
                // 删除内存中指定分类
                [self.dataList removeObjectAtIndex:item];
                // 更新视图
                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            }
        }];
        [alert addAction:confirmAction];
        CJRootController *rootController = [CJRootController fetchRootVC];
        [rootController presentViewController:alert animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
