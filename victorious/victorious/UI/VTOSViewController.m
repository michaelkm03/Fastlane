//
//  VTOSViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VTOSViewController.h"

@interface VTOSViewController ()    <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet    UILabel*    applicationNameLabel;
@property (nonatomic, weak) IBOutlet    UILabel*    versionLabel;
@end

@implementation VTOSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString*   appVersionString    =   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.applicationNameLabel.text  =   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    NSString*   appBuildString      =   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    self.versionLabel.text = [NSString stringWithFormat:@"%@ (%@)", appBuildString, appVersionString];
}

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
