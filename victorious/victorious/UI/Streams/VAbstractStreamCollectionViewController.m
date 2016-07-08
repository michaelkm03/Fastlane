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
#import "VStreamItem+Fetcher.h"
#import "VSequence.h"
#import "VScrollPaginator.h"
#import "VFooterActivityIndicatorView.h"
#import "VDependencyManager.h"
#import "victorious-Swift.h"

@interface VAbstractStreamCollectionViewController () <VScrollPaginatorDelegate>

@property (nonatomic, strong) VScrollPaginator *scrollPaginator;
@property (nonatomic, strong) UIActivityIndicatorView *bottomActivityIndicator;

@property (nonatomic, strong) NSLayoutConstraint *headerYConstraint;
@property (nonatomic, readwrite) CGFloat topInset;

@property (nonatomic, assign) NSUInteger previousNumberOfRowsInStreamSection;

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
    self.appTimingStreamHelper = [[AppTimingStreamHelper alloc] initWithStreamId:self.streamDataSource.stream.remoteId
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
    
    [self.dependencyManager trackViewWillAppear:self];
    
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
    
    [self.dependencyManager trackViewWillDisappear:self];
    
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
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            self.targetStreamItem = nil;
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
    [self loadPage:VPageTypeFirst completion:^
     {
         [self.refreshControl endRefreshing];
     }];
}

- (void)loadPage:(VPageType)pageType completion:(void(^)(void))completion
{
    if ( self.streamDataSource.isLoading )
    {
        if ( [self.refreshControl isRefreshing] )
        {
            [self.refreshControl endRefreshing];
        }
        return;
    }
}

- (void)positionRefreshControl
{
    UIView *subView = self.refreshControl.subviews.firstObject;
    if (subView != nil)
    {
        // Since we're using the collection flow delegate method for the insets
        // we need to manually position the frame of the refresh control.
        subView.center = CGPointMake(CGRectGetMidX(self.refreshControl.bounds),
                                     CGRectGetMidY(self.refreshControl.bounds) + self.topInset * 0.5f);
    }
}

#pragma mark - Bottom activity indicator footer

- (BOOL)shouldDisplayActivityViewFooterForCollectionView:(UICollectionView *)collectionView inSection:(NSInteger)section
{
    const BOOL isLoading = self.streamDataSource.isLoading;
    const BOOL isLastVisibleSection = section == MAX( [self.collectionView numberOfSections] - 1, 0);
    const BOOL hasOneOrMoreItems = [self.collectionView numberOfItemsInSection:section] > 0;
    const BOOL shouldDisplayActivityViewFooter = isLastVisibleSection && isLoading && hasOneOrMoreItems;
    return shouldDisplayActivityViewFooter;
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
    if ( [view isKindOfClass:[VFooterActivityIndicatorView class]] )
    {
        [((VFooterActivityIndicatorView *)view) setActivityIndicatorVisible:YES animated:YES];
    }
}

- (void)updateCollectionView
{
    // Subclasses may override
}

#pragma mark - VScrollPaginatorDelegate

- (void)shouldLoadNextPage
{
    if ( self.streamDataSource.isLoading ||
         self.targetStreamItem != nil )
    {
        return;
    }
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

#pragma mark - VPaginatedDataSourceDelegate

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didUpdateVisibleItemsFrom:(NSOrderedSet *)oldValue to:(NSOrderedSet *)newValue
{
    NSInteger contentSection = [self.streamDataSource sectionIndexForContent];
    [self.collectionView v_applyChangeInSection:contentSection from:oldValue to:newValue animated:YES completion:nil];
}

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didChangeStateFrom:(enum VDataSourceState)oldState to:(enum VDataSourceState)newState
{
    [self updateCollectionView];
}

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didReceiveError:(NSError *)error
{
    [self v_showErrorDefaultError];
}

@end
