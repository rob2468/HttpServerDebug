//
//  CJExhibitController.m
//  Closet
//
//  Created by chenjun on 2018/5/18.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "CJExhibitController.h"
#import "CJProductItemEditController.h"
#import "CJRootController.h"

static NSString * const kCollectionViewCellReuseIdentifier = @"kCollectionViewCellReuseIdentifier";

@interface CJExhibitCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIButton *editButton;

@end

@implementation CJExhibitCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        
        // editButton
        self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.editButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [self.editButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.editButton.hidden = YES;
        [self.contentView addSubview:self.editButton];
        
        [self.contentView addConstraints:
  @[[NSLayoutConstraint constraintWithItem:self.editButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-17],
    [NSLayoutConstraint constraintWithItem:self.editButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:20]]];
    }
    return self;
}

@end

@interface CJExhibitController ()
<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIButton *addProductButton; // 添加单品按钮
@property (strong, nonatomic) NSArray<NSString *> *dataList;

@end

@implementation CJExhibitController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataList = @[@"a", @"b", @"c"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // collectionView
    CGRect frame = self.view.bounds;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.pagingEnabled = YES;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[CJExhibitCollectionViewCell class] forCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier];
    
    // addProductButton
    self.addProductButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addProductButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.addProductButton.backgroundColor = [UIColor blueColor];
    [self.addProductButton addTarget:self action:@selector(addProductButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addProductButton];
    
    CGFloat kAddProductButtonEdgeLength = 50;
    self.addProductButton.layer.cornerRadius = kAddProductButtonEdgeLength / 2.0;
    self.addProductButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.addProductButton.layer.shadowOpacity = 0.5;
    self.addProductButton.layer.shadowOffset = CGSizeMake(0, 5);
    [self.view addConstraints:
  @[[NSLayoutConstraint constraintWithItem:self.addProductButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:-17],
    [NSLayoutConstraint constraintWithItem:self.addProductButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-17],
    [NSLayoutConstraint constraintWithItem:self.addProductButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0 constant:kAddProductButtonEdgeLength],
    [NSLayoutConstraint constraintWithItem:self.addProductButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:kAddProductButtonEdgeLength]]];
}

- (void)addProductButtonPressed {
    CJProductItemEditController *addController = [[CJProductItemEditController alloc] initWithProductItem:nil];
    //        addController.delegate = self
    CJRootController *rootController = [CJRootController fetchRootVC];
    [rootController presentViewController:addController animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
