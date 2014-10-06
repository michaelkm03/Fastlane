//
//  VSuggestedPeople.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSuggestedPeople.h"
#import "VSuggestedPersonCollectionViewCell.h"
#import "VObjectManager+Users.h"
#import "VUser.h"

static NSString * const kSuggestedPersonCellIdentifier = @"VSuggestedPersonCollectionViewCell";

@interface VSuggestedPeople () <VSuggestedPersonCollectionViewCellDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *suggestedPeople;

@end

@implementation VSuggestedPeople

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if (self)
    {
        self.collectionView = collectionView;
    }
    return self;
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
    _collectionView = collectionView;
    [self configureCollectionView:self.collectionView];
    [self refresh];
}

- (void)configureCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[UINib nibWithNibName:kSuggestedPersonCellIdentifier bundle:nil] forCellWithReuseIdentifier:kSuggestedPersonCellIdentifier];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView reloadData];
}

#pragma mark - Loading remote data and responses

- (void)usersDidLoad:(NSArray *)users
{
    NSMutableArray *suggestedUsersData = [[NSMutableArray alloc] init];
    for ( VUser *user in users )
    {
        VSuggestedPersonData *data = [[VSuggestedPersonData alloc] init];
        data.isMainUserFollowing = user.isFollowing.boolValue;
        data.username = user.name;
        data.numberOfFollowers = @( arc4random() % 1000 );
        data.remoteId = user.remoteId;
        data.pictureUrl = user.pictureUrl;
        [suggestedUsersData addObject:data];
    }
    self.suggestedPeople = [NSArray arrayWithArray:suggestedUsersData];
    [self.collectionView reloadData];
}

- (void)refresh
{
    [[VObjectManager sharedManager] listOfRecommendedFriendsWithSuccessBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         [self usersDidLoad:resultObjects];
     }
                                                                   failBlock:^(NSOperation *operation, NSError *error)
     {
         // TODO: Handle error
     }];
}

#pragma mark - VSuggestedPersonCollectionViewCellDelegate

- (void)unfollowPerson:(VSuggestedPersonData *)userData
{
    [[VObjectManager sharedManager] unfollowUserWithId:userData.remoteId successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
    {
    }
                                           failBlock:^(NSOperation *operation, NSError *error)
     {
         VLog( @"Unfollow failed: %@", [error localizedDescription] );
    }];
}

- (void)followPerson:(VSuggestedPersonData *)userData
{
    [[VObjectManager sharedManager] followUserWithId:userData.remoteId successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
    }
                                           failBlock:^(NSOperation *operation, NSError *error)
     {
         VLog( @"Follow failed: %@", [error localizedDescription] );
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.suggestedPeople.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VSuggestedPersonCollectionViewCell *cell = (VSuggestedPersonCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kSuggestedPersonCellIdentifier forIndexPath:indexPath];
    VSuggestedPersonData *suggestPersonData = self.suggestedPeople[ indexPath.row ];
    cell.data = suggestPersonData;
    cell.delegate = self;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VSuggestedPersonCollectionViewCell *cell = (VSuggestedPersonCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    __unused NSNumber *userId = cell.data.remoteId;
}

@end
