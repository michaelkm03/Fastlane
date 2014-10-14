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
#import "VAuthorizationViewControllerFactory.h"
#import "VUser.h"
#import "VThemeManager.h"
#import "VNoContentView.h"
#import "VUserProfileViewController.h"
#import "VConstants.h"

@interface VFollowerTableViewController ()

@property (nonatomic, strong)   NSArray    *followers;
@property (nonatomic) BOOL isMe;

@end

@implementation VFollowerTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraButtonBack"]
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(goBack:)];

    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
//    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryBackgroundColor];

    [self.tableView registerNib:[UINib nibWithNibName:@"followerCell" bundle:nil] forCellReuseIdentifier:@"followerCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

#pragma mark - Friend Actions

- (void)followFriendAction:(VUser *)user
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Add user relationship to local persistent store
        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        NSManagedObjectContext *moc = mainUser.managedObjectContext;
        
        [mainUser addFollowingObject:user];
        [moc saveToPersistentStore:nil];
        
        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in indexPaths)
        {
            VFollowerTableViewCell *cell = (VFollowerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            if (cell.profile == user)
            {
                [cell flipFollowIconAction:nil];
                return;
            }
        }
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        if (error.code == kVFollowsRelationshipAlreadyExistsError)
        {
            // Add user relationship to local persistent store
            VUser *mainUser = [[VObjectManager sharedManager] mainUser];
            NSManagedObjectContext *moc = mainUser.managedObjectContext;
            
            [mainUser addFollowingObject:user];
            [moc saveToPersistentStore:nil];
            
            NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
            for (NSIndexPath *indexPath in indexPaths)
            {
                VFollowerTableViewCell *cell = (VFollowerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                if (cell.profile == user)
                {
                    [cell flipFollowIconAction:nil];
                    return;
                }
            }
            return;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FollowError", @"")
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                              otherButtonTitles:nil];
        [alert show];
    };
    
    // Add user at backend
    [[VObjectManager sharedManager] followUser:user successBlock:successBlock failBlock:failureBlock];
}

- (void)unfollowFriendAction:(VUser *)user
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        NSManagedObjectContext *moc = mainUser.managedObjectContext;
        
        [mainUser removeFollowingObject:user];
        [moc saveToPersistentStore:nil];
        
        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in indexPaths)
        {
            VFollowerTableViewCell *cell = (VFollowerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            if (cell.profile == user)
            {
                void (^animations)() = ^(void)
                {
                    cell.haveRelationship = NO;
                };
                [UIView transitionWithView:cell.followButton
                                  duration:0.3
                                   options:UIViewAnimationOptionTransitionFlipFromTop
                                animations:animations
                                completion:nil];

                [cell flipFollowIconAction:nil];
                return;
            }
        }

    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        NSInteger errorCode = error.code;
        if (errorCode == kVFollowsRelationshipDoesNotExistError)
        {
            VUser *mainUser = [[VObjectManager sharedManager] mainUser];
            NSManagedObjectContext *moc = mainUser.managedObjectContext;
            
            [mainUser removeFollowingObject:user];
            [moc saveToPersistentStore:nil];
            NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
            for (NSIndexPath *indexPath in indexPaths)
            {
                VFollowerTableViewCell *cell = (VFollowerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                if (cell.profile == user)
                {
                    [cell flipFollowIconAction:nil];
                    return;
                }
            }
        }
        
        UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnfollowError", @"")
                                                               message:error.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
    };
    
    [[VObjectManager sharedManager] unfollowUser:user successBlock:successBlock failBlock:failureBlock];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.followers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser *profile = self.followers[indexPath.row];
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    BOOL haveRelationship = [mainUser.following containsObject:profile];
    
    VFollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"followerCell" forIndexPath:indexPath];
    cell.profile = self.followers[indexPath.row];
    cell.showButton = YES;
    cell.owner = self.profile;
    cell.haveRelationship = haveRelationship;
    
    // Tell the button what to do when it's tapped
    cell.followButtonAction = ^(void)
    {
        // Check if logged in before attempting to follow / unfollow
        if (![VObjectManager sharedManager].authorized)
        {
            [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
            return;
        }
        
        if ([mainUser.following containsObject:profile])
        {
            [self unfollowFriendAction:profile];
        }
        else
        {
            [self followFriendAction:profile];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser  *user = self.followers[indexPath.row];
    VUserProfileViewController *profileVC   =   [VUserProfileViewController userProfileWithFollowerOrFollowing:user];
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height * .75)
    {
        [self loadMoreFollowers];
    }
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

    [[VObjectManager sharedManager] refreshFollowersForUser:self.profile
                                               successBlock:followerSuccess
                                                  failBlock:followerFail];
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
    
    [[VObjectManager sharedManager] loadNextPageOfFollowersForUser:self.profile
                                                      successBlock:followerSuccess
                                                         failBlock:nil];
}

- (void)setHasFollowers:(BOOL)hasFollowers
{
    if (!hasFollowers)
    {
        NSString *msg, *title;
        
        self.isMe = (self.profile.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue);
        
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

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
