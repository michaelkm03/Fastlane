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

#import "MBProgressHUD.h"

#import "UIActionSheet+VBlocks.h"
#import "UIViewController+VLayoutInsets.h"
#import "VNavigationControllerScrollDelegate.h"
#import "VObjectManager+Login.h"

//View Controllers
#import "VFindFriendsViewController.h"
#import "VAuthorizationViewControllerFactory.h"
#import "VWorkspaceFlowController.h"
#import "VNavigationController.h"

//Data Models
#import "VStream+Fetcher.h"
#import "VSequence.h"
#import "VAbstractFilter.h"

#import "VSettingManager.h"
#import "VScrollPaginator.h"
#import "VImageSearchResultsFooterView.h"
#import "VFooterActivityIndicatorView.h"
#import "VMultipleContainerViewControllerChild.h"

const CGFloat kVLoadNextPagePoint = .75f;

@interface VAbstractStreamCollectionViewController () <VMultipleContainerViewControllerChild, VScrollPaginatorDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) VScrollPaginator *scrollPaginator;
@property (nonatomic, strong) UIActivityIndicatorView *bottomActivityIndicator;

@property (nonatomic, strong) VImageSearchResultsFooterView *refreshFooter;

@property (nonatomic, strong) NSLayoutConstraint *headerYConstraint;
@property (nonatomic, strong) VNavigationControllerScrollDelegate *navigationControllerScrollDelegate;
@property (nonatomic, readwrite) CGFloat topInset;

@property (nonatomic, assign) NSUInteger previousNumberOfRowsInStreamSection;
@property (nonatomic, assign) BOOL shouldAnimateActivityViewFooter;

@end

@implementation VAbstractStreamCollectionViewController

#pragma mark - Init & Dealloc

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.streamTrackingHelper = [[VStreamTrackingHelper alloc] init];

    self.scrollPaginator = [[VScrollPaginator alloc] init];
    self.scrollPaginator.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.navigationBarShouldAutoHide = YES;
}

- (void)dealloc
{
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.collectionView registerNib:[VFooterActivityIndicatorView nibForSupplementaryView]
          forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                 withReuseIdentifier:[VFooterActivityIndicatorView reuseIdentifier]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    [self positionRefreshControl];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.streamTrackingHelper onStreamViewWillAppearWithStream:self.currentStream];
    
    BOOL shouldRefresh = !self.refreshControl.isRefreshing && self.streamDataSource.count == 0;
    if ( shouldRefresh )
    {
        [self refreshWithCompletion:nil];
    }
    
    if ( self.v_navigationController == nil && self.navigationController.navigationBarHidden )
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.streamTrackingHelper onStreamViewDidAppearWithStream:self.currentStream isBeingPresented:self.isBeingPresented];
    
    if ( self.navigationBarShouldAutoHide )
    {
        [self addScrollDelegate];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.streamTrackingHelper onStreamViewWillDisappearWithStream:self.currentStream
                                                  isBeingDismissed:self.isBeingDismissed];
    
    self.navigationControllerScrollDelegate = nil;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ( self.v_navigationController == nil )
    {
        if ( self.topInset != self.topLayoutGuide.length )
        {
            self.topInset = self.topLayoutGuide.length;
            [self.collectionView.collectionViewLayout invalidateLayout];
        }
    }
}

- (void)addScrollDelegate
{
    self.navigationControllerScrollDelegate = [[VNavigationControllerScrollDelegate alloc] initWithNavigationController:[self v_navigationController]];
}

#pragma mark - VMultipleContainerViewControllerChild protocol

- (void)viewControllerSelected
{
    [self.streamTrackingHelper viewControllerSelected:self.currentStream];
}

- (void)viewControllerAppearedAsInitial
{
    [self.streamTrackingHelper viewControllerAppearedAsInitial:self.currentStream];
}

#pragma mark - Tracking helper

- (void)trackStreamDidAppear
{
    // Override in subclasses
}

#pragma mark - Property Setters

- (void)setCurrentStream:(VStream *)currentStream
{
    _currentStream = currentStream;
    if ([self isViewLoaded])
    {
        self.streamDataSource.stream = currentStream;
        self.collectionView.dataSource = self.streamDataSource;
    }
}

- (void)v_setLayoutInsets:(UIEdgeInsets)layoutInsets
{
    [super v_setLayoutInsets:layoutInsets];
    self.topInset = layoutInsets.top;
    
    if ( [self isViewLoaded] )
    {
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self positionRefreshControl];
    }
}

- (void)setNavigationBarShouldAutoHide:(BOOL)navigationBarShouldAutoHide
{
    if ( navigationBarShouldAutoHide == _navigationBarShouldAutoHide )
    {
        return;
    }
    _navigationBarShouldAutoHide = navigationBarShouldAutoHide;
    
    if ( navigationBarShouldAutoHide )
    {
        [self addScrollDelegate];
    }
    else
    {
        self.navigationControllerScrollDelegate = nil;
    }
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
    
    [self.streamDataSource loadPage:VPageTypeFirst withSuccess:
     ^{
         [self.streamTrackingHelper streamDidLoad:self.currentStream];
         
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
}

- (void)positionRefreshControl
{
    UIView *subView = self.refreshControl.subviews[0];
    
    // Since we're using the collection flow delegate method for the insets, we need to manually position the frame of the refresh control.
    subView.center = CGPointMake(CGRectGetMidX(self.refreshControl.bounds), CGRectGetMidY(self.refreshControl.bounds) + self.topInset * 0.5f);
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
    return isLastSection && hasOneOrMoreItems && [self.streamDataSource filterCanLoadNextPage];
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

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 0)
    {
        return UIEdgeInsetsMake(self.topInset, 0, 0, 0);
    }
    else
    {
        return UIEdgeInsetsZero;
    }
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
    if (self.streamDataSource.count == 0 || self.streamDataSource.isFilterLoading || !self.streamDataSource.filterCanLoadNextPage)
    {
        return;
    }
    
    self.shouldAnimateActivityViewFooter = YES;
    [self.streamDataSource loadPage:VPageTypeNext withSuccess:
     ^{
         __weak typeof(self) welf = self;
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                        {
                            [welf.collectionView flashScrollIndicators];
                        });
     }
                                              failure:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.scrollPaginator scrollViewDidScroll:scrollView];
    [self.navigationControllerScrollDelegate scrollViewDidScroll:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.navigationControllerScrollDelegate scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self.navigationControllerScrollDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
