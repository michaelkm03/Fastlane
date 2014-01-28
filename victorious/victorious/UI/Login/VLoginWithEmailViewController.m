//
//  VLoginWithEmailViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoginWithEmailViewController.h"

@interface VLoginWithEmailViewController ()
@property   (nonatomic, weak)   IBOutlet    UITextField*    usernameTextField;
@property   (nonatomic, weak)   IBOutlet    UITextField*    passwordTextField;
@end

@implementation VLoginWithEmailViewController

#pragma mark - Actions

- (IBAction)login:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
