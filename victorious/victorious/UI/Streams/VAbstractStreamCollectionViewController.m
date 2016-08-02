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
#import "VStreamItem+Fetcher.h"
#import "VSequence.h"
#import "VFooterActivityIndicatorView.h"
#import "VDependencyManager.h"
#import "victorious-Swift.h"

@interface VAbstractStreamCollectionViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *bottomActivityIndicator;

@property (nonatomic, strong) NSLayoutConstraint *headerYConstraint;
@property (nonatomic, readwrite) CGFloat topInset;

@property (nonatomic, assign) NSUInteger previousNumberOfRowsInStreamSection;

@property (nonatomic, strong) AppTimingStreamHelper *appTimingStreamHelper;

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

- (void)addScrollDelegate
{
}

- (void)updateNavigationItems
{
    // Nothing to do here, provided to override in subclasses
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

- (void)flashScrollIndicatorsWithDelay:(NSTimeInterval)delay
{
    __weak typeof(self) welf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       [welf.collectionView flashScrollIndicators];
                   });
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
