//
//  CJCategoryManageCell.m
//  Closet
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "CJCategoryManageCell.h"

@implementation CJCategoryManageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        
        // nameLabel
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.nameLabel];
        
        [self.contentView addConstraints:
  @[[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
    [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-5]]];
        
        // deleteButton
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.deleteButton setTitle:@"X" forState:UIControlStateNormal];
        [self.deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.deleteButton];

        [self.contentView addConstraints:
         @[[NSLayoutConstraint constraintWithItem:self.deleteButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
           [NSLayoutConstraint constraintWithItem:self.deleteButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]]];
    }
    return self;
}

- (void)deleteButtonPressed {
    if ([self.delegate respondsToSelector:@selector(onManageCellDeleteButtonPressed:)]) {
        [self.delegate onManageCellDeleteButtonPressed:self];
    }
}

@end
