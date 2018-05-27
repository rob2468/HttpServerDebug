//
//  CJRootController.m
//  Closet
//
//  Created by chenjun on 2018/4/23.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "CJRootController.h"
#import "CJHomeController.h"

@interface CJRootController ()

@property (strong, nonatomic) UINavigationController *rootNav;

@end

@implementation CJRootController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    CJHomeController *homeController = [[CJHomeController alloc] init];
    self.rootNav = [[UINavigationController alloc] initWithRootViewController:homeController];
    self.rootNav.view.frame = self.view.bounds;
    self.rootNav.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.rootNav.navigationBarHidden = YES;
    [self.view addSubview:self.rootNav.view];
}

+ (CJRootController *)fetchRootVC {
    CJRootController *rootController = (CJRootController *)UIApplication.sharedApplication.keyWindow.rootViewController;
    return rootController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
