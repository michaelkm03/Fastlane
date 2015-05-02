//
//  VFollowerTableViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowerTableViewController.h"
#import "VFollowerTableViewCell.h"
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VAuthorizedAction.h"
#import "VUser.h"
#import "VThemeManager.h"
#import "VNoContentView.h"
#import "VUserProfileViewController.h"
#import "VConstants.h"
#import "MBProgressHUD.h"
#import "VFollowerEventResponder.h"
#import "VDependencyManager+VUserProfile.h"

@interface VFollowerTableViewController ()

@property (nonatomic, strong)   NSArray    *followers;
@property (nonatomic) BOOL isMe;
@property (nonatomic, strong) VFollowerEventResponder *followCommandHandler;

@end

@implementation VFollowerTableViewController

#pragma mark - UIResponder

- (UIResponder *)nextResponder
{
    self.followCommandHandler = [[VFollowerEventResponder alloc] initWithNextResponder:[super nextResponder]];
    self.followCommandHandler.viewControllerToPresentAuthorizationOn = self;
    self.followCommandHandler.dependencyManager = self.dependencyManager;
    
    return self.followCommandHandler;
}

#pragma mark - View lifecycle

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
    
    [self refreshFollowersList];
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
    
    [[VTrackingManager sharedInstance] setValue:VTrackingValueProfileFollowers forSessionParameterWithKey:VTrackingKeyContext];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyContext];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.followers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VFollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[VFollowerTableViewCell suggestedReuseIdentifier]
                                                                   forIndexPath:indexPath];
    cell.profile = self.followers[indexPath.row];
    cell.dependencyManager = self.dependencyManager;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser *user = self.followers[indexPath.row];
    VUserProfileViewController *profileVC = [self.dependencyManager userProfileViewControllerWithUser:user];
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VFollowerTableViewCell desiredSizeWithCollectionViewBounds:tableView.bounds].height;
}

- (IBAction)refresh:(id)sender
{
    int64_t         delayInSeconds = 1.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        [self refreshFollowersList];
        [self.refreshControl endRefreshing];
    });
}

- (void)refreshFollowersList
{
    VSuccessBlock followerSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSSortDescriptor   *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.followers = [resultObjects sortedArrayUsingDescriptors:@[sort]];
        [self setHasFollowers:self.followers.count];
        
        [self.tableView reloadData];
    };
    
    VFailBlock followerFail = ^(NSOperation *operation, NSError *error)
    {
        if (error.code)
        {
            self.followers = [[NSArray alloc] init];
            [self.tableView reloadData];
            [self setHasFollowers:NO];
        }
    };

    if (self.profile != nil)
    {
        [[VObjectManager sharedManager] loadFollowersForUser:self.profile
                                                    pageType:VPageTypeFirst
                                                successBlock:followerSuccess
                                                   failBlock:followerFail];
    }
}

- (void)loadMoreFollowers
{
    VSuccessBlock followerSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSSortDescriptor   *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        NSSet *uniqueFollowers = [NSSet setWithArray:[self.followers arrayByAddingObjectsFromArray:resultObjects]];
        self.followers = [[uniqueFollowers allObjects] sortedArrayUsingDescriptors:@[sort]];
        [self setHasFollowers:self.followers.count];
        
        [self.tableView reloadData];
    };
    
    if (self.profile != nil)
    {
        [[VObjectManager sharedManager] loadFollowersForUser:self.profile
                                                    pageType:VPageTypeNext
                                                successBlock:followerSuccess
                                                   failBlock:nil];
    }
}

- (void)setHasFollowers:(BOOL)hasFollowers
{
    if (!hasFollowers)
    {
        NSString *msg, *title;
        
        self.isMe = ([VObjectManager sharedManager].mainUser != nil && self.profile.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue);
        
        if (self.isMe)
        {
            title = NSLocalizedString(@"NoFollowersTitle", @"");
            msg = NSLocalizedString(@"NoFollowersMessage", @"");
        }
        else
        {
            title = NSLocalizedString(@"ProfileNoFollowersTitle", @"");
            msg = NSLocalizedString(@"ProfileNoFollowersMessage", @"");
        }
        
        VNoContentView *noFollowersView = [VNoContentView noContentViewWithFrame:self.tableView.frame];
        noFollowersView.dependencyManager = self.dependencyManager;
        self.tableView.backgroundView = noFollowersView;
        noFollowersView.titleLabel.text = title;
        noFollowersView.messageLabel.text = msg;
        noFollowersView.iconImageView.image = [UIImage imageNamed:@"noFollowersIcon"];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    }
}

@end
