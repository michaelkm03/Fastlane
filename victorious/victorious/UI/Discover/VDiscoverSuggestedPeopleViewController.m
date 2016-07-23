//
//  VDiscoverSuggestedPeopleViewControllerr.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDiscoverSuggestedPeopleViewController.h"
#import "VDiscoverSuggestedPersonCell.h"
#import "VDiscoverConstants.h"
#import "victorious-Swift.h"

static NSString * const kSuggestedPersonCellIdentifier          = @"VDiscoverSuggestedPersonCell";
static NSString * const VStoryboardViewControllerIndentifier    = @"suggestedPeople";
static const UIEdgeInsets kCollectionViewEdgeInsets = {0, 0, 0, 0};

@interface VDiscoverSuggestedPeopleViewController ()

@property (nonatomic, strong) VUser *userToAnimate;

@end

@implementation VDiscoverSuggestedPeopleViewController

+ (VDiscoverSuggestedPeopleViewController *)instantiateFromStoryboard:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle bundleForClass:[self class]]];
    VDiscoverSuggestedPeopleViewController *vc = [storyboard instantiateViewControllerWithIdentifier:VStoryboardViewControllerIndentifier];
    return vc;
}

#pragma mark - View controller life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.error = nil;
    
    [self.collectionView registerNib:[UINib nibWithNibName:kSuggestedPersonCellIdentifier bundle:nil] forCellWithReuseIdentifier:kSuggestedPersonCellIdentifier];
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).sectionInset = kCollectionViewEdgeInsets;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusDidChange:) name:kLoggedInChangedNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotification selectors

- (void)loginStatusDidChange:(NSNotification *)note
{
    [self.collectionView reloadData];
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
    else
    {
        NSArray *visibleCells = self.collectionView.visibleCells;
        for ( VDiscoverSuggestedPersonCell *cell in visibleCells )
        {
            [cell updateFollowingAnimated:NO];
        }
    }
    
    [self reload];
}

- (void)reload
{
    TrendingUsersOperation *operation = [[TrendingUsersOperation alloc] init];
    [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
    {
        if (error == nil)
        {
            [self didLoadWithUsers:operation.results];
        }
        else
        {
            [self didFailToLoadWithError:error];
        }
    }];
}

- (void)didLoadWithUsers:(NSArray *)users
{
    BOOL shouldReload = ![self.suggestedUsers isEqualToArray:users];
    
    if ( users.count == 0 )
    {
        [self clearData];
    }
    else
    {
        _suggestedUsers = users;
    }
    
    self.hasLoadedOnce = YES;
    
    if ( self.delegate != nil )
    {
        [self.delegate suggestedPeopleDidFinishLoading];
    }

    // Only reload if we have new content
    if (shouldReload)
    {
        [self.collectionView reloadData];
    }
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

#pragma mark - VTableViewControllerProtocol

@synthesize hasLoadedOnce;

- (BOOL)isShowingNoData
{
    return self.suggestedUsers.count == 0 || self.error != nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.isShowingNoData ? 0 : self.suggestedUsers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VDiscoverSuggestedPersonCell *cell = (VDiscoverSuggestedPersonCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kSuggestedPersonCellIdentifier forIndexPath:indexPath];
    BOOL animated = (self.suggestedUsers[ indexPath.row ] == self.userToAnimate);
    [cell setUser:self.suggestedUsers[ indexPath.row ]
         animated:animated];
    if (animated)
    {
        self.userToAnimate = nil;
    }
    cell.dependencyManager = self.dependencyManager;
    return cell;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(VDiscoverSuggestedPersonCell *cell, NSUInteger idx, BOOL *stop)
    {
        
        cell.dependencyManager = dependencyManager;
        
    }];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VDiscoverSuggestedPersonCell *cell = (VDiscoverSuggestedPersonCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    VUser *user = cell.user;
    
    NSDictionary *params = @{ VTrackingKeyName : user.displayName ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectSuggestedUser parameters:params];
    
    NSDictionary *userInfo = @{ kVDiscoverUserProfileSelectedKeyUser : user };
    [[NSNotificationCenter defaultCenter] postNotificationName:kVDiscoverUserProfileSelectedNotification object:nil userInfo:userInfo];
}

@end
