//
//  VUsersAndTagsSearchViewController.m
//  victorious
//
//  Created by Lawrence Leach on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUsersAndTagsSearchViewController.h"

// VObjectManager
#import "VObjectManager.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Discover.h"
#import "VHashtag+RestKit.h"

// Search Results
#import "VUserSearchResultsViewController.h"
#import "VTagsSearchResultsViewController.h"

// VThemeManager
#import "VThemeManager.h"

@interface VUsersAndTagsSearchViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *searchField;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIView *searchBarView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchBarViewHeightConstraint;

@property (nonatomic, strong) VUserSearchResultsViewController *userSearchResultsVC;
@property (nonatomic, strong) VTagsSearchResultsViewController *tagsSearchResultsVC;

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, weak) NSTimer *typeDelay;
@property (nonatomic, assign) NSInteger charCount;

@end

@implementation VUsersAndTagsSearchViewController

+ (instancetype)usersAndTagsSearchViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Discover" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"search"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Remove header
    [self.navigationController setNavigationBarHidden:YES];
    
    // Setup Search Field
    self.searchField.placeholder = NSLocalizedString(@"SearchPeopleAndHashtags", @"");
    [self.searchField setTextColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor]];
    [self.searchField setTintColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]];
    self.searchField.delegate = self;
    [self.searchField becomeFirstResponder];
    
    // Add UITextField Observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(segmentControlAction:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchFieldTextChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.searchField
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.searchField
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    
    // Setup Search Results View Controllers
    self.userSearchResultsVC = [[VUserSearchResultsViewController alloc] initWithNibName:nil bundle:nil];
    self.tagsSearchResultsVC = [[VTagsSearchResultsViewController alloc] initWithNibName:nil bundle:nil];
    
    // Add view controllers to container vie
    [self.containerView addSubview:self.tagsSearchResultsVC.view];
    [self.containerView addSubview:self.userSearchResultsVC.view];
    
    // Constraints
    self.searchBarViewHeightConstraint.constant = 55.0f;
    self.headerViewHeightConstraint.constant = 64.0f;
    
    // Set the header view Background color
    //self.headerView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];

    // Format the segmented control
    self.segmentControl.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.segmentControl.selectedSegmentIndex = 0;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Button Actions

- (IBAction)closeButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISegmentControl Action

- (IBAction)segmentControlAction:(id)sender
{
    // Perform search
    if ( self.segmentControl.selectedSegmentIndex == 0 )
    {
        self.userSearchResultsVC.view.alpha = 1.0f;
        self.tagsSearchResultsVC.view.alpha = 0;
        [self userSearch:sender];
    }
    else if ( self.segmentControl.selectedSegmentIndex == 1 )
    {
        self.userSearchResultsVC.view.alpha = 0;
        self.tagsSearchResultsVC.view.alpha = 1.0f;
        [self hashtagSearch:sender];
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
        
        [self.tagsSearchResultsVC setSearchResults:searchResults];
    };
    
    VFailBlock searchFail = ^(NSOperation *operation, NSError *error)
    {
        VLog(@"\n\nHashtag Search Failed with the following error:\n%@", error);
    };

    
    if ([self.searchField.text length] > 0)
    {
        [[VObjectManager sharedManager] findHashtagsBySearchString:self.searchField.text
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
    
    if ([self.searchField.text length] > 0)
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
    if (self.searchField.text.length == 0)
    {
        self.userSearchResultsVC.view.alpha = 0;
        self.tagsSearchResultsVC.view.alpha = 0;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""] && textField.text.length == 0)
    {
        self.userSearchResultsVC.view.alpha = 0;
        self.tagsSearchResultsVC.view.alpha = 0;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

#pragma mark - Keyboard Notification Handlers

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGFloat height = CGRectGetHeight( [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] );
    VLog(@"Search Keyboard is showing with a height of %f", height);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    VLog(@"Search Keyboard is hiding");
}

@end
