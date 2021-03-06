//
//  TankHeaderView.h
//  TankCommander
//
//  Created by Ryan Case on 11/17/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tank;

@interface TankHeaderView : UIView
{
    Tank *tank;
}

- (id)initWithPoint:(CGPoint)point andTank:(Tank *)t;

@end
