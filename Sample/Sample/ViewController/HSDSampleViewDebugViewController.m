//
//  HSDSampleViewDebugViewController.m
//  Closet
//
//  Created by chenjun on 2018/5/27.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDSampleViewDebugViewController.h"

#pragma mark - interface

@interface HSDSampleVDCase1Controller : UIViewController

@end

@interface HSDSampleVDCase2Controller : UIViewController

@end

#pragma mark - extension & implementation

@interface HSDSampleViewDebugViewController ()
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<NSString *> *dataList;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HSDSampleViewDebugViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataList = @[@"Case 1", @"Case 2"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"View Debug";

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSInteger row = [indexPath row];
    NSString *title = [self.dataList objectAtIndex:row];
    cell.textLabel.text = title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    NSString *title = [self.dataList objectAtIndex:row];
    if ([title isEqualToString:@"Case 1"]) {
        HSDSampleVDCase1Controller *vc = [[HSDSampleVDCase1Controller alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"Case 2"]) {
        HSDSampleVDCase2Controller *vc = [[HSDSampleVDCase2Controller alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


@interface HSDSampleVDCase1Controller ()

@end

@implementation HSDSampleVDCase1Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"View Debug Case 1";

    // redView
    CGRect viewFrame = CGRectMake(30, 135, 60, 50);
    UIView *redView = [[UIView alloc] initWithFrame:viewFrame];
    redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:redView];

    // greenView
    viewFrame = CGRectMake(30, 140, 70, 20);
    UIView *greenView = [[UIView alloc] initWithFrame:viewFrame];
    greenView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:greenView];
}

@end

@interface HSDSampleVDCase2Controller ()

@end

@implementation HSDSampleVDCase2Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"View Debug Case 2";

    // scrollView
    CGRect viewFrame = CGRectMake(10, 80, 200, 200);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:viewFrame];
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    scrollView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:scrollView];
    [scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 1000)];

    // redView
    viewFrame = CGRectMake(-40, -30, 60, 50);
    UIView *redView = [[UIView alloc] initWithFrame:viewFrame];
    redView.backgroundColor = [UIColor redColor];
    [scrollView addSubview:redView];
}

@end
