//
//  VActionBarViewController.m
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActionBarViewController.h"

#import "UIView+VFrameManipulation.h"

#import "VThemeManager.h"

@interface VActionBarViewController ()

@end

@implementation VActionBarViewController

+ (instancetype)sharedInstance
{
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.leftLabel.textAlignment = NSTextAlignmentCenter;
    self.rightLabel.textAlignment = NSTextAlignmentCenter;
    
    self.leftLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.leftLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVPollButtonFont];
    self.rightLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.rightLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVPollButtonFont];
    
    self.leftButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.rightButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
}

#pragma mark - Animation
- (void)animateInWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    [self.view setXOrigin:self.view.frame.size.width];
    
    self.leftLabel.alpha = 0;
    self.rightLabel.alpha = 0;
    
    [UIView animateWithDuration:duration/2
                     animations:^
     {
         [self.view setXOrigin:0];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:duration/2
                          animations:^
          {
              self.leftLabel.alpha = 1;
              self.rightLabel.alpha = 1;
          }
                          completion:completion];
     }];
}

- (void)animateOutWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration/2
                     animations:^
     {
         self.leftLabel.alpha = 0;
         self.rightLabel.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:duration/2
                          animations:^
          {
              [self.view setXOrigin:self.view.frame.size.width];
          }
                          completion:completion];
     }];
}

@end
