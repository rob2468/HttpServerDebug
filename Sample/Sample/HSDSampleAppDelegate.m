//
//  HSDSampleAppDelegate.m
//  Sample
//
//  Created by chenjun on 2018/4/23.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDSampleAppDelegate.h"
#import "HSDManager.h"
#import "HSDSampleRootController.h"

@implementation HSDSampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    HSDSampleRootController *rootVC = [[HSDSampleRootController alloc] init];
    rootVC.view.backgroundColor = [UIColor yellowColor];
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    
    [HSDManager updateHSDDelegate:self];
    [HSDManager updateHttpServerPort:5555];

    // demo for console log component
    static NSInteger tmp = 0;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
        tmp++;
        NSLog(@"test for console log display %ld", (long)tmp);
    }];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

    return YES;
}

-(NSDictionary *)onHSDReceiveInfo:(NSString *)info {
    info = info.length > 0 ? info : @"";
    return @{@"sent_info": info};
}

@end
