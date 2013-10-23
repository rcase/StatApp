//
//  Suspension.h
//  TankCommander
//
//  Created by Ryan Case on 10/20/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Suspension : NSObject

@property (nonatomic) NSString *name;

@property (nonatomic) float loadLimit;
@property (nonatomic) int traverseSpeed;

@property (nonatomic) float weight;
@property (nonatomic) BOOL stockModule;
@property (nonatomic) BOOL topModule;
@property (nonatomic) int experienceNeeded;
@property (nonatomic) int cost;

@end