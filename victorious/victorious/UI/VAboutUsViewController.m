//
//  VAboutUsViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VAboutUsViewController.h"

@interface VAboutUsViewController ()    <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet    UILabel*    applicationNameLabel;
@property (nonatomic, weak) IBOutlet    UILabel*    versionLabel;
@end

@implementation VAboutUsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString*   appBuildString      =   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString*   appVersionString    =   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

    
    self.applicationNameLabel.text  =   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    self.versionLabel.text = [NSString stringWithFormat:@"%@ (%@)", appBuildString, appVersionString];
}

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
