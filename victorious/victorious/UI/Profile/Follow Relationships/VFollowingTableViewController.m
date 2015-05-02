//
//  VFollowingTableViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowingTableViewController.h"
#import "VFollowerTableViewCell.h"
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VAuthorizedAction.h"
#import "VUser.h"
#import "VUserProfileViewController.h"
#import "VNoContentView.h"
#import "VConstants.h"
#import "VThemeManager.h"
#import "MBProgressHUD.h"
#import "VDependencyManager.h"
#import "VFollowerEventResponder.h"
#import "VDependencyManager+VUserProfile.h"

@interface VFollowingTableViewController ()

@property (nonatomic, strong)   NSArray    *following;
@property (nonatomic) BOOL isMe;
@property (nonatomic, strong) VFollowerEventResponder *followCommandHandler;

@end

@implementation VFollowingTableViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

#pragma mark - UIResponder

- (UIResponder *)nextResponder
{
    self.followCommandHandler = [[VFollowerEventResponder alloc] initWithNextResponder:[super nextResponder]];
    self.followCommandHandler.viewControllerToPresentAuthorizationOn = self;
    self.followCommandHandler.dependencyManager = self.dependencyManager;
    
    return self.followCommandHandler;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self.tableView registerNib:[VFollowerTableViewCell nibForCell]
         forCellReuseIdentifier:[VFollowerTableViewCell suggestedReuseIdentifier]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.profile)
    {
        [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse
                                                                    usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isKindOfClass:[VUserProfileViewController class]])
             {
                 VUserProfileViewController *userProfile = obj;
                 self.profile = userProfile.user;
                 *stop = YES;
             }
         }];
    }
    
    [self refreshFollowingList];
    
    // Set insets and layout margin
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];

    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[VTrackingManager sharedInstance] setValue:VTrackingValueProfileFollowing forSessionParameterWithKey:VTrackingKeyContext];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyContext];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.following count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VFollowerTableViewCell    *cell = [tableView dequeueReusableCellWithIdentifier:[VFollowerTableViewCell suggestedReuseIdentifier]
                                                                      forIndexPath:indexPath];
    cell.profile = self.following[indexPath.row];
    cell.dependencyManager = self.dependencyManager;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VFollowerTableViewCell desiredSizeWithCollectionViewBounds:tableView.bounds].height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser  *user = self.following[indexPath.row];
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (IBAction)refresh:(id)sender
{
    int64_t         delayInSeconds = 1.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        [self refreshFollowingList];
        [self.refreshControl endRefreshing];
    });
}

- (void)refreshFollowingList
{
    VSuccessBlock followerSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSSortDescriptor   *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.following = [resultObjects sortedArrayUsingDescriptors:@[sort]];
        [self setIsFollowing:self.following.count];
        
        [self.tableView reloadData];
    };
    
    VFailBlock followerFail = ^(NSOperation *operation, NSError *error)
    {
        if (error.code)
        {
            self.following = [[NSArray alloc] init];
            [self.tableView reloadData];
            [self setIsFollowing:NO];
        }
    };
    
    if (self.profile != nil)
    {
        [[VObjectManager sharedManager] loadFollowingsForUser:self.profile
                                                     pageType:VPageTypeFirst
                                                 successBlock:followerSuccess
                                                    failBlock:followerFail];
    }
    else
    {
        MBProgressHUD *failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        failureHUD.mode = MBProgressHUDModeText;
        failureHUD.detailsLabelText = NSLocalizedString(@"NotLoggedInMessage", @"");
        [failureHUD hide:YES afterDelay:3.0f];
    }
}

- (void)loadMoreFollowings
{
    VSuccessBlock followingSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSSortDescriptor   *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        NSSet *uniqueFollowings = [NSSet setWithArray:[self.following arrayByAddingObjectsFromArray:resultObjects]];
        self.following = [[uniqueFollowings allObjects] sortedArrayUsingDescriptors:@[sort]];
        [self setIsFollowing:self.following.count];
        
        [self.tableView reloadData];
    };
    
    if (self.profile != nil)
    {
        [[VObjectManager sharedManager] loadFollowingsForUser:self.profile
                                                     pageType:VPageTypeNext
                                                 successBlock:followingSuccess
                                                    failBlock:nil];
    }
    else
    {
        MBProgressHUD *failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        failureHUD.mode = MBProgressHUDModeText;
        failureHUD.detailsLabelText = NSLocalizedString(@"NotLoggedInMessage", @"");
        [failureHUD hide:YES afterDelay:3.0f];
    }
}

- (void)setIsFollowing:(BOOL)isFollowing
{
    if (!isFollowing)
    {
        NSString *msg, *title;
        
        self.isMe = [[VObjectManager sharedManager] mainUser] != nil && self.profile.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue;
        
        if (self.isMe)
        {
            title = NSLocalizedString(@"NotFollowingTitle", @"");
            msg = NSLocalizedString(@"NotFollowingMessage", @"");
        }
        else
        {
            title = NSLocalizedString(@"ProfileNotFollowingTitle", @"");
            msg = NSLocalizedString(@"ProfileNotFollowingMessage", @"");
        }
        
        VNoContentView *notFollowingView = [VNoContentView noContentViewWithFrame:self.tableView.bounds];
        notFollowingView.dependencyManager = self.dependencyManager;
        self.tableView.backgroundView = notFollowingView;
        notFollowingView.titleLabel.text = title;
        notFollowingView.messageLabel.text = msg;
        notFollowingView.iconImageView.image = [UIImage imageNamed:@"noFollowersIcon"];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    }
}

@end
