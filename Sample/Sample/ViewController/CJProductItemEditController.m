//
//  CJProductItemEditController.m
//  Closet
//
//  Created by chenjun on 2018/5/16.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "CJProductItemEditController.h"
#import "CJProductItemDataModel.h"
#import "CJDBProductItemManager.h"

static CGFloat kHeaderContentViewHeight = 64.0;     // 头部引导视图高度

@protocol CJProductItemEditControllerDelegate <NSObject>

- (void)onProductItemEditControllerDismiss;

@end

@interface CJProductItemEditController ()

@property (strong, nonatomic) UIView *headerContentView; // 头部
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView; // 内容
@property (strong, nonatomic) UITextField *nameTextField; // 单品名称输入框
@property (weak, nonatomic) id<CJProductItemEditControllerDelegate> delegate;
@property (strong, nonatomic) CJProductItemDataModel *productItem;

@end

@implementation CJProductItemEditController

- (instancetype)initWithProductItem:(CJProductItemDataModel *)productItem {
    self = [super init];
    if (self) {
        self.productItem = productItem;
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
    
     // scrollView
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];

    // contentView
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.contentView];


    [self.view addConstraints:
  @[[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headerContentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]]];
    [self.view addConstraints:
  @[[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]]];
    [self.view addConstraints:
  @[[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]]];

    // "单品名"
    UILabel *productItemNameLabel = [[UILabel alloc] init];
    productItemNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    productItemNameLabel.text = @"单品名：";
    productItemNameLabel.textColor = [UIColor blackColor];
    productItemNameLabel.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:productItemNameLabel];
    
    [productItemNameLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:(UILayoutConstraintAxisHorizontal)];
    [self.view addConstraints:
  @[[NSLayoutConstraint constraintWithItem:productItemNameLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:17],
    [NSLayoutConstraint constraintWithItem:productItemNameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:20]]];

    // nameTextField
    self.nameTextField = [[UITextField alloc] init];
    self.nameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.contentView addSubview:self.nameTextField];

    [self.view addConstraints:
  @[[NSLayoutConstraint constraintWithItem:self.nameTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:productItemNameLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:self.nameTextField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-17],
    [NSLayoutConstraint constraintWithItem:self.nameTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:productItemNameLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]]];
    
     // contentView设置bottom约束
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:productItemNameLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:20]];
    
    if (self.productItem) {
        titleLabel.text = @"更新单品";
    } else {
        titleLabel.text = @"添加单品";
    }
}

- (void)cancelButtonPressed {
    UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonPressed {
    BOOL isSuccess = NO;
    // 解析用户输入
    NSString *name = self.nameTextField.text;
    NSString *productName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (productName.length == 0) {
        if (!self.productItem) {
            self.productItem = [[CJProductItemDataModel alloc] init];
        }
        self.productItem.name = productName;
        isSuccess = YES;
    }
    
    if (isSuccess) {
        if (self.productItem.ID == NSNotFound) {
            // 新增单品
            [CJDBProductItemManager addProductItem:self.productItem];
        } else {
            // 更新单品
            
        }
        
        // 退出当前页面
        UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [rootController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
