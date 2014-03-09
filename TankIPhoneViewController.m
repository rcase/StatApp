//
//  TankIPhoneViewController.m
//  TankCommander
//
//  Created by Ryan Case on 3/6/14.
//  Copyright (c) 2014 Ryan Case. All rights reserved.
//

#import "TankIPhoneViewController.h"
#import "Tank.h"
#import "AverageTank.h"
#import "ModulesViewController.h"
#import "RCButton.h"
#import "StatCell.h"
#import "RCFormatting.h"
#import "SelectorView.h"

@interface TankIPhoneViewController ()

@end

@implementation TankIPhoneViewController

@synthesize tank, turretedIndex, nonTurretedIndex;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.turretedIndex = @[@"gun", @"hull", @"turret", @"suspension", @"engine", @"radio"];
        self.nonTurretedIndex = @[@"gun", @"hull", @"suspension", @"engine", @"radio"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load the nib file
    UINib *nib = [UINib nibWithNibName:@"StatCell" bundle:nil];
    
    // Register this NIB which contains the cell
    [[self tableView] registerNib:nib
           forCellReuseIdentifier:@"StatCell"];
    
    [self.tableView reloadData];
    
    // Adding the Header
    RCFormatting *format = [RCFormatting store];
    // Container view
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 120)];
    [header setBackgroundColor:[UIColor whiteColor]];
    
    [format addLabelToView:header
                 withFrame:CGRectMake(0, 10, width, 30)
                      text:tank.name
                  fontSize:(format.fontSize * 1.5)
                 fontColor:format.darkColor
          andTextAlignment:NSTextAlignmentCenter];
    
    CGPoint origin = CGPointMake(0, 40);
    SelectorView *selectorView = [[SelectorView alloc] initForIPhoneWithOrigin:origin andTank:tank];
    [selectorView setTankViewController:self];
    [header addSubview:selectorView];
        
    // Finally set the tableHeaderView property
    self.tableView.tableHeaderView = header;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.tank.equippedModulesNameArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSDictionary *tankHash = tank.attributesHash;
    if (tank.hasTurret) {
        NSArray *modArr = [tankHash valueForKey:turretedIndex[section]];
        return [modArr count];
    } else {
        NSArray *modArr = [tankHash valueForKey:nonTurretedIndex[section]];
        return [modArr count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StatCell";
    StatCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *tankHash = tank.attributesHash;
    NSArray *attArr = [[NSArray alloc] init];
    if (tank.hasTurret) {
        attArr = [tankHash objectForKey:turretedIndex[indexPath.section]];
    } else {
        attArr = [tankHash objectForKey:nonTurretedIndex[indexPath.section]];
    }
    
    NSString *name = [NSString stringWithFormat:@"%@", attArr[indexPath.row][1]];
    NSString *value = [NSString stringWithFormat:@"%@", [tank valueForKey:attArr[indexPath.row][0]]];
    NSString *average = [NSString stringWithFormat:@"%@", [tank.averageTank valueForKey:attArr[indexPath.row][0]]];
    
    [[cell stat] setText:name];
    [[cell statValue] setText:value];
    [[cell statAverage] setText:average];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Grab the array of modules for the tank
    NSArray *modArray = self.tank.equippedModulesNameArray;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // Create a view to add the button to
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, width, 44)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    // Create and format the button
    RCButton *button = [[RCButton alloc] initWithFrame:CGRectMake(10, 0, width, 42)];
    [button setButtonData:modArray[section][1]];
    [button setTitle:modArray[section][0] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont systemFontOfSize:16.0]];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    
    // Set the button target
    [button addTarget:self
               action:@selector(pushModulesViewController:)
     forControlEvents:UIControlEventTouchUpInside];
    
    // Add it to the container view
    [headerView addSubview:button];
    
    // and return it
    return headerView;
}

- (void)pushModulesViewController:(RCButton *)sender
{
    NSString *key = sender.buttonData;
    if (![key isEqualToString:@"hull"]) {
        ModulesViewController *mvc = [[ModulesViewController alloc] initWithTank:tank andKey:key];
        [mvc setTankViewController:self];
        [self.navigationController pushViewController:mvc animated:YES];
    }
}

@end
