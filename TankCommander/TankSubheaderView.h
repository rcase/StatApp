//
//  TankSubheaderView.h
//  TankCommander
//
//  Created by Ryan Case on 11/17/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tank, TankIPadViewController;

@interface TankSubheaderView : UIView
{
    Tank *tank;
}

@property (nonatomic) TankIPadViewController *tankViewController;

- (id)initWithPoint:(CGPoint)point andTank:(Tank *)t;

@end
