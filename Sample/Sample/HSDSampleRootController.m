//
//  HSDSampleRootController.m
//  Sample
//
//  Created by chenjun on 2018/4/23.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDSampleRootController.h"
#import "HSDSampleHomeViewController.h"

@interface HSDSampleRootController ()

@property (strong, nonatomic) UINavigationController *rootNav;

@end

@implementation HSDSampleRootController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    HSDSampleHomeViewController *homeController = [[HSDSampleHomeViewController alloc] init];
    self.rootNav = [[UINavigationController alloc] initWithRootViewController:homeController];
    self.rootNav.view.frame = self.view.bounds;
    self.rootNav.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.rootNav.view];
}

+ (HSDSampleRootController *)fetchRootVC {
    HSDSampleRootController *rootController = (HSDSampleRootController *)UIApplication.sharedApplication.keyWindow.rootViewController;
    return rootController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
