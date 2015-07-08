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

// Dependencies
#import "VDependencyManager.h"

static NSString *const emptyCellIdentifier = @"emptyCell";

static const CGFloat kMinimumThumbnailHeight = 70.0f; //The minimum height for the thumbnail preview collection view
static const CGFloat kCollectionViewRightInset = 250.0f; //The right-inset of the thumbnail collectionview

@interface VTrimmerViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *thumbnailCollectionView;

@property (nonatomic, strong) VTrimControl *trimControl;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NSLayoutConstraint *dimmingViewWidthConstraint;

@property (nonatomic, strong) UIView *currentPlayBackOverlayView;
@property (nonatomic, strong) NSLayoutConstraint *currentPlayBackWidthConstraint;
@property (nonatomic, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VTrimmerFlowLayout *trimmerFlowLayout;

@property (nonatomic, assign) NSInteger numberOfFrames;

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

    [self prepareThumbnailCollectionViewAndTitleLabel];
    [self preparePlaybackOverlay];
    [self prepareTrimControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerSupplementaryViews];
    self.titleLabel.alpha = 1.0f;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:1.5f
                          delay:2.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:kNilOptions
                     animations:^
     {
         self.titleLabel.alpha = 0.0f;
     }
                     completion:nil];
}

#pragma mark - Property Accessors

- (void)setMaximumTrimDuration:(CMTime)maximumTrimDuration
{
    _maximumTrimDuration = maximumTrimDuration;
    self.trimControl.maxDuration = maximumTrimDuration;
    [self updateTrimControlTitleWithTime:self.trimControl.selectedDuration];
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
    CMTime timeScrolled = CMTimeSubtract([self maximumEndTime], [self currentTimeOffset]);
    CMTime upperRange = CMTIME_COMPARE_INLINE(timeScrolled, <, self.trimControl.selectedDuration) ? timeScrolled : self.trimControl.selectedDuration;
    return CMTimeRangeMake([self currentTimeOffset], upperRange);
}

- (void)setCurrentPlayTime:(CMTime)currentPlayTime
{
    _currentPlayTime = currentPlayTime;
    if (CMTIME_COMPARE_INLINE(currentPlayTime, >, kCMTimeZero))
    {
        Float64 progress = (CMTimeGetSeconds(currentPlayTime) - CMTimeGetSeconds([self currentTimeOffset])) / CMTimeGetSeconds(self.maximumTrimDuration);
        CGFloat playbackOverlayWidth = (CGRectGetWidth(self.view.bounds) * progress) - (CGRectGetWidth(self.trimControl.trimThumbBody.frame)/2);
        self.currentPlayBackWidthConstraint.constant = ((playbackOverlayWidth >= 0) && (playbackOverlayWidth <= CGRectGetMaxX(self.trimControl.trimThumbBody.frame))) ? playbackOverlayWidth  : 0.0f;
        [self.view layoutIfNeeded];
    }
}

- (void)setThumbnailDataSource:(id<VTrimmerThumbnailDataSource>)thumbnailDataSource
{
    _thumbnailDataSource = thumbnailDataSource;
    
    [self.thumbnailCollectionView reloadData];
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.titleLabel.text = NSLocalizedString(title, @"");
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
        numberOfFrames++;
        neededTimeLineWidth = neededTimeLineWidth - frameWidth;
    }
    self.numberOfFrames = numberOfFrames - 1;
    return numberOfFrames; // 1 extra for a spacer cell
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
    CGSize size;
    NSInteger numberOfItems = [self collectionView:collectionView
                            numberOfItemsInSection:indexPath.section];
    
    // Empty Cell
    if (indexPath.row == numberOfItems - 1)
    {
        return CGSizeMake(0, 0);
    }
    
    [self.currentPlayBackOverlayView updateConstraintsIfNeeded];

    CGFloat width = MIN(kMaximumTrimHeight, CGRectGetHeight(self.currentPlayBackOverlayView.frame));
    size = CGSizeMake(width, width);
    return size;
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
    if (isnan(CMTimeGetSeconds(self.trimControl.maxDuration)))
    {
        return;
    }
    [self updateTrimControlTitleWithTime:self.trimControl.selectedDuration];
    
    if ([self.delegate respondsToSelector:@selector(trimmerViewController:didUpdateSelectedTimeRange:)])
    {
        [self.delegate trimmerViewController:self
                  didUpdateSelectedTimeRange:[self selectedTimeRange]];
    }
    Float64 progress = CMTimeGetSeconds(self.trimControl.selectedDuration) / CMTimeGetSeconds(self.maxDuration);
    self.dimmingViewWidthConstraint.constant = CGRectGetWidth(self.view.bounds) - (CGRectGetWidth(self.view.bounds) * progress);
   [self.view layoutIfNeeded];
    
    CGFloat progressOfThumbs = 1.0f - (self.thumbnailCollectionView.contentOffset.x / (CGRectGetWidth(self.thumbnailCollectionView.bounds)));
    
    if (progress > progressOfThumbs)
    {
        self.trimControl.trimThumbBody.center = CGPointMake(progressOfThumbs*CGRectGetWidth(self.thumbnailCollectionView.bounds), self.trimControl.trimThumbBody.center.y);
    }
    
    for (UICollectionViewCell *cell in [self.thumbnailCollectionView visibleCells])
    {
        NSIndexPath *indexPath = [self.thumbnailCollectionView indexPathForCell:cell];
        NSInteger lastIndex = [indexPath indexAtPosition:[indexPath length] - 1];
        lastIndex = lastIndex + 1;
        if (lastIndex == self.numberOfFrames)
        {
            CGRect frame;
            frame.size = cell.frame.size;
            frame.origin = CGPointMake(cell.frame.origin.x - self.thumbnailCollectionView.contentOffset.x, cell.frame.origin.y + self.thumbnailCollectionView.contentOffset.y);
            
            if (CGRectGetMaxX(frame) < CGRectGetMaxX(self.trimControl.trimThumbBody.frame))
            {
                self.trimControl.trimThumbBody.center = CGPointMake(CGRectGetMaxX(frame) - (CGRectGetWidth(self.trimControl.trimThumbBody.frame)/2), self.trimControl.trimThumbBody.center.y);
            }
        }
    }
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
    return [self timelineWidthPerSecond] * CMTimeGetSeconds(self.maximumEndTime);
}

- (CMTime)currentTimeOffset
{
    return CMTimeMake(self.thumbnailCollectionView.contentOffset.x, [self timelineWidthPerSecond]);
}

#pragma mark View Hierarcy Setup

- (void)prepareThumbnailCollectionViewAndTitleLabel
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

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.text = NSLocalizedString(self.title, @"");
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading2FontKey];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.titleLabel];

    NSDictionary *viewMap = @{
                              @"collectionView": self.thumbnailCollectionView,
                              @"titleLabel": self.titleLabel
                              };
    CGFloat topPadding = [VTrimControl topPadding];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[collectionView]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewMap]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[titleLabel]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewMap]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-kTimelineTopPadding-[collectionView(kMinimumThumbnailHeight@748,>=kMinimumThumbnailHeight@749)][titleLabel(<=kMaximumLabelHeight)]|"
                                                                      options:kNilOptions
                                                                      metrics:@{
                                                                                @"kTimelineTopPadding":@(topPadding),
                                                                                @"kMinimumThumbnailHeight":@(kMinimumThumbnailHeight),
                                                                                @"kMaximumLabelHeight":@(topPadding)
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
    CGRect frame = CGRectMake(0, 0, 123.6f, 55.0f);
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
    [self.thumbnailCollectionView registerNib:[VTimeMarkView nibForCell] forSupplementaryViewOfKind:TimemarkViewKind withReuseIdentifier:[VTimeMarkView cellIdentifier]];
    [self.thumbnailCollectionView registerNib:[VHashmarkView nibForCell] forSupplementaryViewOfKind:HashmarkViewKind withReuseIdentifier:[VHashmarkView cellIdentifier]];
}

@end
