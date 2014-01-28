//
//  VInviteWithSocialViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VInviteWithSocialViewController.h"

@interface VInviteWithSocialViewController ()
@end

@implementation VInviteWithSocialViewController

- (IBAction)done:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
