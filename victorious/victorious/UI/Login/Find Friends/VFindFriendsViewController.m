//
//  VFindFriendsViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFindContactsTableViewController.h"
#import "VFindFriendsViewController.h"
#import "VSuggestedFriendsTableViewController.h"
#import "VThemeManager.h"

typedef NS_ENUM(NSInteger, VSlideDirection)
{
    VSlideDirectionNone = 0, ///< Use this to disable animation
    VSlideDirectionLeft,
    VSlideDirectionRight
};

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

@property (nonatomic, strong) VFindFriendsTableViewController *suggestedFriendsInnerViewController;
@property (nonatomic, strong) VFindFriendsTableViewController *contactsInnerViewController;
@property (nonatomic, strong) VFindFriendsTableViewController *facebookInnerViewController;
@property (nonatomic, strong) VFindFriendsTableViewController *twitterInnerViewController;
@property (nonatomic, strong) VFindFriendsTableViewController *instagramInnerViewController;

@end

@implementation VFindFriendsViewController

#pragma mark - View Lifecycle

- (void)awakeFromNib
{
    [self createInnerViewControllers];
}

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
    if (!self.innerViewController)
    {
        [self setInnerViewController:self.suggestedFriendsInnerViewController];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -

- (void)setInnerViewController:(UIViewController *)viewController
{
    [self setInnerViewController:viewController slideDirection:VSlideDirectionNone];
}

- (void)setInnerViewController:(UIViewController *)newViewController slideDirection:(VSlideDirection)direction
{
    UIViewController *oldViewController = self.innerViewController;
    if (!newViewController || oldViewController == newViewController)
    {
        return;
    }
    
    [self addChildViewController:newViewController];
    [oldViewController willMoveToParentViewController:nil];

    newViewController.view.frame = CGRectMake(direction == VSlideDirectionRight ? -CGRectGetWidth(self.containerView.bounds) * 0.5f :
                                                                                   CGRectGetWidth(self.containerView.bounds) * 0.5f,
                                              CGRectGetMinY(self.containerView.bounds),
                                              CGRectGetWidth(self.containerView.bounds),
                                              CGRectGetHeight(self.containerView.bounds));
    newViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    newViewController.view.alpha = 0;
    [self.containerView addSubview:newViewController.view];

    void (^animations)() = ^(void)
    {
        newViewController.view.alpha = 1.0f;
        newViewController.view.frame = self.containerView.bounds;
        oldViewController.view.frame = CGRectMake(direction == VSlideDirectionRight ?  CGRectGetWidth(self.containerView.bounds) * 0.5f :
                                                                                      -CGRectGetWidth(self.containerView.bounds) * 0.5f,
                                                  CGRectGetMinY(self.containerView.bounds),
                                                  CGRectGetWidth(self.containerView.bounds),
                                                  CGRectGetHeight(self.containerView.bounds));
        oldViewController.view.alpha = 0;
    };
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        oldViewController.view.alpha = 1.0f;
        [oldViewController.view removeFromSuperview];
        [oldViewController removeFromParentViewController];
        [newViewController didMoveToParentViewController:self];
    };
    
    if (direction == VSlideDirectionNone)
    {
        animations();
        completion(YES);
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:animations completion:completion];
    }
    
    _innerViewController = newViewController;
}

- (void)createInnerViewControllers
{
    self.suggestedFriendsInnerViewController = [[VSuggestedFriendsTableViewController alloc] init];
    self.contactsInnerViewController = [[VFindContactsTableViewController alloc] init];
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

- (IBAction)pressedSuggestedFriends:(id)sender
{
    if (self.innerViewController == self.suggestedFriendsInnerViewController)
    {
        return;
    }
    [self setInnerViewController:self.suggestedFriendsInnerViewController slideDirection:VSlideDirectionRight];
}

- (IBAction)pressedContacts:(id)sender
{
    if (self.innerViewController == self.contactsInnerViewController)
    {
        return;
    }
    
    VSlideDirection direction = VSlideDirectionRight;
    if (self.innerViewController == self.suggestedFriendsInnerViewController)
    {
        direction = VSlideDirectionLeft;
    }
    [self setInnerViewController:self.contactsInnerViewController slideDirection:direction];
}

- (IBAction)pressedFacebook:(id)sender
{
    
}

- (IBAction)pressedTwitter:(id)sender
{
    
}

- (IBAction)pressedInstagram:(id)sender
{
    
}

@end
