//
//  VForceUpgradeViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VForceUpgradeViewController.h"

@interface VForceUpgradeViewController ()

@property (nonatomic, weak) IBOutlet UILabel *label;

@end

@implementation VForceUpgradeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.minimumLineHeight = 30.0f;
    paragraph.maximumLineHeight = 40.0f;
    paragraph.alignment = NSTextAlignmentCenter;
    
    self.label.attributedText = [[NSAttributedString alloc] initWithString:self.label.text
                                                                attributes:@{ NSParagraphStyleAttributeName: paragraph }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (IBAction)upgradeNowTapped:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/apps"]];
}

@end
