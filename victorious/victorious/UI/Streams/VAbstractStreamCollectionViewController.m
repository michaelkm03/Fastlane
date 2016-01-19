//
//  VAbstractStreamCollectionViewController.m
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractStreamCollectionViewController.h"
#import "VStreamCollectionViewDataSource.h"
#import "VCardDirectoryCell.h"
#import "MBProgressHUD.h"
#import "UIViewController+VLayoutInsets.h"
#import "VNavigationController.h"
#import "VStream+Fetcher.h"
#import "VSequence.h"
#import "VAbstractFilter.h"
#import "VScrollPaginator.h"
#import "VImageSearchResultsFooterView.h"
#import "VFooterActivityIndicatorView.h"
#import "VDependencyManager.h"
#import "victorious-Swift.h"

@interface VAbstractStreamCollectionViewController () <VScrollPaginatorDelegate>

@property (nonatomic, strong) VScrollPaginator *scrollPaginator;
@property (nonatomic, strong) UIActivityIndicatorView *bottomActivityIndicator;

@property (nonatomic, strong) VImageSearchResultsFooterView *refreshFooter;

@property (nonatomic, strong) NSLayoutConstraint *headerYConstraint;
@property (nonatomic, readwrite) CGFloat topInset;

@property (nonatomic, assign) NSUInteger previousNumberOfRowsInStreamSection;
@property (nonatomic, assign) BOOL shouldAnimateActivityViewFooter;

@property (nonatomic, strong) AppTimingStreamHelper *appTimingStreamHelper;

@end

@implementation VAbstractStreamCollectionViewController

@synthesize multipleContainerChildDelegate;

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
    
    id<TimingTracker> timingTracker = [DefaultTimingTracker sharedInstance];
    self.appTimingStreamHelper = [[AppTimingStreamHelper alloc] initWithStreamId:self.streamDataSource.stream.streamId
                                                                   timingTracker:timingTracker];
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
    
    self.collectionView.accessibilityIdentifier = VAutomationIDentifierStreamCollectionView;
    
    [self.collectionView registerNib:[VFooterActivityIndicatorView nibForSupplementaryView]
          forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                 withReuseIdentifier:[VFooterActivityIndicatorView reuseIdentifier]];
    [self.collectionView registerNib:[VFooterActivityIndicatorView nibForSupplementaryView]
          forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter
                 withReuseIdentifier:[VFooterActivityIndicatorView reuseIdentifier]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    [self positionRefreshControl];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.streamTrackingHelper onStreamViewWillAppearWithStream:self.currentStream];
    
    BOOL shouldRefresh = !self.refreshControl.isRefreshing && self.streamDataSource.count == 0 && [VCurrentUser user] != nil;
    if ( shouldRefresh )
    {
        [self loadPage:VPageTypeRefresh completion:nil];
    }
    
    if ( self.v_navigationController == nil && self.navigationController.navigationBarHidden )
    {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
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
    
    // Adjust our scroll indicator insets to account for nav bar
    CGRect navBarFrame = self.v_navigationController.innerNavigationController.navigationBar.frame;
    CGRect supplementaryViewFrame = self.v_navigationController.supplementaryHeaderView.frame;
    CGFloat indicatorTopOffset = CGRectGetMaxY(navBarFrame) + CGRectGetHeight(supplementaryViewFrame);
    UIEdgeInsets scrollIndicatorInsets = UIEdgeInsetsMake(indicatorTopOffset, 0, 0, 0);
    self.collectionView.scrollIndicatorInsets = scrollIndicatorInsets;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.streamTrackingHelper onStreamViewWillDisappearWithStream:self.currentStream
                                                  isBeingDismissed:self.isBeingDismissed];
    
    self.navigationControllerScrollDelegate = nil;
    [self.refreshControl endRefreshing];
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
    
    //This has to be performed here, after invalidating the collection view layout
    if ( self.targetStreamItem != nil )
    {
        NSUInteger index = [self.streamDataSource.visibleItems indexOfObject:self.targetStreamItem];
        if ( index != NSNotFound && index < (NSUInteger)[self.collectionView numberOfItemsInSection:0] )
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
            if ( !CGSizeEqualToSize(attributes.size, CGSizeZero) )
            {
                CGPoint offset = attributes.frame.origin;
                offset.x = 0;
                offset.y -= self.v_layoutInsets.top;
                self.collectionView.contentOffset = offset;
                self.targetStreamItem = nil;
            }
        }
    }
}

- (void)addScrollDelegate
{
    self.navigationControllerScrollDelegate = [[VNavigationControllerScrollDelegate alloc] initWithNavigationController:[self v_navigationController]];
}

- (void)updateNavigationItems
{
    // Nothing to do here, provided to override in subclasses
}

#pragma mark - VMultipleContainerChild protocol

- (void)multipleContainerDidSetSelected:(BOOL)isDefault
{
    if ( isDefault )
    {
        [self.streamTrackingHelper viewControllerAppearedAsInitial:self.currentStream];
    }
    else
    {
        // In spite of its name, this is not actullay a stream-related event, so it is not part of `streamTrackingHelper`.
        // This event fires for any conformist of `VMultipleContainerChild`.
        NSDictionary *params = @{ VTrackingKeyStreamName : self.currentStream.name ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectStream parameters:params];
        
        [self.streamTrackingHelper multipleContainerDidSetSelected:self.currentStream];
    }
    
    [self updateNavigationItems];
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
    [self loadPage:VPageTypeRefresh completion:^
     {
         [self updateRowCount];
     }];
}

- (void)updateRowCount
{
    const NSInteger lastSection = MAX( 0, [self.collectionView numberOfSections] - 1 );
    self.previousNumberOfRowsInStreamSection = [self.collectionView numberOfItemsInSection:lastSection];
}

- (void)loadPage:(VPageType)pageType completion:(void(^)(void))completion
{
    if ( self.streamDataSource.isLoading )
    {
        [self.refreshControl endRefreshing];
        return;
    }
    
    if ( self.streamDataSource.count == 0 && !self.streamDataSource.hasHeaderCell )
    {
        [self.refreshControl beginRefreshing];
    }
    
    [self.streamDataSource loadPage:VPageTypeRefresh completion:^(NSError *_Nullable error)
     {
         [self.streamTrackingHelper streamDidLoad:self.currentStream];
         
         if ( error != nil )
         {
#warning TODO: Show any REAL error (this excludes last page or no network errors)
         }
         
         if ( completion != nil )
         {
             completion();
         }
         
         [self.refreshControl endRefreshing];
         [self.appTimingStreamHelper endStreamLoadAppTimingEventsWithPageType:VPageTypeRefresh];
     }];
}

- (void)positionRefreshControl
{
    if ( self.refreshControl.subviews.count == 0 )
    {
        return;
    }
    // Since we're using the collection flow delegate method for the insets
    // we need to manually position the frame of the refresh control.
    UIView *subView = self.refreshControl.subviews[0];
    subView.center = CGPointMake(CGRectGetMidX(self.refreshControl.bounds),
                                 CGRectGetMidY(self.refreshControl.bounds) + self.topInset * 0.5f);
}

#pragma mark - Bottom activity indicator footer

- (void)animateNewlyPopulatedCell:(UICollectionViewCell *)cell
                 inCollectionView:(UICollectionView *)collectionView
                      atIndexPath:(NSIndexPath *)indexPath
{
    const NSUInteger currentCount = [self.collectionView numberOfItemsInSection:indexPath.section];
    const BOOL newPageDidLoad = currentCount != self.previousNumberOfRowsInStreamSection && self.previousNumberOfRowsInStreamSection > 0;
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
    const BOOL canLoadNextPage = !self.streamDataSource.isLoading;
    const BOOL isLastSection = section == MAX( [self.collectionView numberOfSections] - 1, 0);
    const BOOL hasOneOrMoreItems = [self hasEnoughItemsToShowLoadingIndicatorFooterInSection:section];
    return isLastSection && hasOneOrMoreItems;
}

- (BOOL)hasEnoughItemsToShowLoadingIndicatorFooterInSection:(NSInteger)section
{
    return [self.collectionView numberOfItemsInSection:section] > 1;
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
    if ( self.collectionView.visibleCells.count == 0 ||
         self.streamDataSource.visibleItems.count == 0 ||
         self.streamDataSource.isLoading )
    {
        return;
    }
    
    self.shouldAnimateActivityViewFooter = YES;
    [self updateRowCount];
    __weak typeof(self) welf = self;
    [self.streamDataSource loadPage:VPageTypeNext completion:^(NSError *_Nullable error)
     {
         [welf.collectionView flashScrollIndicators];
         [welf.appTimingStreamHelper endStreamLoadAppTimingEventsWithPageType:VPageTypeNext];
     }];
}

- (void)flashScrollIndicatorsWithDelay:(NSTimeInterval)delay
{
    __weak typeof(self) welf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       [welf.collectionView flashScrollIndicators];
                   });
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.scrollPaginator scrollViewDidScroll:scrollView];
    [self.navigationControllerScrollDelegate scrollViewDidScroll:scrollView];
    
    [self.navigationViewfloatingController updateContentOffsetOnScroll:scrollView.contentOffset];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.navigationControllerScrollDelegate scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self.navigationControllerScrollDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.navigationControllerScrollDelegate scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self.navigationControllerScrollDelegate scrollViewDidScrollToTop:scrollView];
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
