//
//  VDiscoverContainerViewController.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDiscoverContainerViewController.h"
#import "VDiscoverConstants.h"
#import "VUser.h"
#import "VUserProfileViewController.h"
#import "VSettingManager.h"
#import "VDiscoverViewControllerProtocol.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Users.h"
#import "VUser.h"

// Dependency Manager
#import "VDependencyManager.h"

// Users and Tags Search
#import "VUsersAndTagsSearchViewController.h"

// Transition
#import "VSearchResultsTransition.h"
#import "VTransitionDelegate.h"

@interface VDiscoverContainerViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *searchField;
@property (nonatomic, weak) IBOutlet UIButton *searchIconButton;
@property (nonatomic, weak) id<VDiscoverViewControllerProtocol> childViewController;

@property (nonatomic, strong) UINavigationController *searchNavigationController;
@property (nonatomic, strong) VUsersAndTagsSearchViewController *usersAndTagsSearchViewController;
@property (nonatomic, strong) VTransitionDelegate *transitionDelegate;

@end

@implementation VDiscoverContainerViewController

#pragma mark - Initializers

+ (VDiscoverContainerViewController *)instantiateFromStoryboard:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateViewControllerWithIdentifier:@"discover"];
}

#pragma mark VHasManagedDependencies conforming initializer

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VDiscoverContainerViewController *discoverContainer = [self instantiateFromStoryboard:@"Discover"];
    discoverContainer.dependencyManager = dependencyManager;
    return discoverContainer;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.searchField.placeholder = NSLocalizedString(@"Search people and hashtags", @"");
    self.searchField.delegate = self;

    VSearchResultsTransition *viewTransition = [[VSearchResultsTransition alloc] init];
    self.transitionDelegate = [[VTransitionDelegate alloc] initWithTransition:viewTransition];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSuggestedPersonProfile:)
                                                 name:kVDiscoverUserProfileSelectedNotification
                                               object:nil];

    NSLayoutConstraint *searchTopConstraint = [NSLayoutConstraint constraintWithItem:self.searchBarContainer
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.topLayoutGuide
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1.0
                                                                            constant:0];
    [self.view addConstraint:searchTopConstraint];
    [self.view layoutIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Show Profile

- (void)showSuggestedPersonProfile:(NSNotification *)note
{
    if ( note.userInfo == nil )
    {
        return;
    }

    VUser *user = note.userInfo[ kVDiscoverUserProfileSelectedKeyUser ];
    if ( user == nil )
    {
        return;
    }

    VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:user];
    if ( self.navigationController != nil )
    {
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
    else
    {
        [self presentViewController:profileViewController animated:YES completion:nil];
    }
}

#pragma mark - Button Actions

- (IBAction)closeButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)searchIconButtonAction:(id)sender
{
    [self.searchField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Release the search field
    [self.searchField resignFirstResponder];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectSearchBar];

    VUsersAndTagsSearchViewController *searchViewController = [VUsersAndTagsSearchViewController initWithDependencyManager:self.dependencyManager];
    searchViewController.transitioningDelegate = self.transitionDelegate;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.destinationViewController conformsToProtocol:@protocol(VDiscoverViewControllerProtocol)] )
    {
        self.childViewController = (id<VDiscoverViewControllerProtocol>)segue.destinationViewController;
    }

    if ( [[segue identifier] isEqualToString:@"usersTagsSearchSegue"] )
    {
        self.usersAndTagsSearchViewController = segue.destinationViewController;
    }
}

#pragma mark - UINavigationControllerDelegate methods

#if 0
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    return [self.transitionDelegate navigationController:navigationController
                         animationControllerForOperation:operation
                                      fromViewController:fromVC
                                        toViewController:toVC];
}
#endif

@end
