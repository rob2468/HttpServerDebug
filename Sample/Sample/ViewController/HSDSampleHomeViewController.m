//
//  HSDSampleHomeViewController.m
//  Sample
//
//  Created by chenjun on 2018/4/26.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDSampleHomeViewController.h"
#import "HSDHttpServerControlPannelController.h"
#import "HSDSampleDBInspectViewController.h"
#import "HSDSampleViewDebugViewController.h"

static NSString * const kHSDCtrlPannel = @"HSD Control Pannel";
static NSString * const kHSDDatabaseInspect = @"Database Inspect";
static NSString * const kHSDViewDebug = @"View Debug";

@interface HSDSampleHomeViewController ()
<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (copy, nonatomic) NSArray<NSString *> *dataList;

@end

@implementation HSDSampleHomeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataList = @[kHSDCtrlPannel, kHSDDatabaseInspect, kHSDViewDebug];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"HSD";
    
    // tableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSInteger row = [indexPath row];
    NSString *title = [self.dataList objectAtIndex:row];
    cell.textLabel.text = title;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    NSString *title = [self.dataList objectAtIndex:row];
    if ([title isEqualToString:kHSDCtrlPannel]) {
        HSDHttpServerControlPannelController *vc = [[HSDHttpServerControlPannelController alloc] init];
        vc.backBlock = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:kHSDDatabaseInspect]) {
        HSDSampleDBInspectViewController *vc = [[HSDSampleDBInspectViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:kHSDViewDebug]) {
        HSDSampleViewDebugViewController *vc = [[HSDSampleViewDebugViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
