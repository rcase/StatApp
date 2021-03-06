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
#import "Stat.h"
#import "StatStore.h"

@implementation RCFormatting

@synthesize fontSize, darkColor, lightColor, barColor, debugGreen, debugBlue, debugPurple, columnOneXLabel,
columnOneXValue, columnTwoXLabel, columnTwoXValue, columnThreeXLabel, columnThreeXValue, labelHeight, labelWidth,
valueHeight, valueWidth, rowHeight, darkGreenColor, screenHeight, screenWidth, highlightGreen, highlightRed,
highlightYellow;

+ (RCFormatting *)store
{
    // the instance of this class is stored here
    static RCFormatting *singleton = nil;
    
    // check to see if an instance already exists
    if (nil == singleton) {
        singleton  = [[[self class] alloc] init];
        // initialize variables here
        
        // Store the screen width and height for view centering and such
        singleton->screenWidth = [UIScreen mainScreen].bounds.size.width;
        singleton->screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        // Font size settings
        singleton->fontSize = 16;
        
        // Color Variables
        singleton->darkColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0];
        singleton->lightColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        singleton->barColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
        singleton->darkGreenColor = [UIColor colorWithRed:0.5 green:0.7 blue:0.5 alpha:1.0];
        
        // Debugging Colors to show the outlines of the different views
        singleton->debugGreen = [UIColor colorWithRed:0.9 green:1.0 blue:0.9 alpha:0.8];
        singleton->debugBlue = [UIColor colorWithRed:0.9 green:0.9 blue:1.0 alpha:0.8];
        singleton->debugPurple = [UIColor colorWithRed:0.9 green:0.8 blue:1.0 alpha:0.8];
        
        // Highlight Colors for use in the Comparison view, to display which tank wins which stat
        singleton->highlightGreen = [UIColor colorWithRed:0.9 green:1.0 blue:0.9 alpha:0.8];
        singleton->highlightRed = [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:0.8];
        singleton->highlightYellow = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:0.8];
        
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
    [label setBackgroundColor:[UIColor clearColor]];
    
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
    [button setBackgroundColor:[UIColor clearColor]];
    
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
    [button setBackgroundColor:[UIColor clearColor]];
    
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
    [button setDataString:buttonData];
    [button setContentHorizontalAlignment:alignment];
    [button setBackgroundColor:[UIColor clearColor]];
    
    [view addSubview:button];
    
    [button addTarget:target action:selector forControlEvents:events];
    
    return button;
}

- (UIView *)fullscreenPopupForKey:(NSString *)key fromPresentationOrigin:(CGPoint)origin
{
    // Grab the Stat object and the pointer to the formatting singleton
    Stat *stat = [[StatStore store] statForKey:key];
    RCFormatting *format  = [RCFormatting store];
    
    // Simple animation to fade the view in
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeIn setDuration:0.3];
    [fadeIn setFromValue:[NSNumber numberWithFloat:0.0]];
    [fadeIn setToValue:[NSNumber numberWithFloat:1.0]];
    
    // Fullscreen background button to dismiss the popup
    UIButton *fullscreen = [[UIButton alloc] init];
    // Frame is giant to ensure it covers everything regardless of scrolling, screensize, etc.
    [fullscreen setFrame:CGRectMake(0, 0, 4000, 10000)];
    [fullscreen setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3]];
    fullscreen.tag = 100;
    
    // Add the animation to the layer
    [[fullscreen layer] addAnimation:fadeIn forKey:@"fadeIn"];
    
    // Add removeFromSuperview as the action for the button, this will dismiss the view
    [fullscreen addTarget:self
                   action:@selector(dismissView:)
         forControlEvents:UIControlEventTouchUpInside];
    
    // The Popup Square
    
    // White square to display text
    UIView *popupSquare = [[UIView alloc] init];
    CGSize popupSize = CGSizeMake(400, 360);
    
    // The point of origin for the presentation layer, needed to set up the position of the popup
    CGPoint presentationOrigin = origin;
    
    // Ensure the popup frame
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGPoint popupOrigin;
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        popupOrigin = CGPointMake(((bounds.size.height - popupSize.width) / 2), 200 + presentationOrigin.y);
    } else {
        popupOrigin = CGPointMake(((bounds.size.width - popupSize.width) / 2), 200 + presentationOrigin.y);
    }
    [popupSquare setFrame:CGRectMake(popupOrigin.x, popupOrigin.y, popupSize.width, popupSize.height)];
    
    // Formatting the square (background, rounded corners, etc.)
    [popupSquare setBackgroundColor:[UIColor whiteColor]];
    popupSquare.layer.cornerRadius = 10;
    popupSquare.layer.masksToBounds = YES;
    popupSquare.tag = 200;
    [fullscreen addSubview:popupSquare];
    
    // Label with the stat title
    [format addLabelToView:popupSquare
                 withFrame:CGRectMake(50, 20, 300, 30)
                      text:stat.glossaryName
                  fontSize:(format.fontSize * 1.5)
                 fontColor:format.darkColor
          andTextAlignment:NSTextAlignmentCenter];
    
    // Text view with the stat description
    UITextView *textField = [[UITextView alloc] initWithFrame:CGRectMake(50, 60, 300, 260)];
    [textField setText:stat.definition];
    [textField setFont:[UIFont systemFontOfSize:format.fontSize]];
    [textField setTextColor:format.darkColor];
    [textField setEditable:NO];
    
    [popupSquare addSubview:textField];
    
    return fullscreen;
}

// Presents a popup explaining the stat when you tap on the stat's name.
- (void)fullscreenPopupFromButton:(id)sender
{
    // Capture and cast the button as an RCButton to use the dataString property
    RCButton *senderButton = (RCButton *)sender;
    
    CGPoint presentationOrigin = [[senderButton.superview.superview.layer presentationLayer] bounds].origin;
    UIView *fullscreen = [self fullscreenPopupForKey:senderButton.dataString
                              fromPresentationOrigin:presentationOrigin];
    
    // Add the subview to the main view and bring it to the front
    [senderButton.superview.superview addSubview:fullscreen];
    [senderButton bringSubviewToFront:fullscreen];
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

- (UIViewController *)iPhoneStatViewControllerForKey:(NSString *)key
{
    Stat *stat = [[StatStore store] statForKey:key];
    return [self iPhoneStatViewControllerForStat:stat];
}

- (UIViewController *)iPhoneStatViewControllerForStat:(Stat *)stat
{
    // Create a VC to display the stat information
    UIViewController *statView = [[UIViewController alloc] init];
    [[statView view] setBackgroundColor:[UIColor whiteColor]];
    
    RCFormatting *format = [RCFormatting store];
    
    UILabel *nameLabel = [format addLabelToView:[statView view]
                                      withFrame:CGRectMake((format.screenWidth - 200) / 2, 80, 200, 44)
                                           text:stat.glossaryName
                                       fontSize:format.fontSize * 1.5
                                      fontColor:format.darkColor
                               andTextAlignment:NSTextAlignmentCenter];
    nameLabel.minimumScaleFactor = 0.5;
    nameLabel.numberOfLines = 1;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    
    // Text view with the stat description
    UITextView *textField = [[UITextView alloc]
                             initWithFrame:CGRectMake((format.screenWidth - 300) / 2, 130, 300, (format.screenHeight - 140))];
    [textField setText:stat.definition];
    [textField setFont:[UIFont systemFontOfSize:format.fontSize]];
    [textField setTextColor:format.darkColor];
    [textField setEditable:NO];
    
    [[statView view] addSubview:textField];
    
    return statView;
}

@end
