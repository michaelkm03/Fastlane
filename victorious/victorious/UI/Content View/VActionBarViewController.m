//
//  VActionBarViewController.m
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActionBarViewController.h"

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
    
    self.leftLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.leftLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
    self.rightLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.rightLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
    
    self.leftButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.rightButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
}

#pragma mark - Animation
- (void)animateInWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    CGRect frame = self.view.frame;
    self.view.frame = CGRectMake(CGRectGetWidth(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
    
    self.leftLabel.alpha = 0;
    self.rightLabel.alpha = 0;
    
    [UIView animateWithDuration:duration/2
                     animations:^
     {
         self.view.frame = CGRectMake(0, CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
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
              CGRect frame = self.view.frame;
              self.view.frame = CGRectMake(CGRectGetWidth(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
          }
                          completion:completion];
     }];
}

@end
