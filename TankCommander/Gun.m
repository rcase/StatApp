//
//  Gun.m
//  TankCommander
//
//  Created by Ryan Case on 10/20/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import "Gun.h"
#import "Shell.h"

@implementation Gun

@synthesize shells, round, rateOfFire, accuracy, aimTime, roundsInDrum, drumReload, timeBetweenShots;

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super initWithDict:dict];
    if (self) {
        NSArray *shellValues = [dict objectForKey:@"shells"];
        Shell *normal = [[Shell alloc] initWithShellIndex:0 andArray:shellValues[0]];
        Shell *gold = [[Shell alloc] initWithShellIndex:1 andArray:shellValues[1]];
        Shell *he = [[Shell alloc] initWithShellIndex:2 andArray:shellValues[2]];
        self.shells = [NSArray arrayWithObjects:normal, gold, he, nil];
        self.rateOfFire = [[dict objectForKey:@"rateOfFire"] floatValue];
        self.accuracy = [[dict objectForKey:@"accuracy"] floatValue];
        self.aimTime = [[dict objectForKey:@"aimTime"] floatValue];
        self.gunDepression = [[dict objectForKey:@"gunDepression"] floatValue];
        self.gunElevation = [[dict objectForKey:@"gunElevation"] floatValue];
        if ([dict objectForKey:@"autoloader"]) {
            self.roundsInDrum = [[dict objectForKey:@"roundsInDrum"] floatValue];
            self.drumReload = [[dict objectForKey:@"drumReload"] floatValue];
            self.timeBetweenShots = [[dict objectForKey:@"timeBetweenShots"] floatValue];
        }
        [self setNormalRounds];
    }
    return self;
}

- (NSString *)description
{
    return self.name;
}

- (void)setNormalRounds
{
    round = shells[ShellTypeNormal];
}

- (void)setGoldRounds
{
    round = shells[ShellTypeGold];
}

- (void)setHERounds
{
    round = shells[ShellTypeHE];
}

- (float)burstDamage
{
    if (self.roundsInDrum) {
        return self.roundsInDrum * self.round.damage;
    } else {
        return self.round.damage;
    }
}

- (float)burstLength
{
    if (self.roundsInDrum) {
        return self.roundsInDrum * self.timeBetweenShots;
    } else {
        return 1;
    }
}

@end
