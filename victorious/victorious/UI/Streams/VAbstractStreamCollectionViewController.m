//
//  VAbstractStreamCollectionViewController.m
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractStreamCollectionViewController.h"

#import "VStreamCollectionViewDataSource.h"
#import "VDirectoryItemCell.h"

#import "VNavigationHeaderView.h"
#import "MBProgressHUD.h"

#import "UIActionSheet+VBlocks.h"
#import "VObjectManager+Login.h"

//View Controllers
#import "UIViewController+VSideMenuViewController.h"
#import "VCameraViewController.h"
#import "VCreatePollViewController.h"
#import "VFindFriendsViewController.h"
#import "VAuthorizationViewControllerFactory.h"

//Data Models
#import "VStream+Fetcher.h"
#import "VSequence.h"
#import "VAbstractFilter.h"

#import "VSettingManager.h"
#import "VScrollPaginator.h"
#import "UIViewController+VNavMenu.h"
#import "VImageSearchResultsFooterView.h"
#import "VFooterActivityIndicatorView.h"

const CGFloat kVLoadNextPagePoint = .75f;

@interface VAbstractStreamCollectionViewController () <UICollectionViewDelegate, VNavigationHeaderDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet VScrollPaginator *scrollPaginator;
@property (nonatomic, strong) UIActivityIndicatorView *bottomActivityIndicator;

@property (nonatomic, strong) VImageSearchResultsFooterView *refreshFooter;

@property (nonatomic, strong) NSLayoutConstraint *headerYConstraint;

@property (nonatomic, assign) NSUInteger previousNumberOfRowsInStreamSection;
@property (nonatomic, assign) BOOL shouldAnimateActivityViewFooter;

@end

@implementation VAbstractStreamCollectionViewController

- (void)dealloc
{
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.collectionView.alwaysBounceVertical = YES;
    
    [self.collectionView registerNib:[VFooterActivityIndicatorView nibForSupplementaryView]
          forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                 withReuseIdentifier:[VFooterActivityIndicatorView reuseIdentifier]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navHeaderView)
    {
        UIEdgeInsets insets = self.collectionView.contentInset;
        insets.top = CGRectGetHeight(self.navHeaderView.bounds);
        self.contentInset = insets;
    }

    if ( !self.refreshControl.isRefreshing && self.streamDataSource.count == 0 )
    {
        [self refresh:nil];
    }
    
    
    [self.refreshControl removeFromSuperview];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    UIView *subView = self.refreshControl.subviews[0];
    
    //Since we're using the collection flow delegate method for the insets, we need to manually position the frame of the refresh control.
    subView.frame = CGRectMake(CGRectGetMinX(subView.frame), CGRectGetMinY(subView.frame) + self.contentInset.top / 2,
                               CGRectGetWidth(subView.frame), CGRectGetHeight(subView.frame));
}

- (BOOL)prefersStatusBarHidden
{
    return !CGRectContainsRect(self.view.frame, self.navHeaderView.frame);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ![[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? UIStatusBarStyleLightContent
    : UIStatusBarStyleDefault;
}

- (void)setCurrentStream:(VStream *)currentStream
{
    _currentStream = currentStream;
    if ([self isViewLoaded])
    {
        self.streamDataSource.stream = currentStream;
        self.collectionView.dataSource = self.streamDataSource;
    }
}

- (IBAction)findFriendsAction:(id)sender
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    VFindFriendsViewController *ffvc = [VFindFriendsViewController newFindFriendsViewController];
    [ffvc setShouldAutoselectNewFriends:NO];
    [self.navigationController pushViewController:ffvc animated:YES];
}

#pragma mark - Refresh

- (IBAction)refresh:(UIRefreshControl *)sender
{
    [self refreshWithCompletion:^
    {
        const NSInteger lastSection = MAX( 0, [self.collectionView numberOfSections] - 1 );
        self.previousNumberOfRowsInStreamSection = [self.collectionView numberOfItemsInSection:lastSection];
    }];
}

- (void)refreshWithCompletion:(void(^)(void))completionBlock
{
    if (self.streamDataSource.isFilterLoading)
    {
        return;
    }
    
    [self.streamDataSource refreshWithSuccess:^(void)
     {
         [self.refreshControl endRefreshing];
         if (completionBlock)
         {
             completionBlock();
         }
     }
                                         failure:^(NSError *error)
     {
         [self.refreshControl endRefreshing];
         MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
         hud.mode = MBProgressHUDModeText;
         hud.labelText = NSLocalizedString(@"RefreshError", @"");
         hud.userInteractionEnabled = NO;
         [hud hide:YES afterDelay:3.0];
     }];
    
    [self.refreshControl beginRefreshing];
    self.refreshControl.hidden = NO;
}

#pragma mark - Bottom activity indicator footer

- (void)animateNewlyPopulatedCell:(UICollectionViewCell *)cell
                 inCollectionView:(UICollectionView *)collectionView
                      atIndexPath:(NSIndexPath *)indexPath
{
    const NSUInteger currentCount = [self.collectionView numberOfItemsInSection:indexPath.section];
    const BOOL newPageDidLoad = currentCount != self.previousNumberOfRowsInStreamSection;
    const BOOL isFirstRowOfNewPage = indexPath.row == (NSInteger) self.previousNumberOfRowsInStreamSection;
    if ( newPageDidLoad && isFirstRowOfNewPage )
    {
        const CGFloat translationY = [VFooterActivityIndicatorView desiredSizeWithCollectionViewBounds:collectionView.bounds].height;
        cell.transform = CGAffineTransformMakeTranslation( 0.0f, translationY );
        [UIView animateWithDuration:0.5f
                              delay:0.0f
             usingSpringWithDamping:0.9f
              initialSpringVelocity:0.2f
                            options:kNilOptions
                         animations:^
         {
             cell.transform = CGAffineTransformIdentity;
         }
                         completion:nil];
        
        self.previousNumberOfRowsInStreamSection = currentCount;
    }
}

- (BOOL)shouldDisplayActivityViewFooterForCollectionView:(UICollectionView *)collectionView inSection:(NSInteger)section
{
    const BOOL isLastSection = section == MAX( [self.collectionView numberOfSections] - 1, 0);
    const BOOL hasOneOrMoreItems = [collectionView numberOfItemsInSection:section] > 1;
    return isLastSection && hasOneOrMoreItems;
}

- (BOOL)shouldAnimateActivityViewFooter
{
    // Once this property is read as YES, it automatically returns to NO
    if ( _shouldAnimateActivityViewFooter )
    {
        _shouldAnimateActivityViewFooter = NO;
        return YES;
    }
    
    return NO;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if ( [self shouldDisplayActivityViewFooterForCollectionView:collectionView inSection:section] )
    {
        return [VFooterActivityIndicatorView desiredSizeWithCollectionViewBounds:collectionView.bounds];
    }
    
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ( [self shouldAnimateActivityViewFooter] && [view isKindOfClass:[VFooterActivityIndicatorView class]] )
    {
        [((VFooterActivityIndicatorView *)view) setActivityIndicatorVisible:YES animated:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self shouldDisplayActivityViewFooterForCollectionView:collectionView inSection:indexPath.section] )
    {
        [self animateNewlyPopulatedCell:cell inCollectionView:collectionView atIndexPath:indexPath];
    }
}

#pragma mark - VScrollPaginatorDelegate

- (void)shouldLoadNextPage
{
    if (self.streamDataSource.isFilterLoading)
    {
        return;
    }
    
    self.shouldAnimateActivityViewFooter = YES;
    [self.streamDataSource loadNextPageWithSuccess:^(void)
     {
         __weak typeof(self) welf = self;
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                        {
                            [welf.collectionView flashScrollIndicators];
                        });
     }
                                              failure:^(NSError *error)
     {
     }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.scrollPaginator scrollViewDidScroll:scrollView];
    
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    if (translation.y < 0 && scrollView.contentOffset.y > CGRectGetHeight(self.navHeaderView.frame))
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self v_hideHeader];
         }];
    }
    else if (translation.y > 0)
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self v_showHeader];
         }];
    }
    
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
