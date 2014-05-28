//
//  VInviteWithSocialViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VInviteFriendsViewController.h"
#import "VThemeManager.h"

@interface VInviteFriendsViewController ()
@property (nonatomic, weak)     IBOutlet    UIToolbar*      segmentedToolbar;
@end

@implementation VInviteFriendsViewController

#pragma mark - Actions

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.segmentedToolbar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.segmentedToolbar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[VThemeManager sharedThemeManager] applyNormalNavBarStyling];
    self.navigationController.navigationBar.translucent = NO;
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
