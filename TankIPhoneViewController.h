//
//  TankIPhoneViewController.h
//  TankCommander
//
//  Created by Ryan Case on 3/6/14.
//  Copyright (c) 2014 Ryan Case. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tank;

@interface TankIPhoneViewController : UITableViewController

@property (nonatomic) Tank *tank;

- (void)pushModulesViewController;

@end
