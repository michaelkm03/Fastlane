//
//  VFindFriendsViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFindFriendsViewController.h"
#import "VThemeManager.h"

@interface VFindFriendsViewController ()

@property (nonatomic, weak)   IBOutlet UIView   *headerView;
@property (nonatomic, weak)   IBOutlet UILabel  *titleLabel;
@property (nonatomic, weak)   IBOutlet UIView   *buttonsSuperview;
@property (nonatomic, weak)   IBOutlet UIButton *backButton;
@property (nonatomic, weak)   IBOutlet UIButton *doneButton;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *socialNetworkButtons;
@property (nonatomic, weak)   IBOutlet UIView   *containerView;
@property (nonatomic, strong) UIViewController  *innerViewController;

@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *socialNetworkButtonHeightConstraints;
@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *socialNetworkButtonSpacingConstraints;

@end

@implementation VFindFriendsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.headerView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
    for (UIButton *button in self.socialNetworkButtons)
    {
        button.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    }
    for (NSLayoutConstraint *heightConstraint in self.socialNetworkButtonHeightConstraints)
    {
        heightConstraint.constant = 48.5f;
    }
    for (NSLayoutConstraint *spacingConstraint in self.socialNetworkButtonSpacingConstraints)
    {
        spacingConstraint.constant = 0.5f;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.backButton.hidden = self.navigationController.viewControllers.count <= 1;
    self.doneButton.hidden = !self.presentingViewController;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -

- (void)setInnerViewController:(UIViewController *)viewController
{
    if (self.innerViewController)
    {
        [self.innerViewController willMoveToParentViewController:nil];
        [self.innerViewController.view removeFromSuperview];
        [self.innerViewController removeFromParentViewController];
    }
    
    _innerViewController = viewController;
    [self addChildViewController:viewController];
    viewController.view.frame = self.containerView.bounds;
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.containerView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
}

#pragma mark - Button Actions

- (IBAction)pressedBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pressedDone:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
