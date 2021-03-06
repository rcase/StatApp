//
//  TankComparisonTableViewController.m
//  TankCommander
//
//  Created by Ryan Case on 3/15/14.
//  Copyright (c) 2014 Ryan Case. All rights reserved.
//

#import "TankComparisonTableViewController.h"
#import "TankIPadViewController.h"
#import "TankIPhoneViewController.h"
#import "Tank.h"
#import "AverageTank.h"
#import "CompareiPadTableViewCell.h"
#import "RCFormatting.h"
#import "Stat.h"
#import "StatStore.h"
#import "RCButton.h"

@interface TankComparisonTableViewController ()

@end

@implementation TankComparisonTableViewController

@synthesize tankOne, tankTwo, tankViewController, compareDict, moduleKeys, tankOneKeys, tankTwoKeys;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithTankOne:(Tank *)t1 andTwo:(Tank *)t2
{
    self = [super init];
    if (self) {
        NSLog(@"Comparison Init");
        // Set the tanks
        self.tankOne = t1;
        self.tankTwo = t2;
        
        if (tankOne == tankTwo) {
            self.tankTwo = [tankOne copyWithZone:nil];
        }
        
        // Grab the singleton data stores for formatting and tooltips
        self.format = [RCFormatting store];
        
        self.compareDict = [self.tankOne combinedAttributesHashWithTank:tankTwo];
        self.moduleKeys = [self.tankOne combinedModulesKeyArrayWithTank:tankTwo];
        
//        // Grab the arrays of attributes for both tanks
        self.tankOneKeys = [self.tankOne attributesList];
        self.tankTwoKeys = [self.tankTwo attributesList];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load the nib file
    UINib *nib;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nib = [UINib nibWithNibName:@"CompareiPadTableViewCell" bundle:nil];
    } else {
        nib = [UINib nibWithNibName:@"CompareiPhoneTableViewCell" bundle:nil];
    }
    
    // Register this NIB which contains the cell
    [[self tableView] registerNib:nib
           forCellReuseIdentifier:@"CompareCell"];
    
    // Other Setup
    // Create a bar button item that pops to the root view controller so you don't have to hit
    // "Back" seven times when going from a comparison view
    UIBarButtonItem *tank = [[UIBarButtonItem alloc] initWithTitle:self.tankOne.name
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action:@selector(popToTankViewController)];
    UIImage *homeImg = [UIImage imageNamed:@"homeBlue"];
    UIImage *homePressed = [UIImage imageNamed:@"homeGrey"];
    UIButton *homeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [homeBtn setBackgroundImage:homeImg forState:UIControlStateNormal];
    [homeBtn setBackgroundImage:homePressed forState:UIControlStateHighlighted];
    [homeBtn addTarget:self action:@selector(popToRootVC) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *home = [[UIBarButtonItem alloc] initWithCustomView:homeBtn];
    
    NSArray *rightBarButtons = @[home, tank];
    self.navigationItem.rightBarButtonItems = rightBarButtons;
    
    self.tableView.tableHeaderView = [self tableHeaderView];
    self.tableView.tableFooterView = [self footerView];
}

- (void)popToTankViewController
{
    [self.navigationController popToViewController:self.tankViewController animated:YES];
}

- (void)popToRootVC
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    return [self.moduleKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *key = self.moduleKeys[section];
    return [[self.compareDict valueForKey:key] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.moduleKeys[section] capitalizedString];
}

- (UIView *)tableHeaderView
{
    UIView *header = [[UIView alloc] init];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    header.frame = CGRectMake(0, 0, width, 60);
    header.backgroundColor = [UIColor whiteColor];
    
    RCButton *tankOneName = [self.format addButtonWithTarget:self
                                                    selector:@selector(pushTVC:)
                                             andControlEvent:UIControlEventTouchUpInside
                                              withButtonData:@"tankOne"
                                                      toView:header
                                                   withFrame:CGRectMake(10, 24, 100, 40)
                                                        text:self.tankOne.name
                                                    fontSize:14
                                                   fontColor:self.format.darkColor
                                         andContentAlignment:UIControlContentHorizontalAlignmentCenter |
                                            UIControlContentVerticalAlignmentCenter];
    tankOneName.autoresizingMask =
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleRightMargin;
    
    RCButton *tankTwoName = [self.format addButtonWithTarget:self
                                                    selector:@selector(pushTVC:)
                                             andControlEvent:UIControlEventTouchUpInside
                                              withButtonData:@"tankTwo"
                                                      toView:header
                                                   withFrame:CGRectMake(110, 24, 100, 40)
                                                        text:self.tankTwo.name
                                                    fontSize:14
                                                   fontColor:self.format.darkColor
                                         andContentAlignment:UIControlContentHorizontalAlignmentCenter | UIControlContentVerticalAlignmentCenter];
    tankTwoName.autoresizingMask =
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleLeftMargin;
    
    UILabel *averageLabel = [self.format addLabelToView:header
                                              withFrame:CGRectMake(210, 24, 100, 40)
                                                   text:@"Average"
                                               fontSize:14
                                              fontColor:self.format.darkColor
                                       andTextAlignment:NSTextAlignmentCenter];
    averageLabel.autoresizingMask =
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        tankOneName.frame = CGRectMake(320, 24, 140, 18);
        tankOneName.titleLabel.font = [UIFont systemFontOfSize:17];
        tankOneName.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleWidth;
        
        tankTwoName.frame = CGRectMake(470, 24, 140, 18);
        tankTwoName.titleLabel.font = [UIFont systemFontOfSize:17];
        tankTwoName.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleWidth;
        
        averageLabel.frame = CGRectMake(620, 24, 140, 18);
        averageLabel.font = [UIFont systemFontOfSize:17];
        averageLabel.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleWidth;
    }
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 44;
    } else {
        return 60;
    }
}

- (CompareiPadTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CompareiPadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompareCell"
                                                                     forIndexPath:indexPath];
    
    // Configure the cell...
    // Get the key and the associated Stat object
    NSString *modKey = self.moduleKeys[indexPath.section];
    NSString *key = [self.compareDict valueForKey:modKey][indexPath.row];
    Stat *stat = [[StatStore store] statForKey:key];
    
    // Three tanks will be displayed (compare1, compare2, average) and they can all have a different list of
    // attributes, so first we need to figure out which ones need displaying
    
    // First, the list of keys that aren't on the average tank
    NSArray *noAverages = @[@"roundsInDrum", @"drumReload", @"burstDamage", @"timeBetweenShots", @"loadLimit"];
    // Test for array inclusion, if the key is not present then it needs an average value displayed
    BOOL needsAverage = YES;
    if ([noAverages containsObject:key]) {
        needsAverage = NO;
    }
    
    // If it needs an average, begin that process
    Stat *averageStat = [[Stat alloc] initWithKey:key];
    if (needsAverage) {
        // We know that one tank or the other has this attribute, so we need to figure out which
        // Default to tankOne
        if ([self.tankOneKeys containsObject:key]) {
            averageStat.value = [NSNumber numberWithFloat:
                                 [[self.tankOne.averageTank valueForKey:key] floatValue]];
        } else {
            // Because the key exists in the combinedKeys, we know it exists on one or the other so
            // we can call this without fear of raising an error
            averageStat.value = [NSNumber numberWithFloat:
                                 [[self.tankTwo.averageTank valueForKey:key] floatValue]];
        }
    }
    
    // Next find the stat for tankOne
    Stat *tankOneStat = [[Stat alloc] initWithKey:key];
    if ([self.tankOneKeys containsObject:key]) {
        // The key exists on tankOne, so add the value to the stat
        tankOneStat.value = [NSNumber numberWithFloat:[[self.tankOne valueForKey:key] floatValue]];
    }
    
    // And the stat for tankTwo
    Stat *tankTwoStat = [[Stat alloc] initWithKey:key];
    if ([self.tankTwoKeys containsObject:key]) {
        tankTwoStat.value = [NSNumber numberWithFloat:[[self.tankTwo valueForKey:key] floatValue]];
    }

    // Grab the formatted strings, if the stat is nil it defaults to "--"
    NSString *tankOneStatString = [tankOneStat formatted];
    NSString *tankTwoStatString = [tankTwoStat formatted];
    NSString *averageStatString = [averageStat formatted];
    
    // Setting the strings
    [[cell statName] setText:stat.displayName];
    [[cell tankOneValue] setText:tankOneStatString];
    [[cell tankTwoValue] setText:tankTwoStatString];
    [[cell averageValue] setText:averageStatString];
    
    // Setting the colors
    // Highlight the better stat with green
    int comparisonResult = [tankOneStat compareStatTo:tankTwoStat];
    if (tankOneStat && tankTwoStat) {
        // If both compare tanks have the stat we can continue
        // REFACTORING CAVEAT: Don't be tempted to remove the seemingly redundant code that
        // sets the color for both labels every time. Because iOS dequeues and reuses cells,
        // once the background color has been set it will stay that way if it is not set
        // every time, leading to a lot of erroneous highlighting when you scroll back up
        
        // Place a light green highlight background on whichever cell wins the comparison
        if (comparisonResult == 1) {
            // Tank one is better
            [[cell tankOneValue] setBackgroundColor:self.format.highlightGreen];
            [[cell tankTwoValue] setBackgroundColor:[UIColor clearColor]];
        } else if (comparisonResult == -1) {
            // Tank two is better
            [[cell tankTwoValue] setBackgroundColor:self.format.highlightGreen];
            [[cell tankOneValue] setBackgroundColor:[UIColor clearColor]];
        } else {
            // They are equal, make them both yellow
            [[cell tankOneValue] setBackgroundColor:self.format.highlightYellow];
            [[cell tankTwoValue] setBackgroundColor:self.format.highlightYellow];
        }
    }
    
    // Set the average value to a light gray
    [[cell averageValue] setTextColor:self.format.lightColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *modKey = self.moduleKeys[indexPath.section];
    NSString *key = [self.compareDict valueForKey:modKey][indexPath.row];
    Stat *stat = [[StatStore store] statForKey:key];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGPoint presOrigin = [self.view.layer.presentationLayer bounds].origin;
        UIView *popup = [self.format fullscreenPopupForKey:stat.key
                                    fromPresentationOrigin:presOrigin];
        
        [self.view addSubview:popup];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        UIViewController *vc = [self.format iPhoneStatViewControllerForStat:stat];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushTVC:(RCButton *)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        TankIPadViewController *tvc = [[TankIPadViewController alloc] init];
        [tvc setCompare:YES];
        if ([sender.dataString isEqualToString:@"tankOne"]) {
            [tvc setTank:self.tankOne];
        } else {
            [tvc setTank:self.tankTwo];
        }
        [self.navigationController pushViewController:tvc animated:YES];
    } else {
        TankIPhoneViewController *tvc = [[TankIPhoneViewController alloc] init];
        [tvc setCompare:YES];
        if ([sender.dataString isEqualToString:@"tankOne"]) {
            [tvc setTank:self.tankOne];
        } else {
            [tvc setTank:self.tankTwo];
        }
        [self.navigationController pushViewController:tvc animated:YES];
    }
}

- (UIView *)footerView
{
    RCFormatting *format = [RCFormatting store];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    
    [format addButtonWithTarget:self
                       selector:@selector(presentHelpView)
                andControlEvent:UIControlEventTouchUpInside
                 withButtonData:@"howTo"
                         toView:footer
                      withFrame:CGRectMake(20, 0, 100, 24)
                           text:@"HELP"
                       fontSize:13
                      fontColor:format.darkColor
            andContentAlignment:UIControlContentVerticalAlignmentTop | UIControlContentHorizontalAlignmentLeft];
    
    return footer;
}

- (void)presentHelpView
{
    RCFormatting *format = [RCFormatting store];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGPoint presOrigin = [self.view.layer.presentationLayer bounds].origin;
        UIView *popup = [format fullscreenPopupForKey:@"howTo"
                               fromPresentationOrigin:presOrigin];
        [self.view addSubview:popup];
    } else {
        UIViewController *vc = [format iPhoneStatViewControllerForKey:@"howTo"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end



























