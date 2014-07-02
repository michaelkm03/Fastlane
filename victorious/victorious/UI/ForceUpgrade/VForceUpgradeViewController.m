//
//  VForceUpgradeViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VForceUpgradeAnimatedTransition.h"
#import "VForceUpgradeViewController.h"
#import "VSettingManager.h"

@interface VForceUpgradeViewController () <UIViewControllerTransitioningDelegate>

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
    NSURL *appstoreURL = [[VSettingManager sharedManager] urlForKey:kVAppStoreURL];
    if (!appstoreURL || [appstoreURL.absoluteString isEqualToString:@""])
    {
        appstoreURL = [NSURL URLWithString:@"itms-apps://itunes.com/apps"];
    }
    
    [[UIApplication sharedApplication] openURL:appstoreURL];
}

- (id<UIViewControllerTransitioningDelegate>)transitioningDelegate
{
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[VForceUpgradeAnimatedTransition alloc] init];
}

@end
