//
//  VUsersViewController.m
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUsersViewController.h"
#import "UIView+AutoLayout.h"
#import "VFollowResponder.h"
#import "VUserCell.h"
#import "VUserProfileViewController.h"
#import "VDependencyManager+VUserProfile.h"
#import "VScrollPaginator.h"
#import "VNoContentView.h"
#import "VDependencyManager+VTracking.h"
#import "victorious-Swift.h"

@interface VUsersViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, VScrollPaginatorDelegate, VFollowResponder, PaginatedDataSourceDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VScrollPaginator *scrollPaginator;
@property (nonatomic, strong) VNoContentView *noContentView;
@property (nonatomic, copy, readonly) NSString *sourceScreenName;

@end

@implementation VUsersViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)dealloc
{
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

#pragma mark - View contorller lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSArray *visibleCells = self.collectionView.visibleCells;
    for ( VUserCell *cell in visibleCells )
    {
        [cell updateFollowingAnimated:NO];
    }
    
    [self.dependencyManager trackViewWillAppear:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
}

- (void)setUsersDataSource:(id<VUsersDataSource>)usersDataSource
{
    _usersDataSource = usersDataSource;
    _usersDataSource.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollPaginator = [[VScrollPaginator alloc] init];
    self.scrollPaginator.delegate = self;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = layout.minimumInteritemSpacing = 0.0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    [self.view v_addFitToParentConstraintsToSubview:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.contentInset = UIEdgeInsetsMake( 6.0f, 0.0f, 6.0f, 0.0f );
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.97f alpha:1.0f];
    
    NSString *identifier = [VUserCell suggestedReuseIdentifier];
    UINib *nib = [UINib nibWithNibName:identifier bundle:[NSBundle bundleForClass:[self class]]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor lightGrayColor];
    [refreshControl addTarget:self action:@selector(refershControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"VNoContentView" owner:nil options:nil];
    self.noContentView = nibs.firstObject;
    self.noContentView.dependencyManager = self.dependencyManager;
    [self.view addSubview:self.noContentView];
    [self.view sendSubviewToBack:self.noContentView];
    self.noContentView.frame = self.view.bounds;
    [self.view v_addFitToParentConstraintsToSubview:self.noContentView];
    
    [self.noContentView resetInitialAnimationState];
    
    [self refershControlAction:refreshControl];
    
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Public

- (void)refershControlAction:(UIRefreshControl *)refreshControl
{
    [self.usersDataSource loadUsersWithPageType:VPageTypeFirst completion:^(NSError *error)
     {
         [refreshControl endRefreshing];
     }];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [VUserCell suggestedReuseIdentifier];
    VUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.dependencyManager = self.dependencyManager;
    NSAssert( [self.usersDataSource.users[ indexPath.row ] conformsToProtocol:@protocol(VUserContext)],
             @"A `VUsersViewController` is attemtping to display an object that does not conform to protocol `VUserContext" );
    id<VUserContext> userContext = self.usersDataSource.users[ indexPath.row ];
    cell.user = userContext.user;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.usersDataSource.users.count;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [VUserCell desiredSizeWithCollectionViewBounds:collectionView.bounds];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VUser *selectedUser = self.usersDataSource.users[ indexPath.row ];
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:selectedUser];
    NSAssert( self.navigationController != nil, @"View controller must be in a navigation controller." );
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.scrollPaginator scrollViewDidScroll:scrollView];
}

#pragma mark - VScrollPaginatorDelegate

- (void)shouldLoadNextPage
{
    [self.usersDataSource loadUsersWithPageType:VPageTypeNext completion:nil];
}

#pragma mark - VFollowResponder

- (void)followUser:(VUser *)user withAuthorizedBlock:(void (^)(void))authorizedBlock andCompletion:(VFollowEventCompletion)completion fromViewController:(UIViewController *)viewControllerToPresentOn withScreenName:(NSString *)screenName
{
    NSString *sourceScreen = screenName?:self.sourceScreenName;
    id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(followUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:)
                                                                      withSender:nil];
    NSAssert(followResponder != nil, @"%@ needs a VFollowingResponder higher up the chain to communicate following commands with.", NSStringFromClass(self.class));
    
    [followResponder followUser:user
            withAuthorizedBlock:authorizedBlock
                  andCompletion:completion
             fromViewController:self
                 withScreenName:sourceScreen];
}

- (void)unfollowUser:(VUser *)user withAuthorizedBlock:(void (^)(void))authorizedBlock andCompletion:(VFollowEventCompletion)completion fromViewController:(UIViewController *)viewControllerToPresentOn withScreenName:(NSString *)screenName
{
    NSString *sourceScreen = screenName?:self.sourceScreenName;
    id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(unfollowUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:)
                                                                      withSender:nil];
    NSAssert(followResponder != nil, @"%@ needs a VFollowingResponder higher up the chain to communicate following commands with.", NSStringFromClass(self.class));
    
    [followResponder unfollowUser:user
              withAuthorizedBlock:authorizedBlock
                    andCompletion:completion
               fromViewController:self
                   withScreenName:sourceScreen];
}

- (NSString *)sourceScreenName
{
    NSDictionary *dict = @{
                           @(VUsersViewContextFollowers) : VFollowSourceScreenFollowers,
                           @(VUsersViewContextFollowing) : VFollowSourceScreenFollowing,
                           @(VUsersViewContextLikers) : VFollowSourceScreenLikers
                           };
    return [dict objectForKey:@(self.usersViewContext)];
}

#pragma mark - PaginatedDataSourceDelegate

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didUpdateVisibleItemsFrom:(NSOrderedSet *)oldValue to:(NSOrderedSet *)newValue
{
    [self.collectionView v_applyChangeInSection:0 from:oldValue to:newValue];
}

@end
