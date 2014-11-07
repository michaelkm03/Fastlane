//
//  VPrivacyPoliciesViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VPrivacyPoliciesViewController.h"
#import "VSettingManager.h"

@implementation VPrivacyPoliciesViewController

#pragma mark - Actions

- (void)viewDidLoad
{
    self.urlToView = [[VSettingManager sharedManager] urlForKey:kVPrivacyUrl];
    
    [super viewDidLoad];
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
