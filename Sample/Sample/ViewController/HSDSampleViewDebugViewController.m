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

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:scrollView];
    [scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 1000)];
    
    // redView
    CGRect viewFrame = CGRectMake(10, 10, 100, 100);
    UIView *redView = [[UIView alloc] initWithFrame:viewFrame];
    redView.backgroundColor = [UIColor redColor];
    [scrollView addSubview:redView];
    
    // greenView
    viewFrame.origin.y = 120;
    UIView *greenView = [[UIView alloc] initWithFrame:viewFrame];
    greenView.backgroundColor = [UIColor greenColor];
    greenView.clipsToBounds = YES;
    [scrollView addSubview:greenView];
    
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

    //
    viewFrame = CGRectMake(10, 230, 100, 100);
    UIView *view = [[UIView alloc] initWithFrame:viewFrame];
    view.backgroundColor = [UIColor darkGrayColor];
    [scrollView addSubview:view];

    for (NSInteger i = 0; i < 40; i++) {
        UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        tmpView.backgroundColor = [UIColor darkGrayColor];
        [view addSubview:tmpView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
