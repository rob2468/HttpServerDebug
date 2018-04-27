//
//  CJAppDelegate.m
//  Closet
//
//  Created by chenjun on 2018/4/23.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "CJAppDelegate.h"
#import "Closet-Swift.h"
#import "HSDManager.h"
#import "CJRootController.h"

@implementation CJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    CJRootController *rootVC = [[CJRootController alloc] init];
    rootVC.view.backgroundColor = [UIColor yellowColor];
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    
    [HSDManager updateHSDDelegate:self];
    [HSDManager updateHttpServerPort:@"5555"];
    return YES;
}

-(NSDictionary *)onHSDReceiveInfo:(NSString *)info {
    return @{@"a": @"b"};
}

@end
