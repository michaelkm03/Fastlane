//
//  VFindFriendsTableViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFindFriendsTableViewController.h"
#import "VFindFriendsViewController.h"
#import "VFindFriendsTableView.h"
#import "VInviteFriendTableViewCell.h"
#import "VNoContentView.h"
#import "NSArray+VMap.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VAuthorizationViewControllerFactory.h"
#import "VUser.h"
#import "VThemeManager.h"
#import "VConstants.h"

@interface VFindFriendsTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readwrite) VFindFriendsTableViewState  state;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSMutableArray *usersFollowing;
@property (nonatomic, strong) NSMutableArray *usersNotFollowing;

@end

@implementation VFindFriendsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _state = VFindFriendsTableViewStatePreConnect;
        _shouldAutoselectNewFriends = YES;
    }
    return self;
}

- (void)loadView
{
    self.view = [VFindFriendsTableView newFromNibWithOwner:self];
    [self.tableView.tableView registerNib:[UINib nibWithNibName:VInviteFriendTableViewCellNibName bundle:nil] forCellReuseIdentifier:VInviteFriendTableViewCellNibName];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.state == VFindFriendsTableViewStatePreConnect)
    {
        [self _connectToSocialNetworkWithPossibleUserInteraction:NO];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (VFindFriendsTableView *)tableView
{
    return (VFindFriendsTableView *)self.view;
}

- (void)setState:(VFindFriendsTableViewState)state
{
    switch (state)
    {
        case VFindFriendsTableViewStateConnected:
        {
            self.tableView.disconnectedView.hidden = YES;
            self.tableView.connectedView.hidden = NO;
            self.tableView.errorView.hidden = YES;
            if (_state != VFindFriendsTableViewStateLoading)
            {
                dispatch_async(dispatch_get_main_queue(), ^(void)
                {
                    [self _loadFriendsFromSocialNetwork];
                });
            }
            break;
        }
        case VFindFriendsTableViewStatePreConnect:
        {
            self.tableView.disconnectedView.hidden = NO;
            self.tableView.connectedView.hidden = YES;
            self.tableView.errorView.hidden = YES;
            break;
        }
        case VFindFriendsTableViewStateLoaded:
        {
            self.tableView.disconnectedView.hidden = YES;
            self.tableView.connectedView.hidden = NO;
            self.tableView.errorView.hidden = YES;
            
            if (self.usersFollowing.count || self.usersNotFollowing.count)
            {
                self.tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                [self.tableView.tableView reloadData];
                self.tableView.clearButton.hidden = NO;
                self.tableView.selectAllButton.hidden = NO;
                self.tableView.inviteFriendsButton.hidden = YES;
                if (self.shouldAutoselectNewFriends)
                {
                    [self selectAllRows:nil];
                }
            }
            else
            {
                [self showNoContentView:YES];
            }
            
            break;
        }
        case VFindFriendsTableViewStateError:
        {
            self.tableView.disconnectedView.hidden = YES;
            self.tableView.connectedView.hidden = YES;
            self.tableView.errorView.hidden = NO;
            break;
        }
        default:
            break;
    }
    _state = state;
    self.tableView.busyOverlay.hidden = state != VFindFriendsTableViewStateConnecting && state != VFindFriendsTableViewStateLoading;
}

- (void)connectToSocialNetworkWithPossibleUserInteraction:(BOOL)userInteraction completion:(void (^)(BOOL, NSError *))completionBlock
{
    NSAssert(NO, @"class %@ needs to implement connectToSocialNetworkWithPossibleUserInteraction:completion:", NSStringFromClass([self class]));
}

- (void)_connectToSocialNetworkWithPossibleUserInteraction:(BOOL)userInteraction
{
    self.state = VFindFriendsTableViewStateConnecting;
    [self connectToSocialNetworkWithPossibleUserInteraction:userInteraction completion:^(BOOL connected, NSError *error)
     {
         if (connected)
         {
             self.state = VFindFriendsTableViewStateConnected;
         }
         else
         {
             self.state = VFindFriendsTableViewStatePreConnect;
         }
     }];
}

- (void)loadFriendsFromSocialNetworkWithCompletion:(void (^)(NSArray *, NSError *))completionBlock
{
    NSAssert(NO, @"class %@ needs to implement loadFriendsFromSocialNetworkWithCompletion:", NSStringFromClass([self class]));
}

- (void)loadSingleFollower:(VUser *)user withSuccess:(VSuccessBlock)successBlock withFailure:(VFailBlock)failureBlock
{
    NSAssert(NO, @"class %@ needs to implement loadSingleFollower:withSuccess:withFailure:", NSStringFromClass([self class]));
}

- (void)unFollowSingleFollower:(VUser *)user withSuccess:(VSuccessBlock)successBlock withFailure:(VFailBlock)failureBlock
{
    NSAssert(NO, @"class %@ needs to implement unFollowSingleFollower:withSuccess:withFailure:", NSStringFromClass([self class]));
}


- (void)_loadFriendsFromSocialNetwork
{
    self.state = VFindFriendsTableViewStateLoading;
    [self loadFriendsFromSocialNetworkWithCompletion:^(NSArray *users, NSError *error)
    {
        if (error || !users)
        {
            self.state = VFindFriendsTableViewStateError;
        }
        else
        {
            self.users = users;
            self.state = VFindFriendsTableViewStateLoaded;
            [self segregateUsers:users];
        }
    }];
}

- (void)segregateUsers:(NSArray *)users
{
    self.usersFollowing = [[NSMutableArray alloc] init];
    self.usersNotFollowing = [[NSMutableArray alloc] init];
    VUser *me = [[VObjectManager sharedManager] mainUser];
    
    NSSet *following = me.following;
    
    for (VUser *user in users)
    {
        if ([following containsObject:user])
        {
            [self.usersFollowing addObject:user];
        }
        else
        {
            [self.usersNotFollowing addObject:user];
        }
    }
    
    self.tableView.selectAllButton.hidden = NO;
    self.tableView.inviteFriendsButton.hidden = YES;
    
    // Disable the Add All button if we don't have anyone to potentially add
    if (self.usersNotFollowing.count == 0)
    {
        self.tableView.selectAllButton.hidden = YES;
        self.tableView.inviteFriendsButton.hidden = NO;
        //[self.tableView.selectAllButton setEnabled:NO];
        [self.tableView.selectAllButton.layer setBorderColor:[[UIColor colorWithWhite:0.781 alpha:1.000] CGColor]];
        [self.tableView.selectAllButton.titleLabel setTextColor:[UIColor colorWithWhite:0.781 alpha:1.000]];
    }
    
    // Disable the No Content View if we have data
    if (self.usersNotFollowing.count > 0 || self.usersFollowing.count > 0)
    {
        [self showNoContentView:NO];
    }
    
    // Reload tableview
    [self.tableView.tableView reloadData];
}

- (void)showNoContentView:(BOOL)toShow
{
    if (toShow)
    {
        VNoContentView *noFollowersView = [VNoContentView noContentViewWithFrame:self.tableView.tableView.frame];
        self.tableView.tableView.backgroundView = noFollowersView;
        noFollowersView.titleLabel.text = [NSLocalizedString(@"NoFriends", @"") uppercaseString];
        noFollowersView.messageLabel.text = NSLocalizedString(@"NoFriendsDetail", @"");
        noFollowersView.iconImageView.image = [UIImage imageNamed:@"noFollowersIcon"];
        self.tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.clearButton.hidden = YES;
        self.tableView.selectAllButton.hidden = YES;
        self.tableView.inviteFriendsButton.hidden = NO;
    }
    else
    {
        self.tableView.tableView.backgroundView = nil;
        self.tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.tableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (NSArray *)selectedUsers
{
    NSArray *indexPaths = [self.tableView.tableView indexPathsForSelectedRows];
    return [indexPaths v_map:^id (id o)
    {
        return self.usersNotFollowing[[o row]];
    }];
}

#pragma mark - Button Actions

- (IBAction)connectButtonTapped:(id)sender
{
    [self _connectToSocialNetworkWithPossibleUserInteraction:YES];
}

- (IBAction)retryButtonTapped:(id)sender
{
    [self _loadFriendsFromSocialNetwork];
}

- (IBAction)clearButtonTapped:(id)sender
{
    NSArray *selectedIndexPaths = [self.tableView.tableView indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in selectedIndexPaths)
    {
        [self.tableView.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (IBAction)selectAllButtonTapped:(id)sender
{
    [self selectAllRows:sender];
}

- (IBAction)inviteButtonTapped:(id)sender
{
    [self.delegate inviteButtonWasTappedInFindFriendsTableViewController:self];
}

- (void)selectAllRows:(id)sender
{
    for (NSUInteger n = 0; n < self.usersNotFollowing.count; n++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:n inSection:0];
        VInviteFriendTableViewCell *cell = (VInviteFriendTableViewCell *)[self.tableView.tableView cellForRowAtIndexPath:indexPath];
        [cell disableFollowIcon:self];
    }
    
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        for (NSUInteger n = 0; n < self.usersNotFollowing.count; n++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:n inSection:0];
            VInviteFriendTableViewCell *cell = (VInviteFriendTableViewCell *)[self.tableView.tableView cellForRowAtIndexPath:indexPath];
            [cell enableFollowIcon:self];
            cell.haveRelationship = YES;
        }
    };
    
    [self loadBatchOfFollowers:self.usersNotFollowing withSuccess:successBlock withFailure:nil];
}

- (void)loadBatchOfFollowers:(NSArray *)followers withSuccess:(VSuccessBlock)successBlock withFailure:(VFailBlock)failureBlock
{
    [[VObjectManager sharedManager] followUsers:followers
                               withSuccessBlock:successBlock
                                      failBlock:failureBlock];
}


- (IBAction)makeButtonGray:(UIButton *)sender
{
    [UIView animateWithDuration:0.3
                     animations:^(void)
    {
        sender.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    }];
}

- (IBAction)makeButtonClear:(UIButton *)sender
{
    [UIView animateWithDuration:0.3
                     animations:^(void)
    {
        sender.backgroundColor = [UIColor clearColor];
    }];
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
        
        NSArray *indexPaths = [self.tableView.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in indexPaths)
        {
            VInviteFriendTableViewCell *cell = (VInviteFriendTableViewCell *)[self.tableView.tableView cellForRowAtIndexPath:indexPath];
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
        
        NSArray *indexPaths = [self.tableView.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in indexPaths)
        {
            VInviteFriendTableViewCell *cell = (VInviteFriendTableViewCell *)[self.tableView.tableView cellForRowAtIndexPath:indexPath];
            if (cell.profile == user)
            {
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
            NSArray *indexPaths = [self.tableView.tableView indexPathsForVisibleRows];
            for (NSIndexPath *indexPath in indexPaths)
            {
                VInviteFriendTableViewCell *cell = (VInviteFriendTableViewCell *)[self.tableView.tableView cellForRowAtIndexPath:indexPath];
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

#pragma mark - UITableView Section Header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSInteger sectionHeight = 40.f;
    if ((section == 0 && self.usersNotFollowing.count == 0) || (section == 1 && self.usersFollowing.count == 0))
    {
        sectionHeight = 0.f;
    }
    return sectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    [view setBackgroundColor:[UIColor colorWithRed:0.874 green:0.887 blue:0.912 alpha:1.000]];
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, tableView.frame.size.width, 20)];
    NSString *text;
    
    if (section == 1)
    {
        text = NSLocalizedString(@"FollowingSectionHeader", @"");
    }
    else if (section == 0)
    {
        switch (self.findFriendsTableType)
        {
            case VFindFriendsTableTypeFacebook:
                text = NSLocalizedString(@"FacebookFollowingSectionHeader", @"");
                break;
                
            case VFindFriendsTableTypeAddressBook:
                text = NSLocalizedString(@"AddressBookFollowingSectionHeader", @"");
                break;
                
            case VFindFriendsTableTypeTwitter:
                text = NSLocalizedString(@"TwitterFollowingSectionHeader", @"");
                break;
                
            default:
                break;
        }
    }
    
    NSMutableAttributedString *newAttributedText = [[NSMutableAttributedString alloc] initWithString:([text uppercaseString] ?: @"") attributes:[self attributesForText]];
    [headerTitle setAttributedText:newAttributedText];
    [view addSubview:headerTitle];
    
    return view;
}

- (NSDictionary *)attributesForText
{
    return @{
             NSFontAttributeName: [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font],
             NSForegroundColorAttributeName: [UIColor colorWithWhite:0.499 alpha:1.000],
             };
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return nil;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger tableSections = 2;
    
    if (self.usersFollowing.count == 0 && self.usersNotFollowing.count == 0)
    {
        tableSections = 1;
    }
    
    return tableSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger sectionRows = 0;
    
    if (section == 0)
    {
        sectionRows = self.usersNotFollowing.count;
    }
    else if (section == 1)
    {
        sectionRows = self.usersFollowing.count;
    }
    return sectionRows;
}

- (BOOL)determineRelationshipWithUser:(VUser *)targetUser atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    VUser *profile;
    BOOL haveRelationship = NO;
    
    if (section == 0)
    {
        profile = self.usersNotFollowing[indexPath.row];
        haveRelationship = ([mainUser.following containsObject:profile]);
    }
    else if (section == 1)
    {
        profile = self.usersFollowing[indexPath.row];
        haveRelationship = ([mainUser.following containsObject:profile]);
    }
    
    return haveRelationship;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    VUser *profile;
    BOOL haveRelationship = NO;

    VInviteFriendTableViewCell *cell = (VInviteFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:VInviteFriendTableViewCellNibName forIndexPath:indexPath];
    if (section == 0)
    {
        profile = self.usersNotFollowing[indexPath.row];
    }
    else if (section == 1)
    {
        profile = self.usersFollowing[indexPath.row];
    }
    
    haveRelationship = [self determineRelationshipWithUser:profile atIndexPath:indexPath];
    
    cell.profile = profile;
    cell.haveRelationship = haveRelationship;
    
    // Tell the button what to do when it's tapped
    cell.followAction = ^(void)
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

@end
