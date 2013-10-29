//
//  TankGroup.m
//  TankCommander
//
//  Created by Ryan Case on 10/27/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import "TankGroup.h"
#import "Tank.h"
#import "Module.h"
#import "Gun.h"

@implementation TankGroup

@synthesize group;

- (id)init
{
    self = [super init];
    if (self) {
        self.group = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addObject:(id)object
{
    [group addObject:object];
}

- (NSArray *)filteredArrayUsingPredicate:(NSPredicate *)predicate
{
    NSArray *result =  [group filteredArrayUsingPredicate:predicate];
    return result;
}

- (Tank *)findTankByName:(NSString *)name
{
    NSArray *result = [group filteredArrayUsingPredicate:
                    [NSPredicate predicateWithFormat:@"self.name == %@", name]];
    if ([result count] > 0) {
        return result[0];
    } else {
        Tank *error = [[Tank alloc] init];
        error.name = @"Search Failed";
        return error;
    }
}

- (NSArray *)sortedListForKey:(NSString *)key smallerValuesAreBetter:(BOOL)yesno
{
    @try {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:key ascending:yesno];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sort];
        NSArray *sortedArray = [group sortedArrayUsingDescriptors:sortDescriptors];
        return sortedArray;
    }
    @catch (NSException *exception) {
        return [NSArray arrayWithObject:@"Error, key not found"];
    }
}

- (NSArray *)percentileValuesForKey:(NSString *)key smallerValuesAreBetter:(BOOL)yesno
{
    NSArray *sortedArray = [self sortedListForKey:key smallerValuesAreBetter:yesno];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (Tank *tank in sortedArray) {
        [values addObject:[NSNumber numberWithFloat:tank.penetration]];
    }
    NSMutableDictionary *valuesCount = [[NSMutableDictionary alloc] init];
    for (NSNumber *num in values) {
        NSString *numString = [num stringValue];
        if ([valuesCount objectForKey:numString]) {
            NSUInteger currentValue = [[valuesCount objectForKey:numString] integerValue];
            currentValue++;
            [valuesCount setObject:[NSNumber numberWithInt:currentValue] forKey:numString];
        } else {
            [valuesCount setObject:[NSNumber numberWithInt:1] forKey:numString];
        }
    }
    NSMutableArray *percentiles = [[NSMutableArray alloc] init];
    for (NSNumber *tankStat in values) {
        NSUInteger valuesEqualTo = 0;
        NSUInteger valuesBelow = 0;
        for (id key in valuesCount) {
            NSUInteger keyIntegerValue = [key integerValue];
            NSUInteger numberOfKeyOccurences = [[valuesCount objectForKey:key] integerValue];
            if (keyIntegerValue < [tankStat integerValue]) {
                valuesBelow += numberOfKeyOccurences;
            } else if (keyIntegerValue == [tankStat integerValue]) {
                valuesEqualTo += numberOfKeyOccurences;
            }
        }
        float percentileForStat = (valuesBelow + (0.5 * valuesEqualTo)) / [values count];
        [percentiles addObject:[NSNumber numberWithFloat:percentileForStat]];
    }
    return percentiles;
}

- (NSArray *)logSortedListForKey:(NSString *)key smallerValuesAreBetter:(BOOL)yesno
{
    NSArray *sortedArray = [self sortedListForKey:key smallerValuesAreBetter:yesno];
    @try {
        NSMutableArray *stringArray = [[NSMutableArray alloc] init];
        for (int i=0; i<[sortedArray count]; i++) {
            Tank *currentTank = sortedArray[i];
            NSString *tankString = [NSString stringWithFormat:@"%d) %@: %.2f",
                                    i+1, currentTank.description, [[currentTank valueForKey:key] floatValue]];
            [stringArray addObject:tankString];
        }
        return stringArray;
    }
    @catch (NSException *exception) {
        return [NSArray arrayWithObject:@"Error, key not found"];
    }
}

- (void)setAllRoundsToNormalRounds
{
    for (Tank *tank in group) {
        [tank.gun setNormalRounds];
    }
}

- (void)setAllRoundsToGoldRounds
{
    for (Tank *tank in group) {
        [tank.gun setGoldRounds];
    }
}

- (void)setAllRoundsToHERounds
{
    for (Tank *tank in group) {
        [tank.gun setHERounds];
    }
}


@end













