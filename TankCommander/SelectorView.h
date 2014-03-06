//
//  SelectorView.h
//  TankCommander
//
//  Created by Ryan Case on 11/18/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tank, TankIPadViewController;

@interface SelectorView : UIView
{
    Tank *tank;
}

@property (nonatomic, weak) TankIPadViewController *tankViewController;

- (id)initWithOrigin:(CGPoint)origin andTank:(Tank *)tank;
- (void)selectStockOrTop:(UISegmentedControl *)stockOrTop;
- (void)selectShellType:(UISegmentedControl *)shellType;

@end
