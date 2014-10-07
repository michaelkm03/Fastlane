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
#import "VUser+RestKit.h"
#import "VDiscoverConstants.h"

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followingDidUpdate:) name:VMainUserDidChangeFollowingUserNotification object:nil];
    
    [self refresh];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)followingDidUpdate:(NSNotification *)note
{
    if ( note.userInfo == nil )
    {
        return;
    }
    
    VUser *updatedUser = note.userInfo[ VDiscoverUserProfileSelectedKeyUser ];
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

- (NSArray *)updateCachedModels:(NSArray *)models withEntityName:(NSString *)entityName
{
    NSMutableArray *updatedUsers = [[NSMutableArray alloc] init];
    RKManagedObjectStore *store = [RKManagedObjectStore defaultStore];
    NSError *error = nil;
    for ( VUser *user in models )
    {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:[store mainQueueManagedObjectContext]];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(remoteId == %i)", user.remoteId.integerValue ];
        [request setPredicate:predicate];
        
        NSArray *array = [[store mainQueueManagedObjectContext] executeFetchRequest:request error:&error];
        if ( array != nil && array.count > 0 )
        {
            // Add the new updated object
            [updatedUsers addObject:array[0]];
        }
        else
        {
            // Keep the old one if something failed
            [updatedUsers addObject:user];
        }
    }
    return [NSArray arrayWithArray:updatedUsers];
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
    NSDictionary *userInfo = @{ VDiscoverUserProfileSelectedKeyUser : user };
    [[NSNotificationCenter defaultCenter] postNotificationName:VDiscoverUserProfileSelectedNotification object:nil userInfo:userInfo];
}

@end
