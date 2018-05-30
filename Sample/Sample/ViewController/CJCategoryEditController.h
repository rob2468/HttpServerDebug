//
//  CJCategoryEditController.h
//  Closet
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CJCategoryDataModel;
@protocol CJCategoryEditControllerDelegate;

@interface CJCategoryEditController : UIViewController

@property (weak, nonatomic) id<CJCategoryEditControllerDelegate> delegate;

- (instancetype)initWithCategory:(CJCategoryDataModel *)category;

@end

@protocol CJCategoryEditControllerDelegate <NSObject>

- (void)onCategoryEditControllerDismiss;

@end
