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
#import "VDiscoverViewControllerProtocol.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Users.h"
#import "VUser.h"
#import "UIViewController+VLayoutInsets.h"

// Dependency Manager
#import "VDependencyManager.h"
#import "VDependencyManager+VUserProfile.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VNavigationItem.h"

// Users and Tags Search
#import "VUsersAndTagsSearchViewController.h"

// Transition
#import "VSearchResultsTransition.h"
#import "VTransitionDelegate.h"
#import "VDiscoverDeepLinkHandler.h"
#import "VCoachmarkDisplayer.h"
#import "UIViewController+VAccessoryScreens.h"

@interface VDiscoverContainerViewController () <UITextFieldDelegate, VMultipleContainerChild, VBackgroundContainer, VCoachmarkDisplayer>

@property (nonatomic, weak) IBOutlet UITextField *searchField;
@property (nonatomic, weak) IBOutlet UIButton *searchIconButton;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *horizontalRules;
@property (nonatomic, weak) IBOutlet UIImageView *searchIconImageView;
@property (nonatomic, weak) id<VDiscoverViewControllerProtocol> childViewController;

@property (nonatomic, strong) UINavigationController *searchNavigationController;
@property (nonatomic, strong) VUsersAndTagsSearchViewController *usersAndTagsSearchViewController;
@property (nonatomic, strong) VTransitionDelegate *transitionDelegate;

@property (nonatomic, strong) NSLayoutConstraint *searchTopConstraint;

@end

@implementation VDiscoverContainerViewController

@synthesize multipleContainerChildDelegate; ///< VMultipleContainerChild

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
    [dependencyManager configureNavigationItem:discoverContainer.navigationItem];
    return discoverContainer;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.searchField.placeholder = NSLocalizedString(@"Search people and hashtags", @"");
    self.searchField.textColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    self.searchField.delegate = self;

    VSearchResultsTransition *viewTransition = [[VSearchResultsTransition alloc] init];
    self.transitionDelegate = [[VTransitionDelegate alloc] initWithTransition:viewTransition];

    self.extendedLayoutIncludesOpaqueBars = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
    [self.horizontalRules enumerateObjectsUsingBlock:^(UIView *horizontalRule, NSUInteger idx, BOOL *stop)
    {
        horizontalRule.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    }];
    self.searchIconImageView.image = [self.searchIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.searchIconImageView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.dependencyManager configureNavigationItem:self.navigationItem];
    
    [self updateAccessoryScreens];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSuggestedPersonProfile:)
                                                 name:kVDiscoverUserProfileSelectedNotification
                                               object:nil];

    self.searchTopConstraint = [NSLayoutConstraint constraintWithItem:self.searchBarContainer
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.view
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1.0
                                                                            constant:0];
    self.searchTopConstraint.constant = self.v_layoutInsets.top;
    [self.view addConstraint:self.searchTopConstraint];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self v_addBadgingToAccessoryScreensWithDependencyManager:self.dependencyManager];
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

#pragma mark - mark

- (id<VDeeplinkHandler>)deepLinkHandlerForURL:(NSURL *)url
{
    VDiscoverDeepLinkHandler *handler = [[VDiscoverDeepLinkHandler alloc] init];
    handler.navigationDestination = self;
    return handler;
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

    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:user];
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

    VUsersAndTagsSearchViewController *searchViewController = [VUsersAndTagsSearchViewController newWithDependencyManager:self.dependencyManager];
    searchViewController.transitioningDelegate = self.transitionDelegate;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

#pragma mark - Navigation

- (void)v_setLayoutInsets:(UIEdgeInsets)v_layoutInsets
{
    [super v_setLayoutInsets:v_layoutInsets];
    
    self.searchTopConstraint.constant = self.v_layoutInsets.top;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.destinationViewController conformsToProtocol:@protocol(VDiscoverViewControllerProtocol)] )
    {
        self.childViewController = (id<VDiscoverViewControllerProtocol>)segue.destinationViewController;
        self.childViewController.dependencyManager = self.dependencyManager;
    }

    if ( [[segue identifier] isEqualToString:@"usersTagsSearchSegue"] )
    {
        self.usersAndTagsSearchViewController = segue.destinationViewController;
    }
}

- (void)updateAccessoryScreens
{
    [self v_addAccessoryScreensWithDependencyManager:self.dependencyManager];
}

#pragma mark - VMultipleContainerChild

- (void)multipleContainerDidSetSelected:(BOOL)isDefault
{
    // This event is not actually stream related, its name remains for legacy purposes
    NSDictionary *params = @{ VTrackingKeyStreamName : [self.dependencyManager stringForKey:VDependencyManagerTitleKey] ?: @"Discover" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectStream parameters:params];
    
    [self updateAccessoryScreens];
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

#pragma mark - VCoachmarkDisplayer

- (NSString *)screenIdentifier
{
    return [self.dependencyManager stringForKey:VDependencyManagerIDKey];
}

- (BOOL)selectorIsVisible
{
    return !self.navigationController.navigationBarHidden;
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

#pragma mark - VTabMenuContainedViewControllerNavigation

- (void)reselected
{
    if ( [self.childViewController conformsToProtocol:@protocol(VTabMenuContainedViewControllerNavigation)] )
    {
        [((id<VTabMenuContainedViewControllerNavigation>)self.childViewController) reselected];
    }
}

@end
