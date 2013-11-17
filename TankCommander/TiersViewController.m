//
//  TiersViewController.m
//  TankCommander
//
//  Created by Ryan Case on 11/16/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import "TiersViewController.h"
#import "TankStore.h"
#import "TypesViewController.h"
#import "TierCell.h"
#import "Tank.h"

@interface TiersViewController ()

@end

@implementation TiersViewController

@synthesize keys, keyStrings, allTanks;

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        keys = @[@"tier1", @"tier2", @"tier3", @"tier4", @"tier5",
                 @"tier6", @"tier7", @"tier8", @"tier9", @"tier10"];
        keyStrings = @[@"Tier 1", @"Tier 2", @"Tier 3", @"Tier 4", @"Tier 5",
                       @"Tier 6", @"Tier 7", @"Tier 8", @"Tier 9", @"Tier 10"];
        allTanks = [TankStore allTanks];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load the nib file
    UINib *nib = [UINib nibWithNibName:@"TierCell" bundle:nil];
    
    // Register this NIB which contains the cell
    [[self tableView] registerNib:nib
           forCellReuseIdentifier:@"TierCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [keys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TierCell";
    TierCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [[cell tierLabel] setText:keyStrings[indexPath.row]];
    [[cell tierRomanLabel] setText:romanStringFromInt(indexPath.row + 1)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tierKey = keys[indexPath.row];
    TypesViewController *tvc = [[TypesViewController alloc] initWithTier:[allTanks valueForKey:tierKey]];
    
    [self.navigationController pushViewController:tvc animated:YES];
}

@end