//
//  VPrivacyPoliciesViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VPrivacyPoliciesViewController.h"
#import "VDependencyManager.h"

static NSString * const kVPrivacyURL = @"privacyURL";

@implementation VPrivacyPoliciesViewController

#pragma mark - Actions

- (void)viewDidLoad
{
    NSString *privacyURLString = [self.dependencyManager stringForKey:kVPrivacyURL];
    self.urlToView = [NSURL URLWithString:privacyURLString];
    [super viewDidLoad];
}

@end
