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

@interface VUsersViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, VScrollPaginatorDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VScrollPaginator *scrollPaginator;
@property (nonatomic, assign) BOOL canLoadNextPage;
@property (nonatomic, strong) VNoContentView *noContentView;

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

#pragma mark - View contorller lifecycle

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
    
    [self setInitialNoContentAnimationState];
    
    [self refershControlAction:refreshControl];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - No content view

- (void)setInitialNoContentAnimationState
{
    self.noContentView.alpha = 0.0;
    const CGFloat scale = 0.8f;
    self.noContentView.transform = CGAffineTransformMakeScale( scale, scale );
}

- (void)showNoContent
{
    [UIView animateWithDuration:0.5f
                          delay:0.2f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.5f
                        options:kNilOptions animations:^{
        
         self.noContentView.alpha = 1.0f;
         self.noContentView.transform = CGAffineTransformIdentity;
     } completion:nil];
}

- (void)updateHasContent
{
    [self.collectionView reloadData];
    
    if ( self.usersDataSource.users.count == 0 )
    {
        self.noContentView.icon = self.usersDataSource.noContentImage;
        self.noContentView.title = self.usersDataSource.noContentTitle;
        self.noContentView.message = self.usersDataSource.noContentMessage;
        
        [self showNoContent];
    }
    else
    {
        [self setInitialNoContentAnimationState];
    }
}

#pragma mark - Public

- (void)refershControlAction:(UIRefreshControl *)refreshControl
{
    [self.usersDataSource refreshWithPageType:VPageTypeFirst completion:^(BOOL success, NSError *error)
     {
         self.canLoadNextPage = success;  //< Can't load next page until the first page has loaded successfully
         [refreshControl endRefreshing];
         [self updateHasContent];
     }];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [VUserCell suggestedReuseIdentifier];
    VUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.dependencyManager = self.dependencyManager;
    cell.user = self.usersDataSource.users[ indexPath.row ];
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
    if ( !self.canLoadNextPage )
    {
        return;
    }
    
    [self.usersDataSource refreshWithPageType:VPageTypeNext completion:^(BOOL success, NSError *error)
     {
         if ( success )
         {
             [self.collectionView reloadData];
         }
     }];
}

@end
