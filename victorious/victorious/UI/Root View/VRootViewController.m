//
//  VRootViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VForceUpgradeViewController.h"
#import "VRootViewController.h"
#import "VConstants.h"

@interface VRootViewController ()

@property (nonatomic) BOOL appearing;
@property (nonatomic) BOOL shouldPresentForceUpgradeScreenOnNextAppearance;

@end

@implementation VRootViewController

+ (instancetype)rootViewController
{
    VRootViewController *rootViewController = (VRootViewController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([rootViewController isKindOfClass:self])
    {
        return rootViewController;
    }
    else
    {
        return nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.appearing = YES;
    if (self.shouldPresentForceUpgradeScreenOnNextAppearance)
    {
        self.shouldPresentForceUpgradeScreenOnNextAppearance = NO;
        [self _presentForceUpgradeScreen];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.appearing = NO;
}

- (void)presentForceUpgradeScreen
{
    if (self.appearing)
    {
        [self _presentForceUpgradeScreen];
    }
    else
    {
        self.shouldPresentForceUpgradeScreenOnNextAppearance = YES;
    }
}

- (void)_presentForceUpgradeScreen
{
    VForceUpgradeViewController *forceUpgradeViewController = [[VForceUpgradeViewController alloc] init];
    [self presentViewController:forceUpgradeViewController animated:YES completion:nil];
}

@end
