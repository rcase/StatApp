//
//  Tier.m
//  TankCommander
//
//  Created by Ryan Case on 10/22/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import "Tier.h"
#import "Tank.h"
#import "TankGroup.h"

@implementation Tier

@synthesize lightTanks, mediumTanks, heavyTanks, tankDestroyers, SPGs, nameString;

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        lightTanks = [[TankGroup alloc] initWithDict:[dict objectForKey:@"lightTanks"]];
        lightTanks.typeString = @"Light Tanks";
        mediumTanks = [[TankGroup alloc] initWithDict:[dict objectForKey:@"mediumTanks"]];
        mediumTanks.typeString = @"Medium Tanks";
        heavyTanks = [[TankGroup alloc] initWithDict:[dict objectForKey:@"heavyTanks"]];
        heavyTanks.typeString = @"Heavy Tanks";
        tankDestroyers = [[TankGroup alloc] initWithDict:[dict objectForKey:@"tankDestroyers"]];
        tankDestroyers.typeString = @"Tank Destroyers";
        SPGs = [[TankGroup alloc] initWithDict:[dict objectForKey:@"spgs"]];
        SPGs.typeString = @"Artillery/SPGs";
    }
    return self;
}

- (int)count
{
    return ([lightTanks count] + [mediumTanks count] + [heavyTanks count] + [tankDestroyers count] + [SPGs count]);
}

- (NSArray *)fetchValidKeys
{
    NSMutableArray *validKeys = [[NSMutableArray alloc] init];
    NSArray *keys = @[@"lightTanks", @"mediumTanks", @"heavyTanks", @"tankDestroyers", @"SPGs"];
    for (NSString *key in keys) {
        if ([[self valueForKey:key] count] > 0) {
            [validKeys addObject:key];
        }
    }
    if ([validKeys count] > 0) {
        [validKeys addObject:@"all"];
    }
    return  validKeys;
}

- (TankGroup *)all
{
    TankGroup *allTanks = [[TankGroup alloc] init];
    for (Tank *tank in lightTanks.group) {
        [allTanks.group addObject:tank];
    }
    for (Tank *tank in mediumTanks.group) {
        [allTanks.group addObject:tank];
    }
    for (Tank *tank in heavyTanks.group) {
        [allTanks.group addObject:tank];
    }
    for (Tank *tank in tankDestroyers.group) {
        [allTanks.group addObject:tank];
    }
    for (Tank *tank in SPGs.group) {
        [allTanks.group addObject:tank];
    }
    allTanks.typeString = @"All";
    return  allTanks;
}

- (TankGroup *)allExceptSPGs
{
    TankGroup *allExceptSPGs = [[TankGroup alloc] init];
    for (Tank *tank in lightTanks.group) {
        [allExceptSPGs.group addObject:tank];
    }
    for (Tank *tank in mediumTanks.group) {
        [allExceptSPGs.group addObject:tank];
    }
    for (Tank *tank in heavyTanks.group) {
        [allExceptSPGs.group addObject:tank];
    }
    for (Tank *tank in tankDestroyers.group) {
        [allExceptSPGs.group addObject:tank];
    }
    return  allExceptSPGs;
}

@end

















