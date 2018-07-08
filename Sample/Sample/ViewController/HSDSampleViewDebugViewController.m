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
    self.title = @"View Debug";
    
    // redView
    CGRect viewFrame = CGRectMake(10, 10, 100, 100);
    UIView *redView = [[UIView alloc] initWithFrame:viewFrame];
    redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:redView];
    
    // greenView
    viewFrame.origin.y = 120;
    UIView *greenView = [[UIView alloc] initWithFrame:viewFrame];
    greenView.backgroundColor = [UIColor greenColor];
    greenView.clipsToBounds = YES;
    [self.view addSubview:greenView];
    
    // greenSubView1
    viewFrame = CGRectMake(110, 110, 100, 100);
    UIView *greenSubView1 = [[UIView alloc] initWithFrame:viewFrame];
    greenSubView1.backgroundColor = [UIColor purpleColor];
    [greenView addSubview:greenSubView1];
    
    // greenSubView2
    viewFrame = CGRectMake(10, 10, 100, 100);
    UIView *greenSubView2 = [[UIView alloc] initWithFrame:viewFrame];
    greenSubView2.backgroundColor = [UIColor yellowColor];
    [greenView addSubview:greenSubView2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
