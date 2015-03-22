//
//  VPrivacyPoliciesViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VPrivacyPoliciesViewController.h"
#import "VSettingManager.h"
#import "VDependencyManager.h"

@implementation VPrivacyPoliciesViewController

#pragma mark - Actions

- (void)viewDidLoad
{
    NSString *privacyURLString = [self.dependencyManager stringForKey:kVPrivacyURL];
    self.urlToView = [NSURL URLWithString:privacyURLString];
    [super viewDidLoad];
}

@end
