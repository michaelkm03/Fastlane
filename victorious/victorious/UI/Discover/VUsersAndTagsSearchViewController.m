//
//  VUsersAndTagsSearchViewController.m
//  victorious
//
//  Created by Lawrence Leach on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUsersAndTagsSearchViewController.h"
#import "VNavigationController.h"
#import "VDiscoverContainerViewController.h"

// VObjectManager
#import "VObjectManager.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Discover.h"
#import "VHashtag+RestKit.h"

// Dependency Manager
#import "VDependencyManager.h"

// Search Results
#import "VUserSearchResultsViewController.h"
#import "VTagsSearchResultsViewController.h"

// No Content View
#import "VNoContentView.h"

// Constants
#import "VConstants.h"

// Transtion
#import "VSimpleModalTransition.h"

#import "UIVIew+AutoLayout.h"

NSString *const kVUserSearchResultsChangedNotification = @"VUserSearchResultsChangedNotification";
NSString *const kVHashtagsSearchResultsChangedNotification = @"VHashtagsSearchResultsChangedNotification";

static NSInteger const kVMaxSearchResults = 1000;

@interface VUsersAndTagsSearchViewController () <UITextFieldDelegate, VUserSearchResultsViewControllerDelegate, VTagsSearchResultsViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *searchField;
@property (nonatomic, weak) IBOutlet UIView *searchBarView;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentControl;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) VUserSearchResultsViewController *userSearchResultsVC;
@property (nonatomic, strong) VTagsSearchResultsViewController *tagsSearchResultsVC;

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, assign) BOOL isKeyboardShowing;
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VUsersAndTagsSearchViewController

#pragma mark - Factory Methods

+ (instancetype)usersAndTagsSearchViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Discover" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"search"];
}

+ (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VUsersAndTagsSearchViewController *usersAndTagsVC = [self usersAndTagsSearchViewController];
    usersAndTagsVC.dependencyManager = dependencyManager;
    return usersAndTagsVC;
}

#pragma mark - View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup Search Results View Controllers
    self.userSearchResultsVC = [VUserSearchResultsViewController newWithDependencyManager:self.dependencyManager];
    self.userSearchResultsVC.delegate = self;
    self.tagsSearchResultsVC = [VTagsSearchResultsViewController newWithDependencyManager:self.dependencyManager];
    self.tagsSearchResultsVC.delegate = self;
    
    // Add view controllers to container view
    [self addChildViewController:self.tagsSearchResultsVC];
    [self.searchResultsContainerView addSubview:self.tagsSearchResultsVC.view];
    [self.tagsSearchResultsVC didMoveToParentViewController:self];
    [self.view v_addFitToParentConstraintsToSubview:self.tagsSearchResultsVC.view];
    
    [self addChildViewController:self.userSearchResultsVC];
    [self.searchResultsContainerView addSubview:self.userSearchResultsVC.view];
    [self.userSearchResultsVC didMoveToParentViewController:self];
    [self.view v_addFitToParentConstraintsToSubview:self.userSearchResultsVC.view];
    
    // Format the segmented control
    self.segmentControl.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.segmentControl.selectedSegmentIndex = 0;
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add NSNotification Observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(segmentControlAction:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchFieldTextChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.segmentControl.selectedSegmentIndex == 0)
    {
        [self.userSearchResultsVC.tableView reloadData];
    }
    else
    {
        [self.tagsSearchResultsVC.tableView reloadData];
    }

    [self.searchField becomeFirstResponder];
    
    [[VTrackingManager sharedInstance] setValue:VTrackingValueDiscoverSearch forSessionParameterWithKey:VTrackingKeyContext];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove NSNotification Observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    if ( self.isBeingDismissed )
    {
        [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyContext];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)v_prefersNavigationBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Button Actions

- (IBAction)closeButtonAction:(id)sender
{
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

- (IBAction)segmentControlAction:(id)sender
{
    CGFloat bottomInsetHeight = self.keyboardHeight;
    
    // Perform search
    if ( self.segmentControl.selectedSegmentIndex == 0 )
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectDiscoverSearchUser];
        
        self.userSearchResultsVC.view.alpha = 1.0f;
        self.tagsSearchResultsVC.view.alpha = 0;
        
        if ( self.searchField.text.length > 0 )
        {
            [self userSearch:sender];
        }
        
        if (self.isKeyboardShowing)
        {
            [self.userSearchResultsVC.tableView setContentInset:UIEdgeInsetsMake(0, 0, bottomInsetHeight, 0)];
        }
    }
    else if ( self.segmentControl.selectedSegmentIndex == 1 )
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectDiscoverSearchHashtag];
        
        self.userSearchResultsVC.view.alpha = 0;
        self.tagsSearchResultsVC.view.alpha = 1.0f;

        if ( self.searchField.text.length > 0 )
        {
            [self hashtagSearch:sender];
        }

        if (self.isKeyboardShowing)
        {
            [self.tagsSearchResultsVC.tableView setContentInset:UIEdgeInsetsMake(0, 0, bottomInsetHeight, 0)];
        }
    }
}

#pragma mark - Search Actions

- (void)hashtagSearch:(id)sender
{
    VSuccessBlock searchSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSMutableArray *searchResults = [[NSMutableArray alloc] init];
        NSArray *tags = [[fullResponse valueForKey:kVPayloadKey] valueForKey:kVObjectsKey];
        
        [tags enumerateObjectsUsingBlock:^(NSString *tag, NSUInteger idx, BOOL *stop)
        {
            VHashtag *newTag = [[VObjectManager sharedManager] objectWithEntityName:[VHashtag entityName]
                                                                           subclass:[VHashtag class]];
            newTag.tag = tag;
            [searchResults addObject:newTag];

        }];
        if ( searchResults.count > 0 )
        {
            [self.tagsSearchResultsVC setSearchResults:searchResults];
        }
        else
        {
            self.tagsSearchResultsVC.searchResults = nil;
            [self.tagsSearchResultsVC.tableView reloadData];
            [self showNoResultsReturnedForSearch];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kVHashtagsSearchResultsChangedNotification object:nil];
    };
    
    VFailBlock searchFail = ^(NSOperation *operation, NSError *error)
    {
        VLog(@"\n\nHashtag Search Failed with the following error:\n%@", error);
    };

    NSString *searchTerm = [self.searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (searchTerm.length > 0)
    {
        [[VObjectManager sharedManager] findHashtagsBySearchString:searchTerm
                                                      limitPerPage:kVMaxSearchResults
                                                      successBlock:searchSuccess
                                                         failBlock:searchFail];
    }
    else
    {
        NSArray *results = [[NSArray alloc] init];
        self.tagsSearchResultsVC.searchResults = (NSMutableArray *)results;
    }
}

- (void)userSearch:(id)sender
{
    VSuccessBlock searchSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSSortDescriptor   *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        NSArray *results = [resultObjects sortedArrayUsingDescriptors:@[sort]];
        
        if (results.count > 0)
        {
            [self.userSearchResultsVC setSearchResults:(NSMutableArray *)results];
        }
        else
        {
            self.userSearchResultsVC.searchResults = nil;
            [self.userSearchResultsVC.tableView reloadData];
            [self showNoResultsReturnedForSearch];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kVUserSearchResultsChangedNotification object:nil];
    };
    
    if ( [self.searchField.text length] > 0 )
    {
        [[VObjectManager sharedManager] findUsersBySearchString:self.searchField.text
                                                          limit:kVMaxSearchResults
                                                        context:VObjectManagerSearchContextDiscover
                                               withSuccessBlock:searchSuccess
                                                      failBlock:nil];
    }
    else
    {
        NSArray *results = [[NSArray alloc] init];
        self.userSearchResultsVC.searchResults = (NSMutableArray *)results;
    }
}

#pragma mark - VUserSearchResultsViewControllerDelegate

- (void)userSearchComplete:(VUserSearchResultsViewController *)userSearchResultsViewController
{
    [self closeButtonAction:userSearchResultsViewController];
}

#pragma mark - VTagsSearchResultsViewControllerDelegate

- (void)tagsSearchComplete:(VTagsSearchResultsViewController *)tagsSearchResultsViewController
{
    [self closeButtonAction:tagsSearchResultsViewController];
}

#pragma mark - Search Field Text Changed

- (void)searchFieldTextChanged:(NSNotification *)notification
{
    if (self.searchField.text.length == 0)
    {
        self.userSearchResultsVC.searchResults = nil;
        [self.userSearchResultsVC.tableView reloadData];
        
        self.tagsSearchResultsVC.searchResults = nil;
        [self.tagsSearchResultsVC.tableView reloadData];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.userSearchResultsVC.searchResults = nil;
    [self.userSearchResultsVC.tableView reloadData];
    self.userSearchResultsVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    self.tagsSearchResultsVC.searchResults = nil;
    [self.tagsSearchResultsVC.tableView reloadData];
    self.tagsSearchResultsVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self segmentControlAction:nil];
    [self.searchField resignFirstResponder];
    
    return YES;
}

#pragma mark - VSearchResultsTableViewControllerDelegate

- (void)showNoResultsReturnedForSearch
{
    NSString *messageTitle, *messageText;
    UIImage *messageIcon;
    
    VNoContentView *noResultsFoundView = [VNoContentView noContentViewWithFrame:self.searchResultsContainerView.frame];
    noResultsFoundView.dependencyManager = self.dependencyManager;
    if ( self.segmentControl.selectedSegmentIndex == 0 )
    {
        messageTitle = NSLocalizedString(@"No People Found In Search Title", @"");
        messageText = NSLocalizedString(@"No people found in search", @"");
        messageIcon = [[UIImage imageNamed:@"user-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.tagsSearchResultsVC.tableView.backgroundView = noResultsFoundView;
        self.userSearchResultsVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else if ( self.segmentControl.selectedSegmentIndex == 1 )
    {
        messageTitle = NSLocalizedString(@"No Hashtags Found In Search Title", @"");
        messageText = NSLocalizedString(@"No hashtags found in search", @"");
        messageIcon = [[UIImage imageNamed:@"tabIconHashtag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.tagsSearchResultsVC.tableView.backgroundView = noResultsFoundView;
        self.tagsSearchResultsVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

    noResultsFoundView.titleLabel.text = messageTitle;
    noResultsFoundView.messageLabel.text = messageText;
    noResultsFoundView.iconImageView.image = messageIcon;
    noResultsFoundView.iconImageView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    [noResultsFoundView addGestureRecognizer:self.tapGestureRecognizer];

}

@end
