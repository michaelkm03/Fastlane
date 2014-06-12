//
//  VTOSViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VTOSViewController.h"

@interface VTOSViewController ()    <UIWebViewDelegate>
@end

@implementation VTOSViewController

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
