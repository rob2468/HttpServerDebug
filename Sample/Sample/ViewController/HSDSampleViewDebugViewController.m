//
//  HSDSampleViewDebugViewController.m
//  Closet
//
//  Created by chenjun on 2018/5/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDSampleViewDebugViewController.h"

@interface HSDSampleViewDebugViewController ()

@end

@implementation HSDSampleViewDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect viewFrame = CGRectMake(10, 10, 100, 100);
    UIView *redView = [[UIView alloc] initWithFrame:viewFrame];
    redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:redView];
    
    viewFrame.origin.y = 120;
    UIView *greenView = [[UIView alloc] initWithFrame:viewFrame];
    greenView.backgroundColor = [UIColor greenColor];
    greenView.clipsToBounds = YES;
    [self.view addSubview:greenView];
    
    viewFrame = CGRectMake(10, 10, 100, 100);
    UIView *greenSubView = [[UIView alloc] initWithFrame:viewFrame];
    greenSubView.backgroundColor = [UIColor yellowColor];
    [greenView addSubview:greenSubView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
