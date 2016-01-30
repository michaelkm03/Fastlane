//
//  DiscoverSearchViewController.m
//  victorious
//
//  Created by Lawrence Leach on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "MBProgressHUD.h"
#import "UIVIew+AutoLayout.h"
#import "VConstants.h"
#import "VDependencyManager.h"
#import "VDiscoverContainerViewController.h"
#import "VNavigationController.h"
#import "VNoContentView.h"
#import "VSimpleModalTransition.h"
#import "DiscoverSearchViewController.h"
#import "victorious-Swift.h"

@interface DiscoverSearchViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSString *currentUserSearchQueryText;
@property (nonatomic, strong) NSString *currentHashtagSearchQueryText;

@property (nonatomic, weak) IBOutlet UITextField *searchField;
@property (nonatomic, weak) IBOutlet UIView *searchBarView;
@property (nonatomic, weak) IBOutlet UIView *headerView;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, assign) BOOL isKeyboardShowing;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) CGFloat storyboardSearchBarHeight;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) SearchResultsViewController *currentSearchVC;
;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchBarViewHeightConstraint;
@property (nonatomic, weak) IBOutlet UIView *opaqueBackgroundView;
@property (nonatomic, weak) IBOutlet UIView *searchBarTopHorizontalRule;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;

@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation DiscoverSearchViewController

#pragma mark - Factory Methods

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Discover" bundle:nil];
    DiscoverSearchViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"search"];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

#pragma mark - View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.storyboardSearchBarHeight = self.searchBarViewHeightConstraint.constant;
    [self updateSearchBarVisibility];
    
    // Setup Search Results View Controllers
    [self setupSearchViewControllers];
    
    // Initialize their views to alpha of 0.0 to ensure first segment selection works
    self.userSearchViewController.view.alpha = 0.0f;
    self.hashtagsSearchViewController.view.alpha = 0.0f;
    
    // Setup Search Field
    self.searchField.placeholder = NSLocalizedString(@"Search people and hashtags", @"");
    [self.searchField setTextColor:[self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]];
    [self.searchField setTintColor:[self.dependencyManager colorForKey:VDependencyManagerLinkColorKey]];
    self.searchField.delegate = self;

    // Set highlighted state for close button
    [self.closeButton setImage:[UIImage imageNamed:@"CloseHighlighted"] forState:UIControlStateHighlighted];
    
    // Set tap gesture
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeButtonAction:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    self.tapGestureRecognizer.numberOfTouchesRequired = 1;
    
    // Format the segmented control
    self.segmentedControl.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self segmentedControlAction:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[VTrackingManager sharedInstance] setValue:VTrackingValueDiscoverSearch forSessionParameterWithKey:VTrackingKeyContext];
    
    // Unable to immediately make the searchBar first responder without this hack
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.searchController.searchBar becomeFirstResponder];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ( self.isBeingDismissed )
    {
        [[VTrackingManager sharedInstance] clearValueForSessionParameterWithKey:VTrackingKeyContext];
    }
}

- (BOOL)v_prefersNavigationBarHidden
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (UIColor *)statusBarBackgroundColor
{
    return [UIColor whiteColor];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Configuration

- (void)setSearchBarHidden:(BOOL)searchBarHidden
{
    _searchBarHidden = searchBarHidden;
    [self updateSearchBarVisibility];
}

- (void)updateSearchBarVisibility
{
    if ( self.isViewLoaded )
    {
        self.searchBarViewHeightConstraint.constant = self.searchBarHidden ? 0.0f : self.storyboardSearchBarHeight;
    }
}

#pragma mark - Button Actions

- (IBAction)closeButtonAction:(id)sender
{
    [self.currentSearchVC cancel];
    
    if ( self.presentingViewController != nil )
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else if ( self.navigationController != nil )
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - UISegmentControl Action

- (IBAction)segmentedControlAction:(id)sender
{
    [self.currentSearchVC cancel];
    
    SearchResultsViewController *previousSearchVC = self.currentSearchVC;
    
    switch ( self.segmentedControl.selectedSegmentIndex )
    {
        case 0:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectDiscoverSearchUser];
            self.currentSearchVC = self.userSearchViewController;
            break;
            
        case 1:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectDiscoverSearchHashtag];
            self.currentSearchVC = self.hashtagsSearchViewController;
            break;
            
        default:
            return;
    }
    
    previousSearchVC.searchResultsDelegate = nil;
    self.currentSearchVC.searchResultsDelegate = self;
    
    NSString *currentSearchTerm = self.searchController.searchBar.text;
    const BOOL isAlreadyShowingResultsForSearchTerm = self.currentSearchVC.searchTerm == currentSearchTerm;
    const BOOL isValidSearchTerm = currentSearchTerm != nil && currentSearchTerm.length > 0;
    if ( isValidSearchTerm && !isAlreadyShowingResultsForSearchTerm )
    {
        [self.currentSearchVC searchWithSearchTerm:currentSearchTerm completion:nil];
    }
    
    NSTimeInterval duration = previousSearchVC == nil ? 0.0f : 0.15f;
    [UIView animateWithDuration:duration animations:^
     {
         self.currentSearchVC.view.alpha = 1.0;
         previousSearchVC.view.alpha = 0.0;
     }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.currentSearchVC clear];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchField resignFirstResponder];
    if ( textField.text != nil && textField.text.length > 0 )
    {
        [self.currentSearchVC searchWithSearchTerm:textField.text completion:nil];
    }
    return YES;
}

@end
