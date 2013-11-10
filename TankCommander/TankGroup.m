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
#import "AverageTank.h"

@implementation TankGroup

@synthesize group, averageTank;

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
    if ([object class] == [Tank class]) {
        [group addObject:object];
    } else {
        NSLog(@"Trying to add a non Tank to a TankGroup array");
    }
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

- (NSArray *)percentileValuesForKey:(NSString *)key smallerValuesAreBetter:(BOOL)smallerIsBetter
{
    NSArray *sortedArray = [self sortedListForKey:key smallerValuesAreBetter:smallerIsBetter];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (Tank *tank in sortedArray) {
        [values addObject:[NSNumber numberWithFloat:[[tank valueForKey:key] floatValue]]];
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
            float keyNumericValue = [key floatValue];
            NSUInteger numberOfKeyOccurences = [[valuesCount objectForKey:key] integerValue];
            if (keyNumericValue < [tankStat floatValue]) {
                valuesBelow += numberOfKeyOccurences;
            } else if (keyNumericValue == [tankStat floatValue]) {
                valuesEqualTo += numberOfKeyOccurences;
            }
        }
        float percentileForStat = (valuesBelow + (0.5 * valuesEqualTo)) / [values count];
        [percentiles addObject:[NSNumber numberWithFloat:percentileForStat]];
    }
    if (smallerIsBetter) {
        for (int i=0; i < [percentiles count]; i++) {
            float currentNumber = [percentiles[i] floatValue];
            currentNumber = 1.00 - currentNumber;
            percentiles[i] = [NSNumber numberWithFloat:currentNumber];
        }
    }
    return percentiles;
}

- (NSNumber *)averageValueForKey:(NSString *)key
{
    NSMutableArray *stats = [[NSMutableArray alloc] init];
    for (Tank *tank in self.group) {
        [stats addObject:[NSNumber numberWithFloat:[[tank valueForKey:key] floatValue]]];
    }
    float average = 0;
    for (NSNumber *sample in stats) {
        average += [sample floatValue];
    }
    average = average / [stats count];
    return [NSNumber numberWithFloat:average];
}

- (NSString *)stringSortedListForKey:(NSString *)key smallerValuesAreBetter:(BOOL)yesno
{
    NSArray *sortedArray = [self sortedListForKey:key smallerValuesAreBetter:yesno];
    @try {
        NSMutableArray *stringArray = [[NSMutableArray alloc] init];
        for (int i=0; i<[sortedArray count]; i++) {
            Tank *currentTank = sortedArray[i];
            NSString *tankString = [NSString stringWithFormat:@"%d) %@: %.2f\n",
                                    i+1, currentTank.description, [[currentTank valueForKey:key] floatValue]];
            [stringArray addObject:tankString];
        }
        NSString *final = [NSString stringWithFormat:@"\n%@:\n", key];
        for (NSString *line in stringArray) {
            final = [final stringByAppendingString:line];
        }
        return final;
    }
    @catch (NSException *exception) {
        return @"Error, key not found";
    }
}

- (void)addAverageTank
{
    AverageTank *average = [[AverageTank alloc] init];
    if (average) {
        average.name = @"Average";
        NSArray *intKeys = @[@"experienceNeeded", @"cost", @"hitpoints"];
        for (NSString *key in intKeys) {
            [average setValue:[self averageValueForKey:key] forKey:key];
        }
        NSArray *floatKeys = @[@"gunTraverseArc", @"speedLimit", @"camoValue", @"penetration", @"aimTime",
                               @"accuracy", @"rateOfFire", @"gunDepression", @"gunElevation", @"weight",
                               @"specificPower", @"damagePerMinute", @"reloadTime", @"alphaDamage",
                               @"frontalHullArmor", @"sideHullArmor", @"rearHullArmor", @"frontalTurretArmor",
                               @"sideTurretArmor", @"effectiveFrontalHullArmor", @"effectiveSideHullArmor",
                               @"effectiveRearHullArmor", @"effectiveFrontalTurretArmor",
                               @"effectiveSideTurretArmor", @"effectiveRearTurretArmor"];
        for (NSString *key in floatKeys) {
            [average setValue:[self averageValueForKey:key] forKey:key];
        }
        self.averageTank = average;
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












