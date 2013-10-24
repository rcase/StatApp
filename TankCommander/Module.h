//
//  Module.h
//  TankCommander
//
//  Created by Ryan Case on 10/23/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Module : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) float weight;
@property (nonatomic) BOOL stockModule;
@property (nonatomic) BOOL topModule;
@property (nonatomic) int experienceNeeded;
@property (nonatomic) int cost;

- (id)initWithDict:(NSDictionary *)dict;

@end
