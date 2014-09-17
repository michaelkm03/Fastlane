//
//  VFindFriendsTableViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFindFriendsTableViewController.h"
#import "VFindFriendsTableView.h"
#import "VInviteFriendTableViewCell.h"
#import "VNoContentView.h"
#import "NSArray+VMap.h"
#import "VObjectManager+Users.h"

@interface VFindFriendsTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readwrite) VFindFriendsTableViewState  state;
@property (nonatomic, strong)    NSArray                    *users;

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
    [self.tableView.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([VInviteFriendTableViewCell class]) bundle:nil] forCellReuseIdentifier:kFollowCellReuseID];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.state == VFindFriendsTableViewStatePreConnect)
    {
        [self _connectToSocialNetworkWithPossibleUserInteraction:NO];
    }
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
            
            if (self.users.count)
            {
                self.tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                [self.tableView.tableView reloadData];
                self.tableView.clearButton.hidden = NO;
                self.tableView.selectAllButton.hidden = NO;
                if (self.shouldAutoselectNewFriends)
                {
                    [self selectAllRows];
                }
            }
            else
            {
                VNoContentView *noFollowersView = [VNoContentView noContentViewWithFrame:self.tableView.tableView.frame];
                self.tableView.tableView.backgroundView = noFollowersView;
                noFollowersView.titleLabel.text = NSLocalizedString(@"NoFriends", @"");
                noFollowersView.messageLabel.text = NSLocalizedString(@"NoFriendsDetail", @"");
                noFollowersView.iconImageView.image = [UIImage imageNamed:@"noFollowersIcon"];
                self.tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                self.tableView.clearButton.hidden = YES;
                self.tableView.selectAllButton.hidden = YES;
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
        }
    }];
}

- (NSArray *)selectedUsers
{
    NSArray *indexPaths = [self.tableView.tableView indexPathsForSelectedRows];
    return [indexPaths v_map:^id (id o)
    {
        return self.users[[o row]];
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
    [self selectAllRows];
}

- (void)selectAllRows
{
    for (NSUInteger n = 0; n < self.users.count; n++)
    {
        [self.tableView.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:n inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    VSuccessBlock successBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSLog(@"\n\n-----\nSuccess Block:\n%@\n-----\n\n", resultObjects);
    };
    
    [self loadBatchOfFollowers:self.selectedUsers withSuccess:successBlock withFailure:nil];
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

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return nil;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VInviteFriendTableViewCell *cell = (VInviteFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kFollowCellReuseID];
    cell.profile = self.users[indexPath.row];
    return cell;
}

@end
