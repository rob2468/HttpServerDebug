//
//  CJCategoryManageCell.h
//  Closet
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CJCategoryManageCellDelegate;

@interface CJCategoryManageCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *deleteButton;
@property (weak, nonatomic) id<CJCategoryManageCellDelegate> delegate;

@end

@protocol CJCategoryManageCellDelegate <NSObject>

- (void)onManageCellDeleteButtonPressed:(CJCategoryManageCell *)cell;

@end
