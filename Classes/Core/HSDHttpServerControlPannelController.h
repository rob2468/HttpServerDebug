//
//  HSDHttpServerControlPannelController.h
//  HttpServerDebug
//
//  Created by chenjun on 18/07/2017.
//  Copyright © 2017 Baidu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSDHttpServerControlPannelController : UIViewController

/**
 *  Actions when user press back button.
 *  If not assigned, [self.navigationController popViewControllerAnimated:YES] will be executed.
 */
@property (strong, nonatomic) void(^backBlock)(void);

@end
