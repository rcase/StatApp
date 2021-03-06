//
//  GunView.m
//  TankCommander
//
//  Created by Ryan Case on 11/17/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import "GunView.h"
#import "RCFormatting.h"
#import "Tank.h"
#import "Gun.h"
#import "AverageTank.h"
#import "ModulesViewController.h"
#import "TankIPadViewController.h"

@implementation GunView

@synthesize tankViewController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithOrigin:(CGPoint)point andTank:(Tank *)t
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    RCFormatting *format = [RCFormatting store];
    
    CGFloat y = format.rowHeight;
    self = [self initWithFrame:CGRectMake(point.x, point.y, screenWidth, y)];
    
    if (self) {
        tank = t;
        
        UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(20, 40, 700, 2)];
        [barView setBackgroundColor:format.barColor];
        [self addSubview:barView];
        
        // Header - Tank gun name
        [format addButtonWithTarget:self
                           selector:@selector(pushModulesViewController)
                    andControlEvent:UIControlEventTouchUpInside
                             toView:self
                          withFrame:CGRectMake(20, 10, 600, 28)
                               text:[NSString stringWithFormat:@"Gun: %@", tank.gun.name]
                           fontSize:(format.fontSize * 1.5)
                          fontColor:format.darkColor
                andContentAlignment:UIControlContentHorizontalAlignmentLeft];
        
        // Header - Tank gun tier
        [format addLabelToView:self
                     withFrame:CGRectMake(680, 10, 40, 28)
                          text:romanStringFromInt(tank.gun.tier)
                      fontSize:(format.fontSize * 1.5)
                     fontColor:format.darkColor
              andTextAlignment:NSTextAlignmentRight];
        
        // Row 1, Column 1
        [format addButtonWithTarget:format
                           selector:@selector(fullscreenPopupFromButton:)
                    andControlEvent:UIControlEventTouchUpInside
                     withButtonData:@"penetration"
                             toView:self
                          withFrame:CGRectMake(format.columnOneXLabel, y, format.labelWidth, format.labelHeight)
                               text:NSLocalizedString(@"Penetration", nil)
                           fontSize:format.fontSize
                          fontColor:format.darkColor
                andContentAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnOneXValue, y, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.0f", tank.penetration]
                      fontSize:format.fontSize
                     fontColor:format.darkColor
              andTextAlignment:NSTextAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnOneXLabel, y+15, format.labelWidth, format.labelHeight)
                          text:NSLocalizedString(@"Average:", nil)
                      fontSize:format.fontSize
                     fontColor:format.lightColor
              andTextAlignment:NSTextAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnOneXValue, y+15, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.0f", tank.averageTank.penetration]
                      fontSize:format.fontSize
                     fontColor:format.lightColor
              andTextAlignment:NSTextAlignmentLeft];
        
        // Row 1, Column 2
        [format addButtonWithTarget:format
                           selector:@selector(fullscreenPopupFromButton:)
                    andControlEvent:UIControlEventTouchUpInside
                     withButtonData:@"alphaDamage"
                             toView:self
                          withFrame:CGRectMake(format.columnTwoXLabel, y, format.labelWidth, format.labelHeight)
                               text:@"Damage: "
                           fontSize:format.fontSize
                          fontColor:format.darkColor
                andContentAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnTwoXValue, y, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.0f", tank.alphaDamage]
                      fontSize:format.fontSize
                     fontColor:format.darkColor
              andTextAlignment:NSTextAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnTwoXValue, y+15, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.0f", tank.averageTank.alphaDamage]
                      fontSize:format.fontSize
                     fontColor:format.lightColor
              andTextAlignment:NSTextAlignmentLeft];
        
        // Row 1, Column 3
        [format addButtonWithTarget:format
                           selector:@selector(fullscreenPopupFromButton:)
                    andControlEvent:UIControlEventTouchUpInside
                     withButtonData:@"accuracy"
                             toView:self
                          withFrame:CGRectMake(format.columnThreeXLabel, y, format.labelWidth, format.labelHeight)
                               text:@"Accuracy"
                           fontSize:format.fontSize
                          fontColor:format.darkColor
                andContentAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnThreeXValue, y, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.2f", tank.accuracy]
                      fontSize:format.fontSize
                     fontColor:format.darkColor andTextAlignment:NSTextAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnThreeXValue, y+15, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.2f", tank.averageTank.accuracy]
                      fontSize:format.fontSize
                     fontColor:format.lightColor
              andTextAlignment:NSTextAlignmentLeft];
        
        // Row 2, Column 1
        y += format.rowHeight;
        
        [format addButtonWithTarget:format
                           selector:@selector(fullscreenPopupFromButton:)
                    andControlEvent:UIControlEventTouchUpInside
                     withButtonData:@"aimTime"
                             toView:self
                          withFrame:CGRectMake(format.columnOneXLabel, y, format.labelWidth, format.labelHeight)
                               text:@"Aim Time"
                           fontSize:format.fontSize
                          fontColor:format.darkColor
                andContentAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnOneXValue, y, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.2fs", tank.aimTime]
                      fontSize:format.fontSize
                     fontColor:format.darkColor
              andTextAlignment:NSTextAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnOneXValue, y+15, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.2fs", tank.averageTank.aimTime]
                      fontSize:format.fontSize
                     fontColor:format.lightColor
              andTextAlignment:NSTextAlignmentLeft];
        
        // Row 2, Column 2
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnTwoXLabel, y, format.labelWidth, format.labelHeight)
                          text:NSLocalizedString(@"Rate of Fire:", nil)
                      fontSize:format.fontSize
                     fontColor:format.darkColor
              andTextAlignment:NSTextAlignmentLeft];
        
        [format addButtonWithTarget:format
                           selector:@selector(fullscreenPopupFromButton:)
                    andControlEvent:UIControlEventTouchUpInside
                     withButtonData:@"rateOfFire"
                             toView:self
                          withFrame:CGRectMake(format.columnTwoXLabel, y, format.labelWidth, format.labelHeight)
                               text:@"Rate of Fire: "
                           fontSize:format.fontSize
                          fontColor:format.darkColor
                andContentAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnTwoXValue, y, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.2f", tank.rateOfFire]
                      fontSize:format.fontSize
                     fontColor:format.darkColor
              andTextAlignment:NSTextAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnTwoXValue, y+15, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.2f", tank.averageTank.rateOfFire]
                      fontSize:format.fontSize
                     fontColor:format.lightColor
              andTextAlignment:NSTextAlignmentLeft];
        
        // Row 2, Column 3
        [format addButtonWithTarget:format
                           selector:@selector(fullscreenPopupFromButton:)
                    andControlEvent:UIControlEventTouchUpInside
                     withButtonData:@"damagePerMinute"
                             toView:self
                          withFrame:CGRectMake(format.columnThreeXLabel, y, format.labelWidth, format.labelHeight)
                               text:@"DPM:"
                           fontSize:format.fontSize
                          fontColor:format.darkColor
                andContentAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnThreeXValue, y, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.0f", tank.damagePerMinute]
                      fontSize:format.fontSize
                     fontColor:format.darkColor
              andTextAlignment:NSTextAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnThreeXValue, y+15, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.0f", tank.averageTank.damagePerMinute]
                      fontSize:format.fontSize
                     fontColor:format.lightColor
              andTextAlignment:NSTextAlignmentLeft];
        
        // Row 3, Column 1
        y += format.rowHeight;
        
        [format addButtonWithTarget:format
                           selector:@selector(fullscreenPopupFromButton:)
                    andControlEvent:UIControlEventTouchUpInside
                     withButtonData:@"gunDepression"
                             toView:self
                          withFrame:CGRectMake(format.columnOneXLabel, y, format.labelWidth, format.labelHeight)
                               text:@"Depression:"
                           fontSize:format.fontSize
                          fontColor:format.darkColor
                andContentAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnOneXValue, y, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.0f", tank.gunDepression]
                      fontSize:format.fontSize
                     fontColor:format.darkColor
              andTextAlignment:NSTextAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnOneXValue, y+15, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.0f", tank.averageTank.gunDepression]
                      fontSize:format.fontSize
                     fontColor:format.lightColor
              andTextAlignment:NSTextAlignmentLeft];
        
        // Row 3, Column 2
        [format addButtonWithTarget:format
                           selector:@selector(fullscreenPopupFromButton:)
                    andControlEvent:UIControlEventTouchUpInside
                     withButtonData:@"gunElevation"
                             toView:self
                          withFrame:CGRectMake(format.columnTwoXLabel, y, format.labelWidth, format.labelHeight)
                               text:@"Elevation:"
                           fontSize:format.fontSize
                          fontColor:format.darkColor
                andContentAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnTwoXValue, y, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.0f", tank.gunElevation]
                      fontSize:format.fontSize
                     fontColor:format.darkColor
              andTextAlignment:NSTextAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnTwoXValue, y+15, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.0f", tank.averageTank.gunElevation]
                      fontSize:format.fontSize
                     fontColor:format.lightColor
              andTextAlignment:NSTextAlignmentLeft];
        
        // Row 3, Column 3
        [format addButtonWithTarget:format
                           selector:@selector(fullscreenPopupFromButton:)
                    andControlEvent:UIControlEventTouchUpInside
                     withButtonData:@"reloadTime"
                             toView:self
                          withFrame:CGRectMake(format.columnThreeXLabel, y, format.labelWidth, format.labelHeight)
                               text:@"Reload Time:"
                           fontSize:format.fontSize
                          fontColor:format.darkColor
                andContentAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnThreeXValue, y, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.2fs", tank.reloadTime]
                      fontSize:format.fontSize
                     fontColor:format.darkColor
              andTextAlignment:NSTextAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnThreeXValue, y+15, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.2fs", tank.averageTank.reloadTime]
                      fontSize:format.fontSize
                     fontColor:format.lightColor
              andTextAlignment:NSTextAlignmentLeft];
        
        // Row 4 Column 1
        y += format.rowHeight;
        
        [format addButtonWithTarget:format
                           selector:@selector(fullscreenPopupFromButton:)
                    andControlEvent:UIControlEventTouchUpInside
                     withButtonData:@"movementDispersionGun"
                             toView:self
                          withFrame:CGRectMake(format.columnOneXLabel, y, format.labelWidth, format.labelHeight)
                               text:@"Mvmt Dispersion:"
                           fontSize:format.fontSize * 0.85
                          fontColor:format.darkColor
                andContentAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnOneXValue, y, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.2f", tank.movementDispersionGun]
                      fontSize:format.fontSize
                     fontColor:format.darkColor
              andTextAlignment:NSTextAlignmentLeft];
        
        [format addLabelToView:self
                     withFrame:CGRectMake(format.columnOneXValue, y+15, format.valueWidth, format.valueHeight)
                          text:[NSString stringWithFormat:@"%0.2f", tank.averageTank.movementDispersionGun]
                      fontSize:format.fontSize
                     fontColor:format.lightColor
              andTextAlignment:NSTextAlignmentLeft];

        
        if (tank.autoloader) {
            
            // Row 4, Column 2
            [format addButtonWithTarget:format
                               selector:@selector(fullscreenPopupFromButton:)
                        andControlEvent:UIControlEventTouchUpInside
                         withButtonData:@"burstDamage"
                                 toView:self
                              withFrame:CGRectMake(format.columnTwoXLabel, y, format.labelWidth, format.labelHeight)
                                   text:@"Burst Damage:"
                               fontSize:format.fontSize
                              fontColor:format.darkColor
                    andContentAlignment:UIControlContentHorizontalAlignmentLeft];
            
            [format addLabelToView:self
                         withFrame:CGRectMake(format.columnTwoXValue, y, format.valueWidth, format.valueHeight)
                              text:[NSString stringWithFormat:@"%0.0f", tank.gun.burstDamage]
                          fontSize:format.fontSize
                         fontColor:format.darkColor
                  andTextAlignment:NSTextAlignmentLeft];
            
            // Row 4, Column 3
            [format addButtonWithTarget:format
                               selector:@selector(fullscreenPopupFromButton:)
                        andControlEvent:UIControlEventTouchUpInside
                         withButtonData:@"roundsInDrum"
                                 toView:self
                              withFrame:CGRectMake(format.columnThreeXLabel, y, format.labelWidth, format.labelHeight)
                                   text:@"Drum Capacity:"
                               fontSize:format.fontSize
                              fontColor:format.darkColor
                    andContentAlignment:UIControlContentHorizontalAlignmentLeft];
            
            [format addLabelToView:self
                         withFrame:CGRectMake(format.columnThreeXValue, y, format.valueWidth, format.valueHeight)
                              text:[NSString stringWithFormat:@"%0.0f", tank.roundsInDrum]
                          fontSize:format.fontSize
                         fontColor:format.darkColor
                  andTextAlignment:NSTextAlignmentLeft];
            
            // Row 5, Column 1
            y += format.rowHeight;
            
            [format addButtonWithTarget:format
                               selector:@selector(fullscreenPopupFromButton:)
                        andControlEvent:UIControlEventTouchUpInside
                         withButtonData:@"timeBetweenShots"
                                 toView:self
                              withFrame:CGRectMake(format.columnOneXLabel, y, format.labelWidth, format.labelHeight)
                                   text:@"Between Shots:"
                               fontSize:format.fontSize
                              fontColor:format.darkColor
                    andContentAlignment:UIControlContentHorizontalAlignmentLeft];
            
            [format addLabelToView:self
                         withFrame:CGRectMake(format.columnOneXValue, y, format.valueWidth, format.valueHeight)
                              text:[NSString stringWithFormat:@"%0.2fs", tank.timeBetweenShots]
                          fontSize:format.fontSize
                         fontColor:format.darkColor
                  andTextAlignment:NSTextAlignmentLeft];
            
            // Row 5, Column 2
            
            [format addButtonWithTarget:format
                               selector:@selector(fullscreenPopupFromButton:)
                        andControlEvent:UIControlEventTouchUpInside
                         withButtonData:@"drumReload"
                                 toView:self
                              withFrame:CGRectMake(format.columnTwoXLabel, y, format.labelWidth, format.labelHeight)
                                   text:@"Full Reload:"
                               fontSize:format.fontSize
                              fontColor:format.darkColor
                    andContentAlignment:UIControlContentHorizontalAlignmentLeft];
            
            [format addLabelToView:self
                         withFrame:CGRectMake(format.columnTwoXValue, y, format.valueWidth, format.valueHeight)
                              text:[NSString stringWithFormat:@"%0.2fs", tank.drumReload]
                          fontSize:format.fontSize
                         fontColor:format.darkColor
                  andTextAlignment:NSTextAlignmentLeft];
        }
        y += format.rowHeight;
        self.frame = CGRectMake(point.x, point.y, [UIScreen mainScreen].bounds.size.width, y);
    }
    return self;
}

- (void)pushModulesViewController
{
    ModulesViewController *mvc = [[ModulesViewController alloc] initWithTank:tank andKey:@"availableGuns"];
    [mvc setTankViewController:tankViewController];
    [tankViewController.navigationController pushViewController:mvc animated:YES];
}

@end
