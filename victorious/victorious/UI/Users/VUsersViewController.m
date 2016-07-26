//
//  VUsersViewController.m
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUsersViewController.h"
#import "UIView+AutoLayout.h"
#import "VUserCell.h"
#import "VUserProfileViewController.h"
#import "VNoContentView.h"
#import "VDependencyManager+VTracking.h"
#import "victorious-Swift.h"

@interface VUsersViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

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
    
    self.noContentView = [VNoContentView viewFromNibWithFrame:self.collectionView.frame];
    self.noContentView.dependencyManager = self.dependencyManager;
    self.noContentView.title = [self.usersDataSource noContentTitle];
    self.noContentView.icon = [self.usersDataSource noContentImage];
    self.noContentView.message = [self.usersDataSource noContentMessage];
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
    cell.user = self.usersDataSource.users[ indexPath.row ];
    cell.sourceScreenName = self.sourceScreenName;
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
    UIViewController *profileViewController = [self.dependencyManager userProfileViewControllerFor:selectedUser];
    NSAssert( self.navigationController != nil, @"View controller must be in a navigation controller." );
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - source screen logic

- (NSString *)sourceScreenName
{
    NSDictionary *dict = @{
                           @(VUsersViewContextFollowers) : VFollowSourceScreenFollowers,
                           @(VUsersViewContextFollowing) : VFollowSourceScreenFollowing,
                           @(VUsersViewContextLikers) : VFollowSourceScreenLikers
                           };
    return [dict objectForKey:@(self.usersViewContext)];
}

@end
