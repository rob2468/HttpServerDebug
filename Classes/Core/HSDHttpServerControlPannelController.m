//
//  HSDHttpServerControlPannelController.m
//  HttpServerDebug
//
//  Created by chenjun on 18/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import "HSDHttpServerControlPannelController.h"
#import "HSDManager+Project.h"
#import "HSDDefine.h"

@interface HSDHttpServerControlPannelController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UISwitch *startSwitchView;

@property (strong, nonatomic) NSMutableString *logText;     // log string, shown in textView

@end

@implementation HSDHttpServerControlPannelController

- (instancetype)init {
    self = [super init];
    if (self) {
        // initialize log text
        self.logText = [[NSMutableString alloc] initWithString:@""];
        
        // add notification observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kHSDNotificationServerStarted object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kHSDNotificationServerStopped object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat top = statusBarHeight + 44;
    // header
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, top);
    headerView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:headerView];
    
    UILabel *headerTitleLabel = [[UILabel alloc] init];
    headerTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    headerTitleLabel.text = @"HSD";
    headerTitleLabel.textColor = [UIColor blackColor];
    headerTitleLabel.font = [UIFont systemFontOfSize:17];
    [headerView addSubview:headerTitleLabel];
    
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:headerTitleLabel attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:headerView attribute:(NSLayoutAttributeCenterX) multiplier:1 constant:0], [NSLayoutConstraint constraintWithItem:headerTitleLabel attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:headerView attribute:(NSLayoutAttributeCenterY) multiplier:1 constant:statusBarHeight / 2.f]]];
    
    CGFloat edgeLength = 5.f;
    CGFloat contentSizeHeight = 0;
    // scrollView
    self.scrollView = [[UIScrollView alloc] init];
    CGFloat bottom = 64;
    CGRect scrollViewFrame = self.view.bounds;
    scrollViewFrame.origin.y = top;
    scrollViewFrame.size.height -= top + bottom;
    self.scrollView.frame = scrollViewFrame;
    [self.view addSubview:self.scrollView];
    
    // textView
    self.textView = [[UITextView alloc] init];
    CGFloat textViewHeight = 120.f;
    self.textView.frame = CGRectMake(edgeLength, edgeLength, scrollViewFrame.size.width - edgeLength * 2, textViewHeight);
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.borderColor = [UIColor blackColor].CGColor;
    self.textView.layer.borderWidth = 1.f;
    self.textView.textColor = [UIColor blackColor];
    self.textView.font = [UIFont systemFontOfSize:13];
    self.textView.text = @"";
    [self.scrollView addSubview:self.textView];
    contentSizeHeight += edgeLength + textViewHeight;
    
    // 启动
    UIView *contentView = [[UIView alloc] init];
    CGFloat contentViewHeight = 50.f;
    CGFloat space = 20;
    contentView.frame = CGRectMake(0, contentSizeHeight + space, scrollViewFrame.size.width, contentViewHeight);
    contentView.layer.borderColor = [UIColor blackColor].CGColor;
    contentView.layer.borderWidth = 1.0f;
    [self.scrollView addSubview:contentView];
    contentSizeHeight += space + contentViewHeight;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = @"启动";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:15];
    [contentView addSubview:titleLabel];
    
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:titleLabel attribute:(NSLayoutAttributeLeading) relatedBy:(NSLayoutRelationEqual) toItem:contentView attribute:(NSLayoutAttributeLeading) multiplier:1 constant:17], [NSLayoutConstraint constraintWithItem:titleLabel attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:contentView attribute:(NSLayoutAttributeCenterY) multiplier:1 constant:0]]];
    
    self.startSwitchView = [[UISwitch alloc] init];
    self.startSwitchView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.startSwitchView addTarget:self action:@selector(startSwitchViewValueChanged:) forControlEvents:UIControlEventValueChanged];
    if ([HSDManager isHttpServerRunning]) {
        self.startSwitchView.on = YES;
    } else {
        self.startSwitchView.on = NO;
    }
    [contentView addSubview:self.startSwitchView];
    
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.startSwitchView attribute:(NSLayoutAttributeTrailing) relatedBy:(NSLayoutRelationEqual) toItem:contentView attribute:(NSLayoutAttributeTrailing) multiplier:1 constant:-17], [NSLayoutConstraint constraintWithItem:self.startSwitchView attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:contentView attribute:(NSLayoutAttributeCenterY) multiplier:1 constant:0]]];
    
    // 自动启动
    contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0, contentSizeHeight + space, scrollViewFrame.size.width, contentViewHeight);
    contentView.layer.borderColor = [UIColor blackColor].CGColor;
    contentView.layer.borderWidth = 1.0f;
    [self.scrollView addSubview:contentView];
    contentSizeHeight += space + contentViewHeight;

    titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = @"自动启动";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:15];
    [contentView addSubview:titleLabel];
    
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:titleLabel attribute:(NSLayoutAttributeLeading) relatedBy:(NSLayoutRelationEqual) toItem:contentView attribute:(NSLayoutAttributeLeading) multiplier:1 constant:17], [NSLayoutConstraint constraintWithItem:titleLabel attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:contentView attribute:(NSLayoutAttributeCenterY) multiplier:1 constant:0]]];
    
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.translatesAutoresizingMaskIntoConstraints = NO;
    [switchView addTarget:self action:@selector(autoStartSwitchViewValueChanged:) forControlEvents:UIControlEventValueChanged];
    BOOL isAutoStart = [[NSUserDefaults standardUserDefaults] boolForKey:kHSDUserDefaultsKeyAutoStart];
    if (isAutoStart) {
        switchView.on = YES;
    } else {
        switchView.on = NO;
    }
    [contentView addSubview:switchView];
    
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:switchView attribute:(NSLayoutAttributeTrailing) relatedBy:(NSLayoutRelationEqual) toItem:contentView attribute:(NSLayoutAttributeTrailing) multiplier:1 constant:-17], [NSLayoutConstraint constraintWithItem:switchView attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:contentView attribute:(NSLayoutAttributeCenterY) multiplier:1 constant:0]]];
    
    // 返回
    contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0, contentSizeHeight + space, scrollViewFrame.size.width, contentViewHeight);
    contentView.layer.borderColor = [UIColor blackColor].CGColor;
    contentView.layer.borderWidth = 1.0f;
    [self.scrollView addSubview:contentView];
    contentSizeHeight += space + contentViewHeight;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = contentView.bounds;
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:button];
    
    self.scrollView.contentSize = CGSizeMake(scrollViewFrame.size.width, contentSizeHeight);
    
    if ([HSDManager isHttpServerRunning]) {
        [self resolveHostName];
    }
}

- (void)startSwitchViewValueChanged:(UISwitch *)sender {
    BOOL isON = sender.on;
    if (isON) {
        [HSDManager startHttpServer];
    } else {
        [HSDManager stopHttpServer];
    }
}

- (void)autoStartSwitchViewValueChanged:(UISwitch *)sender {
    BOOL isON = sender.on;
    [[NSUserDefaults standardUserDefaults] setBool:isON forKey:kHSDUserDefaultsKeyAutoStart];
}

- (void)backButtonPressed {
    if (self.backBlock) {
        self.backBlock();
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 *  resolve host name and show logs in textView
 */
- (void)resolveHostName {
    [HSDManager resolveHostName:^(HSDHostNameResolveState state, NSArray<NSString *> *results, NSDictionary<NSString *,NSNumber *> *errorDict) {
        if (state == HSDHostNameResolveStateReady) {
            [self showLog:@"开始查找域名...\n"];
        } else if (state == HSDHostNameResolveStateSuccess) {
            NSMutableString *logStr = [@"查找域名成功，可通过如下地址访问HSD：\n" mutableCopy];
            for (NSString *result in results) {
                NSString *tmp = result.length > 0 ? result : @"";
                [logStr appendString:tmp];
                [logStr appendString:@"\n"];
            }
            [self showLog:logStr];
        } else if (state == HSDHostNameResolveStateFail) {
            [self showLog:@"查找失败\n"];
        } else if (state == HSDHostNameResolveStateStop) {
            [self showLog:@"查找结束\n"];
        }
    }];
}

- (void)showLog:(NSString *)logStr {
    [self.logText appendString:logStr];
    self.textView.text = self.logText;
    
    // scroll to bottom
    NSUInteger length = self.logText.length;
    if (length > 0) {
        NSRange bottom = NSMakeRange(length - 1, 1);
        [self.textView scrollRangeToVisible:bottom];
    }
}

- (void)notificationReceived:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *name = notification.name;
        if ([name isEqualToString:kHSDNotificationServerStarted]) {
            self.startSwitchView.on = YES;
            [self showLog:@"HSD启动\n"];
            
            // dispatch after, make sure bonjour has published
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self resolveHostName];
            });
        } else if ([name isEqualToString:kHSDNotificationServerStopped]) {
            self.startSwitchView.on = NO;
            [self showLog:@"HSD关闭\n"];
        }
    });
}

@end
