//
//  Tank.h
//  TankCommander
//
//  Created by Ryan Case on 10/20/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Hull, Turret, Gun, Engine, Radio, Suspension;

@interface Tank : NSObject

typedef enum TankType : NSUInteger {
    LightTank,      // 0
    MediumTank,     // 1
    HeavyTank,      // 2
    TankDestroyer,  // 3
    SPG,            // 4
    Vehicle         // 5
} TankType;

typedef enum TankNationality : NSUInteger {
    American,       // 0
    British,        // 1
    Chinese,        // 2
    French,         // 3
    German,         // 4
    Japanese,       // 5
    Russian,        // 6
    Nation          // 7
} TankNationality;

// Properties that go with the tank and not a specific module
@property (nonatomic) NSString *name;
@property (nonatomic) TankNationality nationality;
@property (nonatomic) int tier;
@property (nonatomic) TankType type;
@property (nonatomic) BOOL premiumTank;
@property (nonatomic) int experienceNeeded;
@property (nonatomic) int cost;
@property (nonatomic) float crewLevel;
@property (nonatomic) int baseHitpoints;
@property (nonatomic) float topWeight;
@property (nonatomic) float gunTraverseArc;

// Strings to define the tanks before and after it
@property (nonatomic) NSString *parent;
@property (nonatomic) NSString *child;

// These arrays hold all possible equippable modules
@property (nonatomic) NSMutableArray *availableTurrets;
@property (nonatomic) NSMutableArray *availableEngines;
@property (nonatomic) NSMutableArray *availableSuspensions;
@property (nonatomic) NSMutableArray *availableRadios;

// The modules that are currently equipped are stored in these variables
@property (nonatomic) Hull *hull;
@property (nonatomic) Turret *turret;
@property (nonatomic) Engine *engine;
@property (nonatomic) Radio *radio;
@property (nonatomic) Suspension *suspension;

// Pass through properties
- (Gun *)gun;
- (float)penetration;
- (float)aimTime;
- (float)accuracy;
- (float)rateOfFire;
- (float)gunDepression;
- (float)gunElevation;
- (BOOL)autoloader;
- (float)roundsInDrum;
- (float)drumReload;
- (float)timeBetweenShots;

// Calculated properties
- (int)hitpoints;
- (float)weight;
- (float)specificPower;
- (float)damagePerMinute;
- (float)reloadTime;
- (float)alphaDamage;

// Init methods
- (id)initWithDict:(NSDictionary *)dict;

// Override Methods
- (NSString *)description;

// Used by the init method to set the enums
TankNationality fetchTankNationality (int index);
TankType fetchTankType (int index);


@end
