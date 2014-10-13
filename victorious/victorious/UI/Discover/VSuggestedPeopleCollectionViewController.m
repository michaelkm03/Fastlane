//
//  VSuggestedPeopleCollectionViewController.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSuggestedPeopleCollectionViewController.h"
#import "VSuggestedPersonCollectionViewCell.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Discover.h"
#import "VUser+RestKit.h"
#import "VDiscoverConstants.h"

static NSString * const kSuggestedPersonCellIdentifier          = @"VSuggestedPersonCollectionViewCell";
static NSString * const VStoryboardViewControllerIndentifier    = @"suggestedPeople";

@interface VSuggestedPeopleCollectionViewController () <VSuggestedPersonCollectionViewCellDelegate>

@end

@implementation VSuggestedPeopleCollectionViewController

+ (VSuggestedPeopleCollectionViewController *)instantiateFromStoryboard:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateViewControllerWithIdentifier:VStoryboardViewControllerIndentifier];
}

#pragma mark - View controller life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.suggestedUsers = @[];
    
    [self.collectionView registerNib:[UINib nibWithNibName:kSuggestedPersonCellIdentifier bundle:nil] forCellWithReuseIdentifier:kSuggestedPersonCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followingDidUpdate:) name:VMainUserDidChangeFollowingUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusDidChange:) name:kLoggedInChangedNotification object:nil];
    
    [self refresh];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotification selectors

- (void)loginStatusDidChange:(NSNotification *)note
{
}

- (void)followingDidUpdate:(NSNotification *)note
{
    if ( note.userInfo == nil )
    {
        return;
    }
    
    VUser *updatedUser = note.userInfo[ VMainUserDidChangeFollowingUserKeyUser ];
    if ( updatedUser == nil )
    {
        return;
    }
    
    // Find the user that was updated and update our version of it to match
    [self.suggestedUsers enumerateObjectsUsingBlock:^(VUser *user, NSUInteger idx, BOOL *stop)
     {
         if ( [user isEqualToUser:updatedUser] )
         {
             user.isFollowing = updatedUser.isFollowing;
             *stop = YES;
         }
     }];
    
    [self.collectionView reloadData];
}

#pragma mark - Loading data

- (void)refresh
{
    [[VObjectManager sharedManager] getSuggestedUsers:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         [self didLoadWithUsers:resultObjects];
     }
                                            failBlock:^(NSOperation *operation, NSError *error)
     {
         [self didFailToLoadWithError:error];
     }];
}

- (void)didLoadWithUsers:(NSArray *)users
{
    if ( users.count == 0 )
    {
        self.hasLoadedOnce = YES;
        [self clearData];
    }
    else
    {
        self.suggestedUsers = users;
        [self.collectionView reloadData];
    }
    
    if ( self.delegate != nil )
    {
        [self.delegate didFinishLoading];
    }
}

- (void)didFailToLoadWithError:(NSError *)error
{
    self.hasLoadedOnce = YES;
    
    self.error = error;
    if ( self.delegate != nil )
    {
        [self.delegate didFailToLoad];
    }
    [self clearData];
}

- (void)clearData
{
    self.suggestedUsers = @[];
    [self.collectionView reloadData];
}

#pragma mark - VTableViewControllerProtocol

@synthesize hasLoadedOnce;

- (BOOL)isShowingNoData
{
    return self.suggestedUsers.count == 0 || self.error != nil;
}

#pragma mark - VSuggestedPersonCollectionViewCellDelegate

- (void)unfollowPerson:(VUser *)user
{
    if ([VObjectManager sharedManager].authorized)
    {
        [[VObjectManager sharedManager] unfollowUser:user successBlock:nil failBlock:nil];
    }
    else if ( self.delegate != nil )
    {
        [self.delegate didAttemptActionThatRequiresLogin];
    }
}

- (void)followPerson:(VUser *)user
{
    if ([VObjectManager sharedManager].authorized)
    {
        [[VObjectManager sharedManager] followUser:user successBlock:nil failBlock:nil];
    }
    else if ( self.delegate != nil )
    {
        [self.delegate didAttemptActionThatRequiresLogin];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.isShowingNoData ? 0 : self.suggestedUsers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VSuggestedPersonCollectionViewCell *cell = (VSuggestedPersonCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kSuggestedPersonCellIdentifier forIndexPath:indexPath];
    cell.user = self.suggestedUsers[ indexPath.row ];
    cell.delegate = self;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VSuggestedPersonCollectionViewCell *cell = (VSuggestedPersonCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    VUser *user = cell.user;
    NSDictionary *userInfo = @{ kVDiscoverUserProfileSelectedKeyUser : user };
    [[NSNotificationCenter defaultCenter] postNotificationName:kVDiscoverUserProfileSelectedNotification object:nil userInfo:userInfo];
}

@end
