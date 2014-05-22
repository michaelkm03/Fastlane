//
//  VResetCodeViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VResetCodeViewController.h"

@interface VResetCodeViewController ()

@end

@implementation VResetCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)resendEmail:(id)sender
{
    
}

@end
