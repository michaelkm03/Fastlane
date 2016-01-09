//
//  VUserSearchViewController.m
//  victorious
//
//  Created by Lawrence Leach on 8/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserSearchViewController.h"

#import "VNoContentView.h"
#import "VUserProfileViewController.h"

//Cells
#import "VInviteFriendTableViewCell.h"

#import "VUser.h"
#import "VConstants.h"

//ObjectManager
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Users.h"

//Data Models
#import "VSequence+RestKit.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

#import "VMessageContainerViewController.h"
#import "VMessageViewController.h"

#import "MBProgressHUD.h"

#import "VNavigationController.h"
#import "VObjectManager+Login.h"
#import "UIStoryboard+VMainStoryboard.h"

#import "VTrackingManager.h"
#import "VDependencyManager.h"

#import "VFollowControl.h"

@interface VUserSearchViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIView *noResultsView;
@property (nonatomic, weak) IBOutlet UIImageView *noResultsIcon;
@property (nonatomic, weak) IBOutlet UILabel *noResultsTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *noResultsMessageLabel;

@property (nonatomic, weak) IBOutlet UITextField *searchField;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *hrHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *vrWidthConstraint;
@property (nonatomic, weak) IBOutlet UIImageView *searchIconImageView;

@property (nonatomic, strong) NSString *validSearchText;
@property (nonatomic, strong) NSArray *foundUsers;
@property (nonatomic, weak) NSTimer *typeDelay;
@property (nonatomic, assign) NSInteger charCount;
@property (nonatomic, strong) VUser *selectedUser;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (IBAction)closeButtonAction:(id)sender;
- (void)runUserSearch:(id)sender;

@end

static const NSInteger kSearchResultLimit = 100;

@implementation VUserSearchViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VUserSearchViewController *userSearchViewController = (VUserSearchViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:NSStringFromClass([VUserSearchViewController class])];
    userSearchViewController.dependencyManager = dependencyManager;
    
    return userSearchViewController;
}

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _searchContext = VObjectManagerSearchContextDiscover;
}

- (void)dealloc
{
    _searchField.delegate = nil;
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // SETUP SEARCH FIELD
    self.searchField.delegate = self;
    [self.searchField setTextColor:[self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]];
    [self.searchField setTintColor:[UIColor grayColor]];
    [self.searchField sizeToFit];
    [self.searchField layoutIfNeeded];
    
    // NO RESULTS VIEW
    self.noResultsView.hidden = YES;
    self.noResultsTitleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
    self.noResultsMessageLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading4FontKey];

    // TABLEVIEW
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self.tableView registerNib:[VInviteFriendTableViewCell nibForCell]
         forCellReuseIdentifier:[VInviteFriendTableViewCell suggestedReuseIdentifier]];
    self.tableView.hidden = YES;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    // SET CHAR COUNTER
    self.charCount = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // SET THE SEARCH FIELD ACTIVE
    [self.searchField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventSearchDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:VTrackingEventSearchDidAppear];
    [self.searchField resignFirstResponder];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)v_prefersNavigationBarHidden
{
    return YES;
}

- (void)characterCheck:(id)sender
{
    self.charCount++;
    
    if (self.charCount == 3)
    {
        self.charCount = 0;
        [self runUserSearch:nil];
    }
}

- (IBAction)closeButtonAction:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)composeMessageToUser:(VUser *)profile
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectUserFromSearchRecipient];
    [self.messageSearchDelegate didSelectUser:profile inUserSearchViewController:self];
}

- (void)runUserSearch:(id)sender
{
    self.foundUsers = [[NSArray alloc] init];
    [self.tableView reloadData];
    
    self.validSearchText = self.searchField.text;
    NSString *validSearchSentinel = [self.validSearchText copy];
    __weak typeof(self) welf = self;
    VSuccessBlock searchSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSSortDescriptor   *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        NSArray *sortedUsers =  [resultObjects sortedArrayUsingDescriptors:@[sort]];

        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self.activityIndicatorView stopAnimating];
            
            self.foundUsers = sortedUsers;
            [self setHaveSearchResults:self.foundUsers.count];
            if ([validSearchSentinel isEqualToString:welf.validSearchText])
            {
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            }
        });
    };
    
    VFailBlock searchFail = ^(NSOperation *operation, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self.activityIndicatorView stopAnimating];
            
            [self setHaveSearchResults:NO];
            self.tableView.hidden = YES;
        });
    };

    if ([self.searchField.text length] > 0)
    {
        [self.activityIndicatorView startAnimating];
        [[VObjectManager sharedManager] findUsersBySearchString:self.searchField.text
                                                     sequenceID:nil 
                                                          limit:kSearchResultLimit
                                                        context:self.searchContext
                                               withSuccessBlock:searchSuccess
                                                      failBlock:searchFail];
    }
    else
    {
        self.tableView.hidden = YES;
    }
}

- (void)setHaveSearchResults:(BOOL)haveSearchResults
{
    if (!haveSearchResults)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if ([self.searchField.text length] > 0)
        {
            self.noResultsView.hidden = NO;
        }
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        self.noResultsView.hidden = YES;
    }
}

#pragma mark - TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.foundUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser *profile = self.foundUsers[indexPath.row];
    
    VInviteFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[VInviteFriendTableViewCell suggestedReuseIdentifier]
                                                                       forIndexPath:indexPath];
    cell.profile = profile;
    cell.dependencyManager = self.dependencyManager;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser *profile = self.foundUsers[indexPath.row];
    [self composeMessageToUser:profile];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VInviteFriendTableViewCell desiredSizeWithCollectionViewBounds:tableView.bounds].height;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self runUserSearch:nil];
    [self.searchField resignFirstResponder];
    return YES;
}

@end
