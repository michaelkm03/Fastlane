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
#import "VFollowerTableViewCell.h"

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

#import "VLoginViewController.h"
#import "VMessageContainerViewController.h"
#import "VMessageViewController.h"

#import "VThemeManager.h"

#import "MBProgressHUD.h"

#import "VAuthorizedAction.h"
#import "VNavigationController.h"
#import "VObjectManager+Login.h"
#import "UIStoryboard+VMainStoryboard.h"

#import "VTrackingManager.h"
#import "VDependencyManager.h"

#import "VFollowerCommandHandler.h"

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

@property (nonatomic, strong) NSArray *foundUsers;
@property (nonatomic, weak) NSTimer *typeDelay;
@property (nonatomic, assign) NSInteger charCount;
@property (nonatomic, strong) VUser *selectedUser;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) VFollowerCommandHandler *followCommandHandler;

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

#pragma mark - UIResponder

- (UIResponder *)nextResponder
{
    self.followCommandHandler = [[VFollowerCommandHandler alloc] initWithNextResponder:[super nextResponder]];
    self.followCommandHandler.viewControllerToPresentAuthorizationOn = self;
    self.followCommandHandler.dependencyManager = self.dependencyManager;
    
    return self.followCommandHandler;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // SETUP SEARCH FIELD
    self.searchField.delegate = self;
    [self.searchField addTarget:self action:@selector(runUserSearch:) forControlEvents:UIControlEventEditingChanged];
    [self.searchField setTextColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor]];
    [self.searchField setTintColor:[UIColor grayColor]];
    [self.searchField sizeToFit];
    [self.searchField layoutIfNeeded];
    
    // NO RESULTS VIEW
    self.noResultsView.hidden = YES;
    self.noResultsTitleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
    self.noResultsMessageLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];

    // TABLEVIEW
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self.tableView registerNib:[VFollowerTableViewCell nibForCell]
         forCellReuseIdentifier:[VFollowerTableViewCell suggestedReuseIdentifier]];
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

- (NSUInteger)supportedInterfaceOrientations
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

- (void)typingTimerCheck:(id)sender
{
    if (self.typeDelay)
    {
        if ([self.typeDelay isValid])
        {
            [self.typeDelay invalidate];
        }
        self.typeDelay = nil;
    }
    self.typeDelay = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(runUserSearch:) userInfo:nil repeats:NO];
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
    VSuccessBlock searchSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSSortDescriptor   *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.foundUsers = [resultObjects sortedArrayUsingDescriptors:@[sort]];
        [self setHaveSearchResults:self.foundUsers.count];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
        });
    };
    
    VFailBlock searchFail = ^(NSOperation *operation, NSError *error)
    {
        [self setHaveSearchResults:NO];
        self.tableView.hidden = YES;
        if (error.code)
        {
            self.foundUsers = [[NSArray alloc] init];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
        });
    };

    if ([self.searchField.text length] > 0)
    {
        [self.activityIndicatorView startAnimating];
        [[VObjectManager sharedManager] findUsersBySearchString:self.searchField.text
                                                          limit:kSearchResultLimit
                                                        context:self.searchContext
                                               withSuccessBlock:searchSuccess
                                                      failBlock:searchFail];
    }
    else
    {
        self.foundUsers = [[NSArray alloc] init];
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
    
    VFollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[VFollowerTableViewCell suggestedReuseIdentifier]
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
    return [VFollowerTableViewCell desiredSizeWithCollectionViewBounds:tableView.bounds].height;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self runUserSearch:nil];
    [self.searchField resignFirstResponder];
    return YES;
}

@end
