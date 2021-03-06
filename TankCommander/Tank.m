//
//  Tank.m
//  TankCommander
//
//  Created by Ryan Case on 10/20/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import "Tank.h"
#import "Hull.h"
#import "Turret.h"
#import "Gun.h"
#import "Engine.h"
#import "Radio.h"
#import "Suspension.h"
#import "Armor.h"

static int tankCount = 0;

@implementation Tank

@synthesize name, hull, turret, engine, radio, suspension, availableEngines, availableRadios, topWeight, hasTurret,
availableSuspensions, availableTurrets, experienceNeeded, cost, premiumTank, gunTraverseArc, crewLevel, speedLimit,
baseHitpoints, parent, child, nationality, tier, type, averageTank, stockWeight, available, camoValueStationary,
camoValueMoving, camoValueShooting;

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        // Mass assignment of attributes from the dictionary parsed from the JSON files
        self.name = [dict objectForKey:@"name"];
        self.nationality = fetchTankNationality([dict objectForKey:@"nation"]);
        self.tier = [[dict objectForKey:@"tier"] intValue];
        self.type = fetchTankType([dict objectForKey:@"type"]);
        self.premiumTank = [[dict objectForKey:@"premiumTank"] boolValue];
        self.available = [[dict objectForKey:@"available"] boolValue];
        self.hasTurret = [[dict objectForKey:@"turreted"] boolValue];
        self.experienceNeeded = [[dict objectForKey:@"experienceNeeded"] intValue];
        self.cost = [[dict objectForKey:@"cost"] intValue];
        self.baseHitpoints = [[dict objectForKey:@"baseHitpoints"] intValue];
        self.gunTraverseArc = [[dict objectForKey:@"gunArc"] floatValue];
        self.speedLimit = [[dict objectForKey:@"speedLimit"] floatValue];
        NSArray *camoValues = [dict objectForKey:@"camoValues"];
        self.camoValueStationary = [camoValues[0] floatValue];
        self.camoValueMoving = [camoValues[1] floatValue];
        self.camoValueShooting = [camoValues[2] floatValue];
        self.crewLevel = [[dict objectForKey:@"crewLevel"] floatValue];
        self.topWeight = ([[dict objectForKey:@"topWeight"] floatValue] * 1000);
        self.stockWeight = ([[dict objectForKey:@"stockWeight"] floatValue] * 1000);
        
        // Parent and child tanks are stored as strings for now, later these will likely change to a pointer
        // to the next/prev tank in the line, but the feature itself isn't terribly useful and there are
        // a lot of exceptions to the 1 parent- 1 child rule that would simply make it difficult
        if (!self.premiumTank) {
            self.parent = [dict objectForKey:@"parent"];
            self.child = [dict objectForKey:@"child"];
        }
        
        // Add the hull - init will be different depending on whether the gun is in the turret or the hull
        self.hull = [[Hull alloc] initWithDict:[dict objectForKey:@"hull"] forTurreted:hasTurret];
        
        // Check for the presence of a turret and add guns to it, if not add the guns to the hull object
        if ([dict objectForKey:@"turrets"]) {
            // Each of the following chunks for the module groups is functionally the same so the comments
            // apply to all of them
            
            // First fetch the JSON for the module group
            NSDictionary *turretValues = [dict objectForKey:@"turrets"];
            // Init the NSMutableArray to hold the objects
            availableTurrets = [[NSMutableArray alloc] init];
            // Init each object from the JSON
            for (id key in turretValues) {
                Turret *currentTurret = [[Turret alloc] initWithDict:[turretValues objectForKey:key]];
                // Finally, add it to the module array
                [availableTurrets addObject:currentTurret];
            }
            [availableTurrets sortUsingSelector:@selector(compare:)];
        }
        
        // Same concept as above
        NSDictionary *engineValues = [dict objectForKey:@"engines"];
        availableEngines = [[NSMutableArray alloc] init];
        for (id key in engineValues) {
            Engine *currentEngine = [[Engine alloc] initWithDict:[engineValues objectForKey:key]];
            [availableEngines addObject:currentEngine];
        }
        [availableEngines sortUsingSelector:@selector(compare:)];
        
        // Same concept as above
        NSDictionary *suspensionValues = [dict objectForKey:@"suspensions"];
        availableSuspensions = [[NSMutableArray alloc] init];
        for (id key in suspensionValues) {
            Suspension *currentSuspension = [[Suspension alloc] initWithDict:[suspensionValues objectForKey:key]];
            [availableSuspensions addObject:currentSuspension];
        }
        [availableSuspensions sortUsingSelector:@selector(compare:)];
        
        // Same concept as above
        NSDictionary *radioValues = [dict objectForKey:@"radios"];
        availableRadios = [[NSMutableArray alloc] init];
        for (id key in radioValues) {
            Radio *currentRadio = [[Radio alloc] initWithDict:[radioValues objectForKey:key]];
            [availableRadios addObject:currentRadio];
        }
        [availableRadios sortUsingSelector:@selector(compare:)];
        
        // Finding the weight of the hull is done by taking the stock weight, setting the values to stock, and then
        // subtracting the weight of all the individual modules
        [self setAllValuesStock];
        self.hull.weight = self.stockWeight - self.turret.weight - self.gun.weight -
        self.suspension.weight - self.radio.weight - self.engine.weight;
        
        // Set all the values to top values because that is the likely preference of people using the app
        [self setAllValuesTop];
        [self validate];
        
        tankCount++;
    }
    return self;
}

- (BOOL)validate
{
    BOOL result = YES;
    // The validation is being separated into categories, the first is floatKeys,
    // which require both non-null and nonzero values
    NSArray *floatKeys = [NSArray arrayWithObjects:
                          @"tier", @"crewLevel", @"baseHitpoints", @"gunTraverseArc", @"gunElevation",
                          @"speedLimit", @"camoValueStationary", @"camoValueMoving",
                          @"camoValueShooting", @"viewRange", nil];
    for (NSString *key in floatKeys) {
        if ([[self valueForKey:key] floatValue] == 0.0) {
            NSLog(@"%@ is missing %@", self.name, key);
            result = NO;
        }
    }
    // These keys check only for the presence of a value
    NSArray *presenceKeys = [NSArray arrayWithObjects:
                             @"name", @"nationality", @"type", @"hasTurret", @"premiumTank", @"experienceNeeded",
                             @"hull", @"engine", @"radio", @"suspension", @"cost",  @"gunDepression", nil];
    for (NSString *key in presenceKeys) {
        if (![self valueForKey:key]) {
            NSLog(@"%@ is missing %@", self.name, key);
            result = NO;
        }
    }
    // Some validations are not needed if the tank is a premium
    // These are commented out for now since there's no easy way to get this data from the API or elsewhere
    //    if (!self.premiumTank) {
    //        if (self.experienceNeeded < 1) {
    //            NSLog(@"Non-premium tank %@ is missing experience needed",
    //                  self.name);
    //            result = NO;
    //        }
    //        if (!self.parent | !self.child) {
    //            NSLog(@"%@ is missing parent and/or child: parent: %@, child: %@", self.name, self.parent, self.child);
    //            result = NO;
    //        }
    //    }
    
    // Finally, validate the module arrays to ensure there is only one stock and one top module for each
    NSMutableArray *moduleArrayKeys = [NSMutableArray arrayWithObjects:
                                       @"availableEngines", @"availableSuspensions", @"availableRadios", @"availableGuns",
                                       nil];
    if (self.hasTurret) {
        [moduleArrayKeys addObject:@"availableTurrets"];
    }
    
    for (NSString *key in moduleArrayKeys) {
        result = [self validateModuleArray:key];
    }
    
    return result;
}

- (BOOL)validateModuleArray:(NSString *)moduleArrayString
{
    BOOL result = YES;
    NSArray *moduleArray = [self valueForKey:moduleArrayString];
    int stockValues = 0;
    int topValues = 0;
    // There can only be one stock module and one top module for each module type,
    // this method checks to ensure that this is true
    for (Module *mod in moduleArray) {
        // First we count the number of modules labelled stock and top
        if (mod.topModule) {
            topValues++;
        }
        if (mod.stockModule) {
            stockValues++;
        }
    }
    // Then log errors accordingly and change the bool value
    if (topValues == 0) {
        NSLog(@"Error: %@ %@ is missing a top module",
              self.name, moduleArrayString);
        result = NO;
    } else if (topValues > 1) {
        NSLog(@"Error: %@ %@ has too many top modules",
              self.name, moduleArrayString);
        result = NO;
    }
    // The method will fail if any of the four conditions are wrong, so the log statements
    // can stay in here permanently to specify the error
    if (stockValues == 0) {
        NSLog(@"Error: %@ %@ is missing a stock module",
              self.name, moduleArrayString);
        result = NO;
    } else if (stockValues > 1) {
        NSLog(@"Error: %@ %@ has too many stock modules",
              self.name, moduleArrayString);
        result = NO;
    }
    return result;
}

+ (int)count
{
    return tankCount;
}

// Only used in logging/debugging, this puts and asterisk in front of premium tanks
- (NSString *)description
{
    if (self.premiumTank) {
        return [NSString stringWithFormat:@"*%@", name];
    } else {
        return name;
    }
}

// Used for displaying the module names in the iPhone UITableView
- (NSArray *)equippedModulesNameArray
{
    if (self.hasTurret) {
        // Hull, Turret, Gun, Suspension, Engine, Radio
        NSArray *final = @[
                           @[[NSString stringWithFormat:@"Gun: %@", self.gun.name], @"availableGuns"],
                           @[[NSString stringWithFormat:@"Hull: %@", self.name], @"hull"],
                           @[[NSString stringWithFormat:@"Turret: %@", self.turret.name], @"availableTurrets"],
                           @[[NSString stringWithFormat:@"Suspension: %@", self.suspension.name], @"availableSuspensions"],
                           @[[NSString stringWithFormat:@"Engine: %@", self.engine.name], @"availableEngines"],
                           @[[NSString stringWithFormat:@"Radio: %@", self.radio.name], @"availableRadios"]
                           ];
        return final;
    } else {
        // Hull, Gun, Suspension, Engine, Radio
        NSArray *final = @[
                           @[[NSString stringWithFormat:@"Gun: %@", self.gun.name], @"availableGuns"],
                           @[[NSString stringWithFormat:@"Hull: %@", self.name], @"hull"],
                           @[[NSString stringWithFormat:@"Suspension: %@", self.suspension.name], @"availableSuspensions"],
                           @[[NSString stringWithFormat:@"Engine: %@", self.engine.name], @"availableEngines"],
                           @[[NSString stringWithFormat:@"Radio: %@", self.radio.name], @"availableRadios"]
                           ];
        return final;
    }
}

// Rather than store all the information in this hash, it will instead contain the name of the traits
// to be pulled and that will in turn be used to access them from within the view
- (NSDictionary *)attributesHash
{
    NSMutableDictionary *final = [[NSMutableDictionary alloc] init];
    
    // Set up the dicitonary structure
    [final setValue:[[NSMutableArray alloc] init] forKey:@"hull"];
    [final setValue:[[NSMutableArray alloc] init] forKey:@"gun"];
    [final setValue:[[NSMutableArray alloc] init] forKey:@"suspension"];
    [final setValue:[[NSMutableArray alloc] init] forKey:@"radio"];
    [final setValue:[[NSMutableArray alloc] init] forKey:@"engine"];
    if (self.hasTurret) {
        [final setValue:[[NSMutableArray alloc] init] forKey:@"turret"];
    }
    
    // Gun
    NSMutableArray *gunArr = [final objectForKey:@"gun"];
    [gunArr addObject:@"penetration"];
    [gunArr addObject:@"alphaDamage"];
    [gunArr addObject:@"accuracy"];
    [gunArr addObject:@"aimTime"];
    [gunArr addObject:@"rateOfFire"];
    [gunArr addObject:@"reloadTime"];
    [gunArr addObject:@"damagePerMinute"];
    [gunArr addObject:@"gunDepression"];
    [gunArr addObject:@"gunElevation"];
    [gunArr addObject:@"movementDispersionGun"];
    if (self.autoloader) {
        [gunArr addObject:@"roundsInDrum"];
        [gunArr addObject:@"timeBetweenShots"];
        [gunArr addObject:@"drumReload"];
        [gunArr addObject:@"burstDamage"];
    }
    
    // Hull
    NSMutableArray *hullArr = [final valueForKey:@"hull"];
    [hullArr addObject:@"weight"];
    [hullArr addObject:@"hitpoints"];
    [hullArr addObject:@"camoValueStationary"];
    [hullArr addObject:@"camoValueMoving"];
    [hullArr addObject:@"camoValueShooting"];
    [hullArr addObject:@"frontalHullArmor"];
    [hullArr addObject:@"sideHullArmor"];
    [hullArr addObject:@"rearHullArmor"];
    if (!self.hasTurret) {
        [hullArr addObject:@"viewRange"];
        [hullArr addObject:@"gunTraverseArc"];
    }
    
    // Turret (if needed)
    if (self.hasTurret) {
        NSMutableArray *turretArr = [final objectForKey:@"turret"];
        [turretArr addObject:@"frontalTurretArmor"];
        [turretArr addObject:@"sideTurretArmor"];
        [turretArr addObject:@"rearTurretArmor"];
        [turretArr addObject:@"turretTraverse"];
        [turretArr addObject:@"viewRange"];
        [turretArr addObject:@"gunTraverseArc"];
    }
    
    // Engine
    NSMutableArray *engineArr = [final objectForKey:@"engine"];
    [engineArr addObject:@"horsepower"];
    [engineArr addObject:@"specificPower"];
    [engineArr addObject:@"fireChance"];
    
    // Radio
    NSMutableArray *radioArr = [final objectForKey:@"radio"];
    [radioArr addObject:@"signalRange"];
    
    // Suspension
    NSMutableArray *suspensionArr = [final objectForKey:@"suspension"];
    [suspensionArr addObject:@"hullTraverse"];
    [suspensionArr addObject:@"loadLimit"];
    [suspensionArr addObject:@"speedLimit"];
    [suspensionArr addObject:@"hardTerrainResistance"];
    [suspensionArr addObject:@"mediumTerrainResistance"];
    [suspensionArr addObject:@"softTerrainResistance"];
    [suspensionArr addObject:@"movementDispersionSuspension"];
    
    return final;
}

+ (NSArray *)turretedIndex
{
    NSArray *final = @[@"gun", @"hull", @"turret", @"suspension", @"engine", @"radio"];
    return final;
}

+ (NSArray *)nonTurretedIndex
{
    NSArray *final = @[@"gun", @"hull", @"suspension", @"engine", @"radio"];
    return final;
}

// This purpose of this method is to provide a structure for the compare views
// only relevant stats are included, and some are restructured to provide a
// one size fits all approach
+ (NSDictionary *)allAttributes
{
    NSMutableDictionary *final = [[NSMutableDictionary alloc] init];
    
    // Set up the dicitonary structure
    [final setValue:[[NSMutableArray alloc] init] forKey:@"hull"];
    [final setValue:[[NSMutableArray alloc] init] forKey:@"gun"];
    [final setValue:[[NSMutableArray alloc] init] forKey:@"suspension"];
    [final setValue:[[NSMutableArray alloc] init] forKey:@"radio"];
    [final setValue:[[NSMutableArray alloc] init] forKey:@"engine"];
    [final setValue:[[NSMutableArray alloc] init] forKey:@"turret"];
    
    // Gun
    NSMutableArray *gunArr = [final objectForKey:@"gun"];
    [gunArr addObject:@"penetration"];
    [gunArr addObject:@"alphaDamage"];
    [gunArr addObject:@"accuracy"];
    [gunArr addObject:@"aimTime"];
    [gunArr addObject:@"rateOfFire"];
    [gunArr addObject:@"reloadTime"];
    [gunArr addObject:@"damagePerMinute"];
    [gunArr addObject:@"gunDepression"];
    [gunArr addObject:@"gunElevation"];
    [gunArr addObject:@"roundsInDrum"];
    [gunArr addObject:@"timeBetweenShots"];
    [gunArr addObject:@"drumReload"];
    [gunArr addObject:@"burstDamage"];
    [gunArr addObject:@"movementDispersionGun"];
    
    // Hull
    NSMutableArray *hullArr = [final valueForKey:@"hull"];
    [hullArr addObject:@"hitpoints"];
    [hullArr addObject:@"weight"];
    [hullArr addObject:@"frontalHullArmor"];
    [hullArr addObject:@"sideHullArmor"];
    [hullArr addObject:@"rearHullArmor"];
    [hullArr addObject:@"camoValueStationary"];
    [hullArr addObject:@"camoValueMoving"];
    [hullArr addObject:@"camoValueShooting"];
    [hullArr addObject:@"viewRange"];
    [hullArr addObject:@"gunTraverseArc"];
    
    // Turret (if needed)
    NSMutableArray *turretArr = [final objectForKey:@"turret"];
    [turretArr addObject:@"frontalTurretArmor"];
    [turretArr addObject:@"sideTurretArmor"];
    [turretArr addObject:@"rearTurretArmor"];
    [turretArr addObject:@"turretTraverse"];
    
    
    // Engine
    NSMutableArray *engineArr = [final objectForKey:@"engine"];
    [engineArr addObject:@"specificPower"];
    [engineArr addObject:@"fireChance"];
    
    // Radio
    NSMutableArray *radioArr = [final objectForKey:@"radio"];
    [radioArr addObject:@"signalRange"];
    
    // Suspension
    NSMutableArray *suspensionArr = [final objectForKey:@"suspension"];
    [suspensionArr addObject:@"hullTraverse"];
    [suspensionArr addObject:@"speedLimit"];
    [suspensionArr addObject:@"hardTerrainResistance"];
    [suspensionArr addObject:@"mediumTerrainResistance"];
    [suspensionArr addObject:@"softTerrainResistance"];
    [suspensionArr addObject:@"movementDispersionSuspension"];
    
    return final;
}

- (NSArray *)combinedModulesKeyArrayWithTank:(Tank *)t
{
    NSArray *keys;
    if (self.hasTurret || t.hasTurret) {
        keys = [Tank turretedIndex];
    } else {
        keys = [Tank nonTurretedIndex];
    }
    return keys;
}

// Combines the attributes of two tanks for a comparison view
- (NSDictionary *)combinedAttributesHashWithTank:(Tank *)t
{
    NSDictionary *fullList = [Tank allAttributes];
    NSArray *tankOneAtt = [self attributesList];
    NSArray *tankTwoAtt = [t attributesList];
    NSMutableDictionary *final = [[NSMutableDictionary alloc] init];
    
    // Grab the modules list depending on if one or the other has a turret
    NSArray *keys = [self combinedModulesKeyArrayWithTank:t];
    
    // Set up the final structure based on the index keys
    for (NSString *key in keys) {
        [final setObject:[[NSMutableArray alloc] init] forKey:key];
    }
    
    // Go through the list of all possible keys, if one of the two tanks has it
    // add that to the final dictionary to use when creating the the comparison
    for (NSString *key in fullList) {
        NSArray *attArr = fullList[key];
        for (NSString *att in attArr) {
            if ([tankOneAtt containsObject:att] || [tankTwoAtt containsObject:att]) {
                [final[key] addObject:att];
            }
        }
    }
    
    return final;
}

// Creates a flat list of all the tank's attributes, same idea as above, but not separated
// into the individual modules, used in the compare views
- (NSArray *)attributesList
{
    NSDictionary *hash = self.attributesHash;
    NSMutableArray *final = [[NSMutableArray alloc] init];
    for (NSString *key in hash) {
        for (NSString *att in hash[key]) {
            [final addObject:att];
        }
    }
    return final;
}

// Setting all values to their stock configuration
- (void)setAllValuesStock
{
    // Low hanging fruit: deal with the modules that are the same with all tanks
    for (Engine *engineMod in self.availableEngines) {
        if (engineMod.stockModule) {
            self.engine = engineMod;
        }
    }
    for (Radio *radioMod in self.availableRadios) {
        if (radioMod.stockModule) {
            self.radio = radioMod;
        }
    }
    for (Suspension *suspensionMod in self.availableSuspensions) {
        if (suspensionMod.stockModule) {
            self.suspension = suspensionMod;
        }
    }
    // Set the turret, doing it in this order allows tanks with a turret to access the right
    // array of guns, since attributes change based on the turret used
    if (self.hasTurret) {
        for (Turret *turretMod in self.availableTurrets) {
            if (turretMod.stockModule) {
                self.turret = turretMod;
            }
        }
        // Now that the turret has been changed, we can access the guns that go with it
        for (Gun *gunMod in self.turret.availableGuns) {
            if (gunMod.stockModule) {
                self.turret.gun = gunMod;
            }
        }
    } else {
        // If it doesn't have a turret, then you can directly change the gun
        for (Gun *gunMod in self.hull.availableGuns) {
            if (gunMod.stockModule) {
                self.hull.gun = gunMod;
            }
        }
    }
}

// The inverse of the previous method, sets all values to their top values
- (void)setAllValuesTop
{
    // Low hanging fruit: deal with the modules that are the same with all tanks
    for (Engine *engineMod in self.availableEngines) {
        if (engineMod.topModule) {
            self.engine = engineMod;
        }
    }
    for (Radio *radioMod in self.availableRadios) {
        if (radioMod.topModule) {
            self.radio = radioMod;
        }
    }
    for (Suspension *suspensionMod in self.availableSuspensions) {
        if (suspensionMod.topModule) {
            self.suspension = suspensionMod;
        }
    }
    // Set the turret, doing it in this order allows tanks with a turret to access the right
    // array of guns, since attributes change based on the turret used
    if (self.hasTurret) {
        for (Turret *turretMod in self.availableTurrets) {
            if (turretMod.topModule) {
                self.turret = turretMod;
            }
        }
        for (Gun *gunMod in self.turret.availableGuns) {
            if (gunMod.topModule) {
                self.turret.gun = gunMod;
            }
        }
    } else {
        for (Gun *gunMod in self.hull.availableGuns) {
            if (gunMod.topModule) {
                self.hull.gun = gunMod;
            }
        }
    }
}

// VARIABLE STAT CALCULATIONS

// These methods incorporate the in-game math used to determine the actual stats of a tank
// based on crew skill and equipment level

// Progressive stat = the number increases as the crew improves, view range, for example
- (float)calculateProgressiveStatWithNominalStat:(float)nominalStat
                             effectiveSkillLevel:(float)effectiveSkillLevel
                               andEquipmentBonus:(float)equipmentBonus
{
    return ((nominalStat / 0.875) * ((0.00375 * effectiveSkillLevel + 0.5) + equipmentBonus));
}

// Degressive stat = the number decreases as the crew improves, accuracy, for example
- (float)calculateDegressiveStatWithNominalStat:(float)nominalStat
                            effectiveSkillLevel:(float)effectiveSkillLevel
                              andEquipmentBonus:(float)equipmentBonus
{
    return ((nominalStat * 0.875) / (0.00375 * effectiveSkillLevel + 0.5)) + equipmentBonus;
}

// The crew gets 10% of the commanders skill points, the app doesn't include setting skill levels
// of crew members individually, you just calculate it based on an average for the entire crew, so
// the crewLevel * 1.1 approximates the effective level of everyone but the commander
- (float)crewSkillLevel
{
    return (self.crewLevel * 1.1);
}

// More of a math test than a necessary method, with improved ventilation and brothers in arms the crew
// level gains 10% and that also counts towards the commander's additional 10% bonus, a fully trained
// crew with BIA and vent should be at 121%
- (float)skillLevelVentAndBIA
{
    return ((self.crewLevel + 10.0) * 1.1);
}

// Again, calculating specific bonuses in the method rather than abstracting it, will probably be removed,
// although rammer/vent/bia is an incredibly common configuration for many tanks. This simply includes a gun
// rammer in the equation (10% bonus to ROF)
- (float)topRateOfFire
{
    return [self calculateProgressiveStatWithNominalStat:self.rateOfFire
                                     effectiveSkillLevel:self.skillLevelVentAndBIA
                                       andEquipmentBonus:0.10];
}

// This is used to check the math done in-app compared to the actual values in-game
- (float)fastestReload
{
    return 60.0 / self.topRateOfFire;
}

- (float)fastestAimTime
{
    return [self calculateDegressiveStatWithNominalStat:self.aimTime
                                    effectiveSkillLevel:self.crewSkillLevel
                                      andEquipmentBonus:0.0];
}

// PASS THROUGH PROPERTIES

- (NSArray *)availableGuns
{
    // Once again need to check for the presence of a turret to find where the guns are
    if (self.hasTurret) {
        return self.turret.availableGuns;
    } else {
        return self.hull.availableGuns;
    }
}

- (Gun *)gun
{
    if (hasTurret) {
        return turret.gun;
    } else {
        return hull.gun;
    }
}

- (float)penetration
{
    return self.gun.round.penetration;
}

- (float)aimTime
{
    return self.gun.aimTime;
}

- (float)accuracy
{
    return self.gun.accuracy;
}

- (float)rateOfFire
{
    return self.gun.rateOfFire;
}

- (float)gunDepression
{
    return self.gun.gunDepression;
}

- (float)gunElevation
{
    return self.gun.gunElevation;
}

- (float)alphaDamage
{
    return self.gun.round.damage;
}

- (BOOL)autoloader
{
    return self.gun.autoloader;
}

- (float)roundsInDrum
{
    if (self.autoloader) {
        return self.gun.roundsInDrum;
    } else {
        // In case the method is accidentally called on a non-autoloader
        return 1.0;
    }
}

- (float)drumReload
{
    if (self.autoloader) {
        return self.gun.drumReload;
    } else {
        return self.reloadTime;
    }
}

- (float)timeBetweenShots
{
    if (self.autoloader) {
        return self.gun.timeBetweenShots;
    } else {
        return self.reloadTime;
    }
}

- (float)burstDamage
{
    return self.roundsInDrum * self.alphaDamage;
}

- (float)burstLength
{
    return self.roundsInDrum * self.timeBetweenShots;
}

- (int)hitpoints
{
    if (self.hasTurret) {
        return self.baseHitpoints + turret.additionalHP;
    } else {
        return self.baseHitpoints;
    }
}


- (float)loadLimit
{
    return self.suspension.loadLimit;
}

- (float)viewRange
{
    if (self.hasTurret) {
        return self.turret.viewRange;
    } else {
        return self.hull.viewRange;
    }
}

- (float)horsepower
{
    return self.engine.horsepower;
}

- (float)fireChance
{
    return self.engine.fireChance;
}

- (float)signalRange
{
    return self.radio.signalRange;
}

- (float)movementDispersionGun
{
    return self.gun.movementDispersionGun;
}

- (float)movementDispersionSuspension
{
    return  self.suspension.movementDispersionSuspension;
}

// CALCULATED PROPERTIES

- (float)weight
{
    return (hull.weight + turret.weight + self.gun.weight + engine.weight + suspension.weight + radio.weight) / 1000.0;
}

// Horspower per ton
- (float)specificPower
{
    return (engine.horsepower / self.weight);
}

- (float)damagePerMinute
{
    return (self.gun.rateOfFire * self.gun.round.damage);
}

- (float)reloadTime
{
    if (!self.autoloader) {
        return 60.0 / self.gun.rateOfFire;
    } else {
        return self.drumReload;
    }
}

// ARMOR PORPERTIES

- (float)frontalHullArmor
{
    return self.hull.frontArmor.thickness;
}

- (float)sideHullArmor
{
    return self.hull.sideArmor.thickness;
}

- (float)rearHullArmor
{
    return self.hull.rearArmor.thickness;
}

- (float)effectiveFrontalHullArmor
{
    return self.hull.frontArmor.effectiveThickness;
}

- (float)effectiveSideHullArmor
{
    return self.hull.sideArmor.effectiveThickness;
}

- (float)effectiveRearHullArmor
{
    return self.hull.rearArmor.effectiveThickness;
}

// Turret armor methods return the hull values if there is no turret, to ensure that it always
// returns a value, and because the representation is accurate
- (float)frontalTurretArmor
{
    if (self.hasTurret) {
        return self.turret.frontArmor.thickness;
    } else {
        return self.frontalHullArmor;
    }
}

- (float)sideTurretArmor
{
    if (self.hasTurret) {
        return self.turret.sideArmor.thickness;
    } else {
        return self.sideHullArmor;
    }
}

- (float)rearTurretArmor
{
    if (self.hasTurret) {
        return self.turret.rearArmor.thickness;
    } else {
        return self.rearHullArmor;
    }
}

- (float)effectiveFrontalTurretArmor
{
    if (self.hasTurret) {
        return self.turret.frontArmor.effectiveThickness;
    } else {
        return self.effectiveFrontalHullArmor;
    }
}

- (float)effectiveSideTurretArmor
{
    if (self.hasTurret) {
        return self.turret.sideArmor.effectiveThickness;
    } else {
        return self.effectiveSideHullArmor;
    }
}

- (float)effectiveRearTurretArmor
{
    if (self.hasTurret) {
        return self.turret.rearArmor.effectiveThickness;
    } else {
        return self.effectiveRearHullArmor;
    }
}

- (int)hullTraverse
{
    return self.suspension.traverseSpeed;
}

- (int)turretTraverse
{
    if (self.hasTurret) {
        return  self.turret.traverseSpeed;
    } else {
        return self.hullTraverse;
    }
}

- (float)hardTerrainResistance
{
    return self.suspension.hardTerrainResistance;
}

- (float)mediumTerrainResistance
{
    return self.suspension.mediumTerrainResistance;
}

- (float)softTerrainResistance
{
    return self.suspension.softTerrainResistance;
}

// isStock and isTop are used to know when the "Stock Values" or "Top Values" section of the segmented
// controller should be highlighted
- (BOOL)isStock
{
    NSArray *modules = @[@"gun", @"engine", @"radio", @"suspension"];
    for (NSString *key in modules) {
        Module *mod = [self valueForKey:key];
        if (!mod.stockModule) {
            return NO;
        }
    }
    if (self.hasTurret) {
        if (!self.turret.stockModule) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isTop
{
    NSArray *modules = @[@"gun", @"engine", @"radio", @"suspension"];
    for (NSString *key in modules) {
        Module *mod = [self valueForKey:key];
        if (!mod.topModule) {
            return NO;
        }
    }
    if (self.hasTurret) {
        if (!self.turret.topModule) {
            return NO;
        }
    }
    return YES;
}

// Used by the init method to convert the string value to the enum value
TankType fetchTankType (NSString *type)
{
    if ([type isEqualToString:@"lightTank"]) {
        return LightTank;
    } else if ([type isEqualToString:@"mediumTank"]) {
        return MediumTank;
    } else if ([type isEqualToString:@"heavyTank"]) {
        return HeavyTank;
    } else if ([type isEqualToString:@"AT-SPG"]) {
        return TankDestroyer;
    } else if ([type isEqualToString:@"SPG"]) {
        return SPG;
    } else {
        return Vehicle;
    }
}

// Used by the init method to convert the string value to the enum value
TankNationality fetchTankNationality (NSString *nation)
{
    if ([nation isEqualToString:@"usa"]) {
        return American;
    } else if ([nation isEqualToString:@"gb"]) {
        return British;
    } else if ([nation isEqualToString:@"uk"]) {
        return British;
    } else if ([nation isEqualToString:@"china"]) {
        return Chinese;
    } else if ([nation isEqualToString:@"france"]) {
        return French;
    } else if ([nation isEqualToString:@"germany"]) {
        return German;
    } else if ([nation isEqualToString:@"japan"]) {
        return Japanese;
    } else if ([nation isEqualToString:@"ussr"]) {
        return Russian;
    } else {
        return Nation;
    }
}

// Used to convert the enum value to a HR string
- (NSString *)stringNationality
{
    NSString *result = @"Unknown";
    switch (self.nationality) {
        case American:
            result = @"American";
            break;
        case British:
            result = @"British";
            break;
        case Chinese:
            result = @"Chinese";
            break;
        case French:
            result = @"French";
            break;
        case German:
            result = @"German";
            break;
        case Japanese:
            result = @"Japanese";
            break;
        case Russian:
            result = @"Russian";
            break;
        case Nation:
            break;
    }
    return result;
}

// Used to convert the enum value to a HR string
- (NSString *)stringTankType
{
    NSString *result = @"Unknown";
    switch (self.type) {
        case LightTank:
            result = @"Light Tank";
            break;
        case MediumTank:
            result = @"Medium Tank";
            break;
        case HeavyTank:
            result = @"Heavy Tank";
            break;
        case TankDestroyer:
            result = @"Tank Destroyer";
            break;
        case SPG:
            result = @"SPG";
            break;
        case Vehicle:
            break;
    }
    return result;
}

// Combining the two methods above
- (NSString *)stringNationalityAndType
{
    if (self.premiumTank) {
        return [NSString stringWithFormat:@"%@ Premium %@", self.stringNationality, self.stringTankType];
    } else {
        return [NSString stringWithFormat:@"%@ %@", self.stringNationality, self.stringTankType];
    }
}

// Fetches the geometric image that corresponds with the tank type (Not the outline image of the actual tank)
- (UIImage *)imageForTankType
{
    switch (self.type) {
        case LightTank:
            return [UIImage imageNamed:@"lightTank"];
        case MediumTank:
            return [UIImage imageNamed:@"mediumTank"];
        case HeavyTank:
            return [UIImage imageNamed:@"heavyTank"];
        case TankDestroyer:
            return [UIImage imageNamed:@"tankDestroyer"];
        case SPG:
            return [UIImage imageNamed:@"spg"];
        default:
            return [UIImage imageNamed:@"lightTank"];
    }
}

// Used in pretty printing the tier numbers as Roman Numerals, switch statement is inelegant,
// but unless they add many more tiers it gets the job done
NSString *romanStringFromInt (long convert)
{
    NSString *result = @"-";
    switch (convert) {
        case 1:
            result = @"I";
            break;
        case 2:
            result = @"II";
            break;
        case 3:
            result = @"III";
            break;
        case 4:
            result = @"IV";
            break;
        case 5:
            result = @"V";
            break;
        case 6:
            result = @"VI";
            break;
        case 7:
            result = @"VII";
            break;
        case 8:
            result = @"VIII";
            break;
        case 9:
            result = @"IX";
            break;
        case 10:
            result = @"X";
            break;
    }
    return result;
}

// Will probably be deprecated, as the name implies it checks to see whether the top gun requires first
// upgrading the turret, since the module trees aren't displayed within the app
- (BOOL)isTopTurretNeededForTopGun
{
    if (self.hasTurret) {
        Turret *stock = self.availableTurrets[0];
        Turret *top = self.availableTurrets[1];
        if (stock.gun.name == top.gun.name) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

// Calculate the total experience needed to unlock all modules for an individual tank
- (int)totalExperienceNeeded
{
    int totalExp = 0;
    NSArray *modules;
    if (self.hasTurret) {
        modules = [NSArray arrayWithObjects:
                   @"availableTurrets", @"availableGuns", @"availableSuspensions", @"availableEngines",
                   @"availableRadios", nil];
    } else {
        modules = [NSArray arrayWithObjects:
                   @"availableGuns", @"availableSuspensions", @"availableEngines", @"availableRadios", nil];
    }
    for (NSString *key in modules) {
        NSArray *moduleArray = [self valueForKey:key];
        for (Module *mod in moduleArray) {
            totalExp += mod.experienceNeeded;
        }
    }
    return totalExp;
}

-(id)copyWithZone:(NSZone *)zone
{
    Tank *copy = [[[self class] allocWithZone:zone] init];
    
    // Primitive attributes
    NSArray *primitives = @[@"nationality", @"tier", @"hasTurret", @"premiumTank", @"available", @"experienceNeeded",
                            @"cost", @"crewLevel", @"baseHitpoints", @"topWeight", @"stockWeight", @"gunTraverseArc",
                            @"speedLimit", @"camoValueStationary", @"camoValueMoving", @"camoValueShooting"];
    for (NSString *key in primitives) {
        [copy setValue:[self valueForKey:key] forKey:key];
    }
    
    NSArray *strings = @[@"name", @"parent", @"child"];
    for (NSString *key in strings) {
        [copy setValue:[[self valueForKey:key] copyWithZone:zone] forKey:key];
    }
    
    // Hull
    copy.hull = [self.hull copyWithZone:zone];
    
    // Arrays
    NSArray *arrays = @[@"availableTurrets", @"availableEngines", @"availableRadios", @"availableSuspensions"];
    for (NSString *key in arrays) {
        [copy setValue:[[NSMutableArray alloc] initWithArray:[self valueForKey:key] copyItems:YES] forKey:key];
    }
    
    // Modules
    [copy setAllValuesTop];
    
    return copy;
}

@end
























