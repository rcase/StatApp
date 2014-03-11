//
//  RCFormatVariables.m
//  TankCommander
//
//  Created by Ryan Case on 11/17/13.
//  Copyright (c) 2013 Ryan Case. All rights reserved.
//

#import "RCFormatting.h"
#import "TankIPadViewController.h"
#import "ModulesViewController.h"
#import "RCButton.h"
#import "RCToolTips.h"
#import <QuartzCore/QuartzCore.h>

@implementation RCFormatting

@synthesize fontSize, darkColor, lightColor, barColor, debugGreen, debugBlue, debugPurple, columnOneXLabel,
columnOneXValue, columnTwoXLabel, columnTwoXValue, columnThreeXLabel, columnThreeXValue, labelHeight, labelWidth,
valueHeight, valueWidth, rowHeight, darkGreenColor;

+ (RCFormatting *)store
{
    // the instance of this class is stored here
    static RCFormatting *singleton = nil;
    
    // check to see if an instance already exists
    if (nil == singleton) {
        singleton  = [[[self class] alloc] init];
        // initialize variables here
        
        // Variables to provide consistent layout and colors
        singleton->fontSize = 16.0;
        singleton->darkColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0];
        singleton->lightColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        singleton->barColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
        singleton->darkGreenColor = [UIColor colorWithRed:0.5 green:0.7 blue:0.5 alpha:1.0];
        
        // Debugging Colors to show the outlines of the different views
        singleton->debugGreen = [UIColor colorWithRed:0.9 green:1.0 blue:0.9 alpha:0.8];
        singleton->debugBlue = [UIColor colorWithRed:0.9 green:0.9 blue:1.0 alpha:0.8];
        singleton->debugPurple = [UIColor colorWithRed:0.9 green:0.8 blue:1.0 alpha:0.8];
        
        // Setting column values
        singleton->columnOneXLabel = 20;
        singleton->columnOneXValue = 150;
        singleton->columnTwoXLabel = 260;
        singleton->columnTwoXValue = 390;
        singleton->columnThreeXLabel = 500;
        singleton->columnThreeXValue = 630;
        
        // Setting the size constraints
        singleton->labelWidth = 120;
        singleton->labelHeight = 24;
        singleton->valueWidth = 80;
        singleton->valueHeight = 24;
        
        // Row height to use when incrementing view height
        singleton->rowHeight = 45;
        
    }
    // return the instance of this class
    return singleton;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"RCFormatting init");
    }
    return self;
}

- (UILabel *)addLabelToView:(UIView *)view
                  withFrame:(CGRect)frame
                       text:(NSString *)text
                   fontSize:(CGFloat)size
                  fontColor:(UIColor *)color
           andTextAlignment:(NSTextAlignment)alignment
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setText:text];
    [label setFont:[UIFont systemFontOfSize:size]];
    [label setTextColor:color];
    [label setTextAlignment:alignment];
    
    [view addSubview:label];
    return label;
}

- (UIButton *)addButtonToView:(UIView *)view
                    withFrame:(CGRect)frame
                         text:(NSString *)text
                     fontSize:(CGFloat)size
                    fontColor:(UIColor *)color
          andContentAlignment:(UIControlContentHorizontalAlignment)alignment
{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont systemFontOfSize:size]];
    [button setContentHorizontalAlignment:alignment];
    
    [view addSubview:button];
    
    return button;
}

- (RCButton *)addButtonWithTarget:(id)target
                         selector:(SEL)selector
                  andControlEvent:(UIControlEvents)events
                           toView:(UIView *)view
                        withFrame:(CGRect)frame
                             text:(NSString *)text
                         fontSize:(CGFloat)size
                        fontColor:(UIColor *)color
              andContentAlignment:(UIControlContentHorizontalAlignment)alignment
{
    RCButton *button = [[RCButton alloc] initWithFrame:frame];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont systemFontOfSize:size]];
    [button setContentHorizontalAlignment:alignment];
    
    [view addSubview:button];
    
    [button addTarget:target action:selector forControlEvents:events];
    
    return button;
}

- (RCButton *)addButtonWithTarget:(id)target
                         selector:(SEL)selector
                  andControlEvent:(UIControlEvents)events
                   withButtonData:(NSString *)buttonData
                           toView:(UIView *)view
                        withFrame:(CGRect)frame
                             text:(NSString *)text
                         fontSize:(CGFloat)size
                        fontColor:(UIColor *)color
              andContentAlignment:(UIControlContentHorizontalAlignment)alignment
{
    RCButton *button = [[RCButton alloc] initWithFrame:frame];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont systemFontOfSize:size]];
    [button setButtonData:buttonData];
    [button setContentHorizontalAlignment:alignment];
    
    [view addSubview:button];
    
    [button addTarget:target action:selector forControlEvents:events];
    
    return button;
}

- (void)fullscreenPopupFromButton:(id)sender
{
    RCButton *senderButton = (RCButton *)sender;
    RCToolTips *tooltips = [RCToolTips store];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //iPad Interface
        
        // Simple animation to fade the view in
        CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [fadeIn setDuration:0.3];
        [fadeIn setFromValue:[NSNumber numberWithFloat:0.0]];
        [fadeIn setToValue:[NSNumber numberWithFloat:1.0]];
        
        // Fullscreen background button to dismiss the popup
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        UIButton *fullscreen = [[UIButton alloc] init];
        // Check device orientation to make sure it displays properly
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            [fullscreen setFrame:CGRectMake(0, 0, screenSize.height, screenSize.width)];
        } else {
            [fullscreen setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
        }
        [fullscreen setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3]];
        
        // Add the animation to the layer
        [[fullscreen layer] addAnimation:fadeIn forKey:@"fadeIn"];
        
        // Add the subview to the main view and bring it to the front
        [senderButton.superview.superview addSubview:fullscreen];
        [senderButton bringSubviewToFront:fullscreen];
        
        // Add removeFromSuperview as the action for the button, this will dismiss the view
        [fullscreen addTarget:self
                       action:@selector(dismissView:)
             forControlEvents:UIControlEventTouchUpInside];
        
        // White square to display text
        UIView *popupSquare = [[UIView alloc] init];
        CGRect bounds = [UIScreen mainScreen].bounds;
        CGSize popupSize = CGSizeMake(400, 300);
        CGPoint popupOrigin = CGPointMake(0, 0);
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            popupOrigin = CGPointMake(((bounds.size.height - popupSize.width) / 2), 200);
        } else {
            popupOrigin = CGPointMake(((bounds.size.width - popupSize.width) / 2), 200);
        }
        [popupSquare setFrame:CGRectMake(popupOrigin.x, popupOrigin.y, popupSize.width, popupSize.height)];
        [popupSquare setBackgroundColor:[UIColor whiteColor]];
        popupSquare.layer.cornerRadius = 10;
        popupSquare.layer.masksToBounds = YES;
        [fullscreen addSubview:popupSquare];
        
        // Fetch the values from the tooltips singleton to fill in the data
        NSArray *tooltipArr = [tooltips valuesForKey:senderButton.buttonData];
        
        // Label with the stat title
        [self addLabelToView:popupSquare
                   withFrame:CGRectMake(50, 20, 300, 30)
                        text:tooltipArr[0]
                    fontSize:(self.fontSize * 1.5)
                   fontColor:self.darkColor
            andTextAlignment:NSTextAlignmentCenter];
        
        // Text view with the stat description
        UITextView *textField = [[UITextView alloc] initWithFrame:CGRectMake(50, 60, 300, 200)];
        [textField setText:tooltipArr[2]];
        [textField setFont:[UIFont systemFontOfSize:self.fontSize]];
        [textField setTextColor:self.darkColor];
        [textField setUserInteractionEnabled:NO];
        
        [popupSquare addSubview:textField];
    } else {
        // iPhone Interface
    }
}

- (void)dismissView:(id)sender
{
    // Cast the sender into a UIView, which it should always be anyway
    UIView *senderView = (UIView *)sender;
    // Fade to opaque
    [UIView animateWithDuration:0.3 animations:^{
        // Fun fact, if you define the animation separately, the completion code fires immediately
        // rather than waiting for the delay as you would expect. This doesn't appear to be true
        // When the completion is another animation, all in all, non-intuitive behavior from that
        senderView.alpha = 0.0;
    } completion:^(BOOL finished) {
        // Then remove the view once the animation finishes
        [senderView removeFromSuperview];
    }];
}

@end
