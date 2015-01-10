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
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Discover.h"
#import "VUser+RestKit.h"
#import "VDiscoverConstants.h"

static NSString * const kSuggestedPersonCellIdentifier          = @"VSuggestedPersonCollectionViewCell";
static NSString * const VStoryboardViewControllerIndentifier    = @"suggestedPeople";

@interface VSuggestedPeopleCollectionViewController () <VSuggestedPersonCollectionViewCellDelegate>

@property (nonatomic, strong) VUser *userToAnimate;

@end

@implementation VSuggestedPeopleCollectionViewController

+ (VSuggestedPeopleCollectionViewController *)instantiateFromStoryboard:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle bundleForClass:[self class]]];
    VSuggestedPeopleCollectionViewController *vc = [storyboard instantiateViewControllerWithIdentifier:VStoryboardViewControllerIndentifier];
    return vc;
}

#pragma mark - View controller life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.error = nil;
    
    [self.collectionView registerNib:[UINib nibWithNibName:kSuggestedPersonCellIdentifier bundle:nil] forCellWithReuseIdentifier:kSuggestedPersonCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followingDidUpdate:) name:VMainUserDidChangeFollowingUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusDidChange:) name:kLoggedInChangedNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotification selectors

- (void)loginStatusDidChange:(NSNotification *)note
{
    VObjectManager *objectManager = [VObjectManager sharedManager];
    
    if ( objectManager.mainUserLoggedIn )
    {
        [objectManager refreshFollowingsForUser:objectManager.mainUser
                                        successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             [self followingDidLoad];
         } failBlock:nil];
        
        self.suggestedUsers = [self usersByRemovingUser:objectManager.mainUser fromUsers:self.suggestedUsers];
    }
    
    [self updateFollowingInUsers:self.suggestedUsers];
    [self.collectionView reloadData];
}

- (void)followingDidUpdate:(NSNotification *)note
{
    [self updateFollowingInUsers:self.suggestedUsers];
    [self.collectionView reloadData];
}

- (void)updateFollowingInUsers:(NSArray *)users
{
    VObjectManager *objectManager = [VObjectManager sharedManager];
    
    [users enumerateObjectsUsingBlock:^(VUser *user, NSUInteger idx, BOOL *stop)
     {
         if ( objectManager.mainUserLoggedIn )
         {
             user.isFollowing = @( [objectManager.mainUser.following containsObject:user] );
         }
         else
         {
             user.isFollowing = @NO;
         }
     }];
}

#pragma mark - Loading data

- (void)refresh:(BOOL)shouldClearCurrentContent
{
    if ( shouldClearCurrentContent )
    {
        self.hasLoadedOnce = NO;
        self.suggestedUsers = @[];
        [self.collectionView reloadData];
    }
    
    [self reload];
}

- (void)reload
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
        [self clearData];
    }
    else
    {
        _suggestedUsers = users;
        [self updateFollowingInUsers:self.suggestedUsers];  // Will also reload data, so no need to call reloadData again
    }
    
    self.hasLoadedOnce = YES;
    
    if ( self.delegate != nil )
    {
        [self.delegate suggestedPeopleDidFinishLoading];
    }
    
    [self.collectionView reloadData];
}

- (void)didFailToLoadWithError:(NSError *)error
{
    self.hasLoadedOnce = YES;
    
    self.error = error;
    if ( self.delegate != nil )
    {
        [self.delegate suggestedPeopleDidFailToLoad];
    }
    [self clearData];
}

- (void)clearData
{
    _suggestedUsers = @[];
    [self.collectionView reloadData];
}

- (NSArray *)usersByRemovingUser:(VUser *)user fromUsers:(NSArray *)users
{
    if ( ![users containsObject:user] )
    {
        return users;
    }
    
    NSMutableArray *usersToKeep = [NSMutableArray arrayWithArray:users];
    [usersToKeep removeObject:user];
    return [NSArray arrayWithArray:usersToKeep];
}

- (void)followingDidLoad
{
    [self updateFollowingInUsers:self.suggestedUsers];
    
    VObjectManager *objectManager = [VObjectManager sharedManager];
    [objectManager loadNextPageOfFollowingsForUser:objectManager.mainUser
                                      successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         [self followingDidLoad];
     } failBlock:^(NSOperation *operation, NSError *error)
     {
         
     }];
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
        [[VObjectManager sharedManager] unfollowUser:user successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             user.numberOfFollowers = [NSNumber numberWithUnsignedInteger:user.numberOfFollowers.unsignedIntegerValue - 1];
             self.userToAnimate = user;
             [self.collectionView reloadData];
         } failBlock:nil];
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
        [[VObjectManager sharedManager] followUser:user successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             user.numberOfFollowers = [NSNumber numberWithUnsignedInteger:user.numberOfFollowers.unsignedIntegerValue + 1];
             self.userToAnimate = user;
             [self.collectionView reloadData];
         } failBlock:nil];
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
    BOOL animated = (self.suggestedUsers[ indexPath.row ] == self.userToAnimate);
    [cell setUser:self.suggestedUsers[ indexPath.row ]
         animated:animated];
    if (animated)
    {
        self.userToAnimate = nil;
    }
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
