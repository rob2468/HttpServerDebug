//
//  HSDSampleCategoryEditController.m
//  Closet
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDSampleCategoryEditController.h"
#import "HSDSampleCategoryDataModel.h"
#import "HSDSampleDBCategoryManager.h"

static const CGFloat kHeaderContentViewHeight = 64.0;     // 头部引导视图高度

@interface HSDSampleCategoryEditController ()

// 视图
@property (strong, nonatomic) UIView *headerContentView;
@property (strong, nonatomic) UITextField *categoryNameTextField;

@property (strong, nonatomic) HSDSampleCategoryDataModel *category;

@end

@implementation HSDSampleCategoryEditController

- (instancetype)initWithCategory:(HSDSampleCategoryDataModel *)category {
    self = [super init];
    if (self) {
        self.category = category;
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
    
    // titleLabel
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:18];
    [self.headerContentView addSubview:titleLabel];
    
    [self.headerContentView addConstraints:
  @[[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.headerContentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.headerContentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:10]]];

    // "取消“
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.headerContentView addSubview:cancelButton];
    
     [self.headerContentView addConstraints:
  @[[NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.headerContentView attribute:NSLayoutAttributeLeading multiplier:1 constant:17],
    [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.headerContentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:10]]];

      // "保存"
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    doneButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [doneButton setTitle:@"保存" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.headerContentView addSubview:doneButton];

    [self.headerContentView addConstraints:
  @[[NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.headerContentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-17],
    [NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.headerContentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:10]]];

    
    // "分类名"
    UILabel *categoryNameLabel = [[UILabel alloc] init];
    categoryNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    categoryNameLabel.text = @"分类名：";
    categoryNameLabel.textColor = [UIColor blackColor];
    categoryNameLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:categoryNameLabel];
    
    [categoryNameLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:(UILayoutConstraintAxisHorizontal)];
    [self.view addConstraints:
  @[[NSLayoutConstraint constraintWithItem:categoryNameLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:17],
    [NSLayoutConstraint constraintWithItem:categoryNameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headerContentView attribute:NSLayoutAttributeBottom multiplier:1 constant:20]]];

    // categoryNameTextField
    self.categoryNameTextField = [[UITextField alloc] init];
    self.categoryNameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.categoryNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.categoryNameTextField];
    
    [self.view addConstraints:
  @[[NSLayoutConstraint constraintWithItem:self.categoryNameTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:categoryNameLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:self.categoryNameTextField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:-17],
    [NSLayoutConstraint constraintWithItem:self.categoryNameTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:categoryNameLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]]];
    
    // 根据初识“分类”更新视图
    if (self.category) {
        titleLabel.text = @"更新分类";
        self.categoryNameTextField.text = self.category.name;
    } else {
        titleLabel.text = @"新增分类";
    }
}

- (void)cancelButtonPressed {
    if ([self.delegate respondsToSelector:@selector(onCategoryEditControllerDismiss)]) {
        [self.delegate onCategoryEditControllerDismiss];
    }
}

- (void)doneButtonPressed {
    BOOL isSuccess = NO;
    // 解析用户输入
    NSString *categoryName = self.categoryNameTextField.text;
    categoryName = [categoryName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (categoryName.length > 0) {
        if (!self.category) {
            self.category = [[HSDSampleCategoryDataModel alloc] init];
        }
        self.category.name = categoryName;
        isSuccess = YES;
    }
    
    if (isSuccess) {
        if (self.category.ID == NSNotFound) {
            // 新增分类
            [HSDSampleDBCategoryManager addCategory:self.category];
        } else {
            // 更新分类
            [HSDSampleDBCategoryManager updateCategory:self.category];
        }
        if ([self.delegate respondsToSelector:@selector(onCategoryEditControllerDismiss)]) {
            [self.delegate onCategoryEditControllerDismiss];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
