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
#import "MBProgressHUD.h"

NSString *const kVUserSearchResultsChangedNotification = @"VUserSearchResultsChangedNotification";
NSString *const kVHashtagsSearchResultsChangedNotification = @"VHashtagsSearchResultsChangedNotification";

static NSInteger const kVMaxSearchResults = 1000;

@interface VUsersAndTagsSearchViewController () <UITextFieldDelegate, VUserSearchResultsViewControllerDelegate, VTagsSearchResultsViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *searchField;
@property (nonatomic, weak) IBOutlet UIView *searchBarView;
@property (nonatomic, weak) IBOutlet UIView *headerView;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, assign) BOOL isKeyboardShowing;
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;


@property (nonatomic, strong) RKManagedObjectRequestOperation *userSearchRequest;
@property (nonatomic, strong) RKManagedObjectRequestOperation *tagSearchRequest;

@end

@implementation VUsersAndTagsSearchViewController

#pragma mark - Factory Methods

+ (instancetype)usersAndTagsSearchViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Discover" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"search"];
}

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.searchField becomeFirstResponder];
    
    [[VTrackingManager sharedInstance] setValue:VTrackingValueDiscoverSearch forSessionParameterWithKey:VTrackingKeyContext];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self cancelUserSearch:YES andHashtagSearch:YES];
    
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
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    // Perform search
    if ( self.segmentControl.selectedSegmentIndex == 0 )
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectDiscoverSearchUser];
        [self cancelUserSearch:NO andHashtagSearch:YES];
        
        self.userSearchResultsVC.view.alpha = 1.0f;
        self.tagsSearchResultsVC.view.alpha = 0;
        
        if (self.isKeyboardShowing)
        {
            [self.userSearchResultsVC.tableView setContentInset:UIEdgeInsetsMake(0, 0, bottomInsetHeight, 0)];
        }
    }
    else if ( self.segmentControl.selectedSegmentIndex == 1 )
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectDiscoverSearchHashtag];
        [self cancelUserSearch:YES andHashtagSearch:NO];
        
        self.userSearchResultsVC.view.alpha = 0;
        self.tagsSearchResultsVC.view.alpha = 1.0f;

        if (self.isKeyboardShowing)
        {
            [self.tagsSearchResultsVC.tableView setContentInset:UIEdgeInsetsMake(0, 0, bottomInsetHeight, 0)];
        }
    }
}

#pragma mark - Search Actions

- (void)hashtagSearch:(NSString *)tagName
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
            [self showNoResultsReturnedForSearch];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kVHashtagsSearchResultsChangedNotification object:nil];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    };
    
    VFailBlock searchFail = ^(NSOperation *operation, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    };

    NSString *searchTerm = [tagName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (searchTerm.length > 0)
    {
        [self cancelUserSearch:NO andHashtagSearch:YES];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.userInteractionEnabled = NO;
        dispatch_async(dispatch_get_global_queue( QOS_CLASS_USER_INITIATED, 0), ^
        {
            self.tagSearchRequest = [[VObjectManager sharedManager] findHashtagsBySearchString:searchTerm
                                                                                  limitPerPage:kVMaxSearchResults
                                                                                  successBlock:searchSuccess
                                                                                     failBlock:searchFail];
        });
    }
    else
    {
        NSArray *results = [[NSArray alloc] init];
        self.tagsSearchResultsVC.searchResults = (NSMutableArray *)results;
    }
}

- (void)userSearch:(NSString *)userName
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
            [self showNoResultsReturnedForSearch];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kVUserSearchResultsChangedNotification object:nil];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    };
    
    VFailBlock searchFail = ^(NSOperation *operation, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    };
    
    if ( [userName length] > 0 )
    {
        [self cancelUserSearch:YES andHashtagSearch:NO];

        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.userInteractionEnabled = NO;
        dispatch_async(dispatch_get_global_queue( QOS_CLASS_USER_INITIATED, 0), ^
        {
            self.userSearchRequest = [[VObjectManager sharedManager] findUsersBySearchString:userName
                                                                                  sequenceID:nil
                                                                                       limit:kVMaxSearchResults
                                                                                     context:VObjectManagerSearchContextDiscover
                                                                            withSuccessBlock:searchSuccess
                                                                                   failBlock:searchFail];
        });
    }
    else
    {
        NSArray *results = [[NSArray alloc] init];
        self.userSearchResultsVC.searchResults = (NSMutableArray *)results;
    }
}

- (void)cancelUserSearch:(BOOL)userFlag andHashtagSearch:(BOOL)tagFlag
{
    if (userFlag && self.userSearchRequest != nil)
    {
        if (self.userSearchRequest.isExecuting)
        {
            [self.userSearchRequest cancel];
        }

    }
    if (tagFlag && self.tagSearchRequest != nil)
    {
        if (self.tagSearchRequest.isExecuting)
        {
            [self.tagSearchRequest cancel];
        }
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

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.userSearchResultsVC.searchResults = nil;
    self.userSearchResultsVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    self.tagsSearchResultsVC.searchResults = nil;
    self.tagsSearchResultsVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchField resignFirstResponder];
    if (self.searchField.text.length > 0)
    {
        if ( self.segmentControl.selectedSegmentIndex == 0 )
        {
            [self userSearch:self.searchField.text];
        }
        else if (self.segmentControl.selectedSegmentIndex == 1)
        {
            [self hashtagSearch:self.searchField.text];
        }
    }
    
    return YES;
}

#pragma mark - VSearchResultsTableViewControllerDelegate

- (void)showNoResultsReturnedForSearch
{
    NSString *messageTitle, *messageText;
    UIImage *messageIcon;
    
    VNoContentView *noResultsFoundView = [VNoContentView noContentViewWithFrame:self.searchResultsContainerView.frame];
    if ( [noResultsFoundView respondsToSelector:@selector(setDependencyManager:)] )
    {
        noResultsFoundView.dependencyManager = self.dependencyManager;
    }
    if ( self.segmentControl.selectedSegmentIndex == 0 )
    {
        messageTitle = NSLocalizedString(@"No People Found In Search Title", @"");
        messageText = NSLocalizedString(@"No people found in search", @"");
        messageIcon = [[UIImage imageNamed:@"user-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.userSearchResultsVC.tableView.backgroundView = noResultsFoundView;
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

    noResultsFoundView.title = messageTitle;
    noResultsFoundView.message = messageText;
    noResultsFoundView.icon = messageIcon;
    [noResultsFoundView addGestureRecognizer:self.tapGestureRecognizer];

}

@end
