//
//  VUsersAndTagsSearchViewController.m
//  victorious
//
//  Created by Lawrence Leach on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUsersAndTagsSearchViewController.h"

#import "VDiscoverContainerViewController.h"

// VObjectManager
#import "VObjectManager.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Discover.h"
#import "VHashtag+RestKit.h"

// Dependency Manager
#import "VDependencyManager.h"

// Search Results
#import "VSearchResultsTableViewController.h"
#import "VUserSearchResultsViewController.h"
#import "VTagsSearchResultsViewController.h"

// No Content View
#import "VNoContentView.h"

// Transtion
#import "VSimpleModalTransition.h"

#import "UIVIew+AutoLayout.h"

@interface VUsersAndTagsSearchViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *searchField;
@property (nonatomic, weak) IBOutlet UIView *searchBarView;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentControl;

@property (nonatomic, strong) VUserSearchResultsViewController *userSearchResultsVC;
@property (nonatomic, strong) VTagsSearchResultsViewController *tagsSearchResultsVC;

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, assign) BOOL isKeyboardShowing;
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizer;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VUsersAndTagsSearchViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Remove header
    [self.navigationController setNavigationBarHidden:YES];
    
    // Setup Search Results View Controllers
    self.userSearchResultsVC = [VUserSearchResultsViewController newWithDependencyManager:self.dependencyManager];
    self.tagsSearchResultsVC = [VTagsSearchResultsViewController newWithDependencyManager:self.dependencyManager];
    
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
    
    // Add NSNotification Observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(segmentControlAction:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchFieldTextChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    // Setup Search Field
    self.searchField.placeholder = NSLocalizedString(@"SearchPeopleAndHashtags", @"");
    [self.searchField setTextColor:[self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]];
    [self.searchField setTintColor:[self.dependencyManager colorForKey:VDependencyManagerLinkColorKey]];
    self.searchField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.searchField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove NSNotification Observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (BOOL)prefersStatusBarHidden
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
        NSArray *tags = [[fullResponse valueForKey:@"payload"] valueForKey:@"objects"];
        
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
    };
    
    VFailBlock searchFail = ^(NSOperation *operation, NSError *error)
    {
        VLog(@"\n\nHashtag Search Failed with the following error:\n%@", error);
    };

    if ([self.searchField.text length] > 0)
    {
        [[VObjectManager sharedManager] findHashtagsBySearchString:self.searchField.text
                                                      limitPerPage:1000
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
        [self.userSearchResultsVC setSearchResults:(NSMutableArray *)results];
    };
    
    if ( [self.searchField.text length] > 0 )
    {
        [[VObjectManager sharedManager] findMessagableUsersBySearchString:self.searchField.text
                                                         withSuccessBlock:searchSuccess
                                                                failBlock:nil];
    }
    else
    {
        NSArray *results = [[NSArray alloc] init];
        self.userSearchResultsVC.searchResults = (NSMutableArray *)results;
    }
}

#pragma mark - Search Field Text Changed

- (void)searchFieldTextChanged:(NSNotification *)notification
{
    if ( self.searchField.text.length == 0 )
    {
        self.userSearchResultsVC.view.alpha = 0;
        self.tagsSearchResultsVC.view.alpha = 0;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ( [string isEqualToString:@""] && textField.text.length == 0 )
    {
        self.userSearchResultsVC.view.alpha = 0;
        self.tagsSearchResultsVC.view.alpha = 0;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.userSearchResultsVC.searchResults = nil;
    [self.userSearchResultsVC.tableView reloadData];
    self.userSearchResultsVC.tableView.backgroundView = nil;
        
    self.tagsSearchResultsVC.searchResults = nil;
    [self.tagsSearchResultsVC.tableView reloadData];
    self.tagsSearchResultsVC.tableView.backgroundView = nil;
    
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
    if ( self.segmentControl.selectedSegmentIndex == 0 )
    {
        messageTitle = NSLocalizedString(@"NoPeopleFoundInSearchTitle", @"");
        messageText = NSLocalizedString(@"NoPeopleFoundInSearch", @"");
        messageIcon = [[UIImage imageNamed:@"user-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.userSearchResultsVC.tableView.backgroundView = noResultsFoundView;
        self.userSearchResultsVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else if ( self.segmentControl.selectedSegmentIndex == 1 )
    {
        messageTitle = NSLocalizedString(@"NoHashtagsFoundInSearchTitle", @"");
        messageText = NSLocalizedString(@"NoHashtagsFoundInSearch", @"");
        messageIcon = [[UIImage imageNamed:@"tabIconHashtag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.tagsSearchResultsVC.tableView.backgroundView = noResultsFoundView;
        self.tagsSearchResultsVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

    noResultsFoundView.titleLabel.text = messageTitle;
    noResultsFoundView.messageLabel.text = messageText;
    noResultsFoundView.iconImageView.image = messageIcon;
    noResultsFoundView.iconImageView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryLinkColorKey];
}

@end
