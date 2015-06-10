//
//  VSuggestedPeopleCollectionViewController.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDiscoverSuggestedPeopleViewController.h"
#import "VDiscoverSuggestedPersonCell.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Discover.h"
#import "VUser+RestKit.h"
#import "VDiscoverConstants.h"
#import "VAuthorizedAction.h"

static NSString * const kSuggestedPersonCellIdentifier          = @"VSuggestedPersonCollectionViewCell";
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
    
    NSDictionary *params = @{ VTrackingKeyName : user.name ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectSuggestedUser parameters:params];
    
    NSDictionary *userInfo = @{ kVDiscoverUserProfileSelectedKeyUser : user };
    [[NSNotificationCenter defaultCenter] postNotificationName:kVDiscoverUserProfileSelectedNotification object:nil userInfo:userInfo];
}

@end
