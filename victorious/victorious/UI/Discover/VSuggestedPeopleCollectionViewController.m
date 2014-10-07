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
#import "VUser.h"

static NSString * const kSuggestedPersonCellIdentifier = @"VSuggestedPersonCollectionViewCell";

@interface VSuggestedPeopleCollectionViewController () <VSuggestedPersonCollectionViewCellDelegate>

@property (nonatomic, strong) NSArray *suggestedUsers;

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
    
    [self refresh];
}

#pragma mark - Loading remote data and responses

- (void)usersDidLoad:(NSArray *)users
{
    self.suggestedUsers = users;
    [self.collectionView reloadData];
}

- (void)refresh
{
    [[VObjectManager sharedManager] listOfRecommendedFriendsWithSuccessBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         // TODO: Remote this loop, testing only
         for ( VUser *user in resultObjects )
         {
             user.numberOfFollowers = @( arc4random() % 2000 );
         }
         [self usersDidLoad:resultObjects];
     }
                                                                   failBlock:^(NSOperation *operation, NSError *error)
     {
         // TODO: Handle error
         VLog( @"Recommended Friends failed: %@", [error localizedDescription] );
     }];
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
    __unused VUser *user = cell.user;
}

@end
