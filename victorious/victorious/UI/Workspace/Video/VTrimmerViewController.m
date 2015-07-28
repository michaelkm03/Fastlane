//
//  VTrimmerViewController.m
//  victorious
//
//  Created by Michael Sena on 12/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrimmerViewController.h"

// Frameworks
@import AVFoundation;

// Views
#import "VThumbnailCell.h"
#import "VTrimControl.h"
#import "VHashmarkView.h"
#import "VTimeMarkView.h"
#import "VTrimmerFlowLayout.h"
#import "UIView+AutoLayout.h"

// Dependencies
#import "VDependencyManager.h"

static NSString *const emptyCellIdentifier = @"emptyCell";

static const CGFloat kCollectionViewRightInset = 250.0f; //The right-inset of the thumbnail collectionview

@interface VTrimmerViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *thumbnailCollectionView;

@property (nonatomic, strong) VTrimControl *trimControl;

@property (nonatomic, strong) NSLayoutConstraint *dimmingViewWidthConstraint;

@property (nonatomic, strong) UIView *currentPlayBackOverlayView;
@property (nonatomic, strong) NSLayoutConstraint *currentPlayBackWidthConstraint;
@property (nonatomic, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VTrimmerFlowLayout *trimmerFlowLayout;

@property (nonatomic, assign) NSInteger numberOfFrames;
@property (nonatomic, assign) CGFloat lastFrameWidth;

@end

@implementation VTrimmerViewController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self prepareThumbnailCollectionView];
    [self preparePlaybackOverlay];
    [self prepareTrimControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerSupplementaryViews];
}

#pragma mark - Property Accessors

- (void)setMaximumTrimDuration:(CMTime)maximumTrimDuration
{
    _maximumTrimDuration = maximumTrimDuration;
    [self.thumbnailCollectionView.collectionViewLayout invalidateLayout];
}

- (void)setMaximumEndTime:(CMTime)maximumEndTime
{
    _maximumEndTime = maximumEndTime;
    
    if (CMTIME_COMPARE_INLINE(maximumEndTime, <, self.maximumTrimDuration))
    {
        self.maximumTrimDuration = maximumEndTime;
        if ([self.delegate respondsToSelector:@selector(trimmerViewController:didUpdateSelectedTimeRange:)])
        {
            [self.delegate trimmerViewController:self
                      didUpdateSelectedTimeRange:self.selectedTimeRange];
        }
    }
    [self.thumbnailCollectionView.collectionViewLayout invalidateLayout];
}

- (CMTimeRange)selectedTimeRange
{
    CMTime currentTime = [self currentTimeOffset];
    CMTime selectedDuration = [self selectedDuration];
    CMTime timeScrolled = CMTimeSubtract([self maximumEndTime], currentTime);
    CMTime upperRange = CMTIME_COMPARE_INLINE(timeScrolled, <, selectedDuration) ? timeScrolled : selectedDuration;
    return CMTimeRangeMake(currentTime, upperRange);
}

- (void)setCurrentPlayTime:(CMTime)currentPlayTime
{
    _currentPlayTime = currentPlayTime;
    if (CMTIME_COMPARE_INLINE(currentPlayTime, >, kCMTimeZero))
    {
        Float64 progress = CMTimeGetSeconds(CMTimeSubtract(currentPlayTime, [self currentTimeOffset])) / CMTimeGetSeconds([self selectedDuration]);
        CGFloat maxWidth = CGRectGetMaxX(self.trimControl.trimThumbBody.frame);
        CGFloat playbackOverlayWidth = (maxWidth * progress);
        self.currentPlayBackWidthConstraint.constant = ((playbackOverlayWidth >= 0) && (playbackOverlayWidth <= maxWidth)) ? playbackOverlayWidth  : 0.0f;
        [self.view setNeedsLayout];
    }
}

- (void)setThumbnailDataSource:(id<VTrimmerThumbnailDataSource>)thumbnailDataSource
{
    _thumbnailDataSource = thumbnailDataSource;
    
    [self.thumbnailCollectionView reloadData];
}

- (BOOL)isInteracting
{
    return (self.thumbnailCollectionView.dragging || self.thumbnailCollectionView.decelerating || self.trimControl.isTracking);
}

#pragma mark - Target/Action

- (void)trimSelectionChanged:(VTrimControl *)trimControl
{
    [self updateAndNotify];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    CGFloat neededTimeLineWidth = [self timelineWidthForFullTrack];
    
    CGFloat frameWidth = CGRectGetHeight(collectionView.bounds);
    neededTimeLineWidth = neededTimeLineWidth - frameWidth;
    NSInteger numberOfFrames = 1;
    
    while (neededTimeLineWidth > 0)
    {
        self.lastFrameWidth = neededTimeLineWidth;
        numberOfFrames++;
        neededTimeLineWidth = neededTimeLineWidth - frameWidth;
    }
    self.numberOfFrames = numberOfFrames;
    return numberOfFrames;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    VThumbnailCell *thumnailCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VThumbnailCell suggestedReuseIdentifier]
                                                                             forIndexPath:indexPath];
    CGPoint center = [self.thumbnailCollectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath].center;
    CGFloat percentThrough = center.x / [self timelineWidthForFullTrack];
    CMTime timeForCell = CMTimeMake(self.maximumEndTime.value * percentThrough, self.maximumEndTime.timescale);
    thumnailCell.valueForThumbnail = [NSValue valueWithCMTime:timeForCell];
    __weak VThumbnailCell *weakCell = thumnailCell;
    [self.thumbnailDataSource trimmerViewController:self
                                   thumbnailForTime:timeForCell
                                        withSuccess:^(UIImage *thumbnail, CMTime timeForImage, id generatingDataSource)
     {
         CMTime timeValue = [weakCell.valueForThumbnail CMTimeValue];
         if (CMTIME_COMPARE_INLINE(timeValue, ==, timeForImage))
         {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                weakCell.thumbnail = thumbnail;
                                [weakCell.activityIndicator stopAnimating];
                            });
         }
     }
     withFailure:^(NSError *error)
     {
         [weakCell.activityIndicator stopAnimating];
         weakCell.frame = CGRectZero;
     }];
    thumnailCell.clipsToBounds = YES;
    return thumnailCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == HashmarkViewKind)
    {
        reusableview = [VHashmarkView collectionReusableViewForCollectionView:collectionView forIndexPath:indexPath withKind:kind];
    }
    if (kind == TimemarkViewKind)
    {
        CGPoint center = [self.thumbnailCollectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:TimemarkViewKind atIndexPath:indexPath].center;
        CGFloat percentThrough = center.x / [self timelineWidthForFullTrack];
        CMTime timeForCell = CMTimeMake(self.maximumEndTime.value * percentThrough, self.maximumEndTime.timescale);
        Float64 time = CMTimeGetSeconds(timeForCell);
        
        VTimeMarkView *timeMarkView = [VTimeMarkView collectionReusableViewForCollectionView:collectionView forIndexPath:indexPath withKind:kind];
        timeMarkView.timeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)time/60, (int)time%60];
        timeMarkView.timeLabel.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
        reusableview = timeMarkView;
    }
    
    return reusableview;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.currentPlayBackOverlayView updateConstraintsIfNeeded];

    CGFloat height = CGRectGetHeight(collectionView.bounds);
    CGFloat width = height;
    if ( indexPath.row == [collectionView numberOfItemsInSection:indexPath.section] - 1 )
    {
        width = self.lastFrameWidth;
    }
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.isDecelerating)
    {
        if ([self.delegate respondsToSelector:@selector(trimmerViewControllerEndedSeeking:)])
        {
            [self.delegate trimmerViewControllerEndedSeeking:self];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateAndNotify];
    
    if (!CMTimeRangeContainsTime(self.selectedTimeRange, self.currentPlayTime))
    {
        if ([self.delegate respondsToSelector:@selector(trimmerViewControllerBeganSeeking:toTime:)])
        {
            [self.delegate trimmerViewControllerBeganSeeking:self
                                                      toTime:self.selectedTimeRange.start];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        if ([self.delegate respondsToSelector:@selector(trimmerViewControllerEndedSeeking:)])
        {
            [self.delegate trimmerViewControllerEndedSeeking:self];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(trimmerViewControllerEndedSeeking:)])
    {
        [self.delegate trimmerViewControllerEndedSeeking:self];
    }
}

#pragma mark - Private Methods

- (void)updateAndNotify
{
    if (isnan(CMTimeGetSeconds(self.maximumTrimDuration)))
    {
        return;
    }
    [self updateTrimControlTitleWithTime:[self selectedDuration]];
    
    if ([self.delegate respondsToSelector:@selector(trimmerViewController:didUpdateSelectedTimeRange:)])
    {
        [self.delegate trimmerViewController:self
                  didUpdateSelectedTimeRange:[self selectedTimeRange]];
    }
    CGFloat trimEnd = CGRectGetMaxX(self.trimControl.trimThumbBody.frame);
    Float64 progress = trimEnd / [self visibleThumbnailCollectionViewWidth];
    
    CGFloat width = CGRectGetWidth(self.view.bounds) - (CGRectGetWidth(self.view.bounds) * progress);
    if ( self.dimmingViewWidthConstraint.constant != width )
    {
        self.dimmingViewWidthConstraint.constant = CGRectGetWidth(self.view.bounds) - (CGRectGetWidth(self.view.bounds) * progress);
        [self.view setNeedsLayout];
    }
    
    if (progress >= 1.0f && self.thumbnailCollectionView.contentSize.width != 0)
    {
        self.trimControl.trimThumbBody.center = CGPointMake([self visibleThumbnailCollectionViewWidth] - CGRectGetWidth(self.trimControl.trimThumbBody.bounds) / 2, self.trimControl.trimThumbBody.center.y);
    }
}

- (CGFloat)visibleThumbnailCollectionViewWidth
{
    return MIN(self.thumbnailCollectionView.contentSize.width - self.thumbnailCollectionView.contentOffset.x, CGRectGetWidth(self.thumbnailCollectionView.bounds));
}

- (CMTime)selectedDuration
{
    CGFloat percentSelected = CGRectGetMaxX(self.trimControl.trimThumbBody.frame) / self.thumbnailCollectionView.contentSize.width;
    return CMTimeMultiplyByFloat64(self.maximumTrimDuration, percentSelected);
}

- (void)updateTrimControlTitleWithTime:(CMTime)time
{
    NSString *title = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.2f", CMTimeGetSeconds(time)]];
    self.trimControl.attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                                       attributes:@{NSFontAttributeName: [[_dependencyManager fontForKey:VDependencyManagerLabel3FontKey] fontWithSize:16.0f]}];
}

- (CGFloat)timelineWidthPerSecond
{
    return CGRectGetWidth(self.thumbnailCollectionView.bounds) / CMTimeGetSeconds(self.maximumTrimDuration);
}

- (CGFloat)timelineWidthForFullTrack
{
    CGFloat duration =  CMTimeGetSeconds(self.maximumEndTime) - CMTimeGetSeconds(self.minimumStartTime);
    return [self timelineWidthPerSecond] * duration;
}

- (CMTime)currentTimeOffset
{
    return CMTimeMake(self.thumbnailCollectionView.contentOffset.x, [self timelineWidthPerSecond]);
}

#pragma mark View Hierarcy Setup

- (void)prepareThumbnailCollectionView
{
    self.trimmerFlowLayout = [[VTrimmerFlowLayout alloc] init];
    CGRect bounds = self.view.bounds;
    self.trimmerFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.thumbnailCollectionView = [[UICollectionView alloc] initWithFrame:bounds
                                                      collectionViewLayout:self.trimmerFlowLayout];
    [self.thumbnailCollectionView registerNib:[VThumbnailCell nibForCell]
                   forCellWithReuseIdentifier:[VThumbnailCell suggestedReuseIdentifier]];
    [self.thumbnailCollectionView registerClass:[UICollectionViewCell class]
                     forCellWithReuseIdentifier:emptyCellIdentifier];
    self.thumbnailCollectionView.dataSource = self;
    self.thumbnailCollectionView.delegate = self;
    self.thumbnailCollectionView.alwaysBounceHorizontal = NO;
    self.thumbnailCollectionView.bounces = NO;
    self.thumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.thumbnailCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.thumbnailCollectionView.clipsToBounds = NO;
    self.thumbnailCollectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, kCollectionViewRightInset);
    
    [self.view addSubview:self.thumbnailCollectionView];
    
    NSDictionary *viewMap = @{
                              @"collectionView": self.thumbnailCollectionView,
                              };
    CGFloat topPadding = VTrimmerTopPadding;
    CGFloat bottomPadding = topPadding / 2;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[collectionView]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewMap]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(timeLinePadding)-[collectionView]-(bottomPadding)-|"
                                                                      options:kNilOptions
                                                                      metrics:@{
                                                                                @"timeLinePadding":@(topPadding),
                                                                                @"bottomPadding":@(bottomPadding)
                                                                                }
                                                                        views:viewMap]];
}

- (void)prepareTrimControl
{
    self.trimControl = [[VTrimControl alloc] initWithFrame:CGRectZero];
    self.trimControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.trimControl addTarget:self
                         action:@selector(trimSelectionChanged:)
               forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.trimControl];
    
    NSDictionary *viewMap = @{@"trimControl": self.trimControl};

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[trimControl]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewMap]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.trimControl
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.trimControl
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.thumbnailCollectionView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:0.0f]];
}

- (void)preparePlaybackOverlay
{
    CGRect frame = CGRectMake(0, 0, 123.0f, 55.0f);
    self.currentPlayBackOverlayView = [[UIView alloc] initWithFrame:frame];
    self.currentPlayBackOverlayView.userInteractionEnabled = NO;
    
    self.currentPlayBackOverlayView.backgroundColor = [UIColor colorWithRed:237.0f/255.0f green:28.0f/255.0f blue:36.0f/255.0f alpha:0.3f];
    [self.view addSubview:self.currentPlayBackOverlayView];
    self.currentPlayBackOverlayView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[overlayView]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:@{@"overlayView":self.currentPlayBackOverlayView}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.currentPlayBackOverlayView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.thumbnailCollectionView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.currentPlayBackOverlayView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.thumbnailCollectionView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    self.currentPlayBackWidthConstraint = [NSLayoutConstraint constraintWithItem:self.currentPlayBackOverlayView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0f
                                                                        constant:0.0f];
    [self.view addConstraint:self.currentPlayBackWidthConstraint];
}

- (void)registerSupplementaryViews
{
    [self.thumbnailCollectionView registerNib:[VTimeMarkView nibForCell] forSupplementaryViewOfKind:TimemarkViewKind withReuseIdentifier:[VTimeMarkView suggestedReuseIdentifier]];
    [self.thumbnailCollectionView registerNib:[VHashmarkView nibForCell] forSupplementaryViewOfKind:HashmarkViewKind withReuseIdentifier:[VHashmarkView suggestedReuseIdentifier]];
}

@end
