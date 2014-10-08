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
#import "VObjectManager+Discover.h"
#import "VUser+RestKit.h"
#import "VDiscoverConstants.h"

static NSString * const kSuggestedPersonCellIdentifier = @"VSuggestedPersonCollectionViewCell";

@interface VSuggestedPeopleCollectionViewController () <VSuggestedPersonCollectionViewCellDelegate>

@end

@implementation VSuggestedPeopleCollectionViewController

+ (VSuggestedPeopleCollectionViewController *)instantiateFromStoryboard:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateViewControllerWithIdentifier:@"suggestedPeople"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:kSuggestedPersonCellIdentifier bundle:nil] forCellWithReuseIdentifier:kSuggestedPersonCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followingDidUpdate:) name:VMainUserDidChangeFollowingUserNotification object:nil];
    
    [self refresh];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isShowingNoData
{
    return self.suggestedUsers.count == 0 || self.error != nil;
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
    for ( VUser *user in self.suggestedUsers )
    {
        if ( [user isEqualToUser:updatedUser] )
        {
            user.isFollowing = updatedUser.isFollowing;
            break;
        }
    }
    [self.collectionView reloadData];
}

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
    // TODO: Remote this loop, testing only
    for ( VUser *user in users )
    {
        user.numberOfFollowers = @( arc4random() % 2000 );
    }
    
    if ( users.count == 0 )
    {
        [self clearDataAndHide];
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
    self.error = error;
    if ( self.delegate != nil )
    {
        [self.delegate didFailToLoad];
    }
    [self clearDataAndHide];
}

- (void)clearDataAndHide
{
    self.suggestedUsers = @[];
    [self.collectionView reloadData];
}

#pragma mark - VSuggestedPersonCollectionViewCellDelegate

- (void)unfollowPerson:(VUser *)user
{
    [[VObjectManager sharedManager] unfollowUser:user successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         // Do nothing
    }
                                           failBlock:^(NSOperation *operation, NSError *error)
     {
         // TODO: Handle error
         VLog( @"Unfollow failed: %@", [error localizedDescription] );
    }];
}

- (void)followPerson:(VUser *)user
{
    [[VObjectManager sharedManager] followUser:user successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
    {
        // Do nothing
    }
                                           failBlock:^(NSOperation *operation, NSError *error)
     {
         // TODO: Handle error
         VLog( @"Follow failed: %@", [error localizedDescription] );
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.suggestedUsers.count;
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
