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
#import "VUser.h"
#import "VUserProfileViewController.h"
#import "VNoContentView.h"
#import "VConstants.h"

@interface VFollowingTableViewController ()

@property (nonatomic, strong)   NSArray    *following;
@property (nonatomic) BOOL isMe;

@end

@implementation VFollowingTableViewController

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
    
    [self refreshFollowingList];
}

#pragma mark - Friend Actions

- (void)loadSingleFollower:(VUser *)user withSuccess:(VSuccessBlock)successBlock withFailure:(VFailBlock)failureBlock
{
    // Return if we don't have a way to handle the return
    if (!successBlock)
    {
        return;
    }
    
    [[VObjectManager sharedManager] followUser:user
                                  successBlock:successBlock
                                     failBlock:failureBlock];
}

- (void)unFollowSingleFollower:(VUser *)user withSuccess:(VSuccessBlock)successBlock withFailure:(VFailBlock)failureBlock
{
    [[VObjectManager sharedManager] unfollowUser:user
                                    successBlock:successBlock
                                       failBlock:failureBlock];
}

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
    [self loadSingleFollower:user withSuccess:successBlock withFailure:failureBlock];
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
    
    [self unFollowSingleFollower:user withSuccess:successBlock withFailure:failureBlock];
    
}

#pragma mark - Check Relationship Status

- (BOOL)determineRelationshipWithUser:(VUser *)targetUser
{
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    BOOL relationship = ([mainUser.followers containsObject:targetUser] || [mainUser.following containsObject:targetUser]);
    //NSLog(@"\n\n%@ -> %@ - %@\n", mainUser.name, targetUser.name, (relationship ? @"YES":@"NO"));
    return relationship;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.following count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser *profile = self.following[indexPath.row];
    BOOL haveRelationship = [self determineRelationshipWithUser:profile];

    VFollowerTableViewCell    *cell = [tableView dequeueReusableCellWithIdentifier:@"followerCell" forIndexPath:indexPath];
    cell.profile = self.following[indexPath.row];
    cell.showButton = NO;
    cell.haveRelationship = haveRelationship;
    
    // Tell the button what to do when it's tapped
    cell.followButtonAction = ^(void)
    {
        if (haveRelationship)
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
    VUser  *user = self.following[indexPath.row];
    VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height * .75)
    {
        [self loadMoreFollowings];
    }
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
    
    [[VObjectManager sharedManager] refreshFollowingsForUser:self.profile
                                                successBlock:followerSuccess
                                                   failBlock:followerFail];
}

- (void)loadMoreFollowings
{
    VSuccessBlock followerSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSSortDescriptor   *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        NSSet *uniqueFollowings = [NSSet setWithArray:[self.following arrayByAddingObjectsFromArray:resultObjects]];
        self.following = [[uniqueFollowings allObjects] sortedArrayUsingDescriptors:@[sort]];
        [self setIsFollowing:self.following.count];
        
        [self.tableView reloadData];
    };
    
    [[VObjectManager sharedManager] loadNextPageOfFollowingsForUser:self.profile
                                                       successBlock:followerSuccess
                                                          failBlock:nil];
}

- (void)setIsFollowing:(BOOL)isFollowing
{
    if (!isFollowing)
    {
        NSString *msg, *title;
        
        self.isMe = (self.profile.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue);
        
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
        
        VNoContentView *notFollowingView = [VNoContentView noContentViewWithFrame:self.tableView.frame];
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

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
