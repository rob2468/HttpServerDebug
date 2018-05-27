//
//  CJCategoryController.h
//  Closet
//
//  Created by chenjun on 2018/5/17.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CJCategoryControllerDelegate;

@interface CJCategoryController : UIViewController

@property (weak, nonatomic) id<CJCategoryControllerDelegate> delegate;

@end

@protocol CJCategoryControllerDelegate <NSObject>

- (void)closePannel;

- (void)showCategoryManage;

@end
