//
//  Module.m
//  TankCommander
//
//  Created by Ryan Case on 10/23/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import "Module.h"

@implementation Module

static int moduleCount = 0;

@synthesize name, weight, stockModule, topModule, experienceNeeded, cost, modScore;

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.name = [dict objectForKey:@"name"];
        self.tier = [[dict objectForKey:@"tier"] intValue];
        self.weight = [[dict objectForKey:@"weight"] floatValue];
        self.stockModule = [[dict objectForKey:@"stockModule"] boolValue];
        self.topModule = [[dict objectForKey:@"topModule"] boolValue];
        self.experienceNeeded = [[dict objectForKey:@"experienceNeeded"] intValue];
        self.cost = [[dict objectForKey:@"cost"] intValue];
        self.modScore = [[dict objectForKey:@"modScore"] intValue];
        
        moduleCount++;
    }
    return self;
}

+ (int)count
{
    return moduleCount;
}

- (NSString *)description
{
    return name;
}

- (NSString *)stringSummary
{
    return [NSString stringWithFormat:@"%@: %d", self.name, self.tier];
}

- (NSComparisonResult)compare:(Module *)otherModule
{
    return [[NSNumber numberWithInt:self.modScore] compare:[NSNumber numberWithInt:otherModule.modScore]];
}

- (id)copyWithZone:(NSZone *)zone
{
    Module *copy = [[[self class] allocWithZone:zone] init];
    NSArray *attributes = @[@"tier", @"weight", @"stockModule", @"topModule", @"experienceNeeded", @"cost", @"modScore"];
    for (NSString *key in attributes) {
        [copy setValue:[self valueForKey:key] forKey:key];
    }
    copy.name = [self.name copyWithZone:zone];
    
    return copy;
}

@end










