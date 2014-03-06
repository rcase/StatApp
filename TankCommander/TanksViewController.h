//
//  TanksViewController.h
//  TankCommander
//
//  Created by Ryan Case on 11/11/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TankGroup, TankIPadViewController;

@interface TanksViewController : UITableViewController

@property (nonatomic) TankGroup *tankGroup;
@property (nonatomic, strong) TankIPadViewController *tankView;

- (id)initWithTankGroup:(TankGroup *)group;

@end
