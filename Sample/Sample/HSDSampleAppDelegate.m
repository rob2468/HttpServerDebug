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
    [HSDManager updateHttpServerPort:@"5555"];
    
    static NSInteger tmp = 0;
    [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
        tmp++;
        NSLog(@"test for console log display %ld", (long)tmp);
    }];

    return YES;
}

-(NSDictionary *)onHSDReceiveInfo:(NSString *)info {
    return @{@"a": @"b"};
}

@end
