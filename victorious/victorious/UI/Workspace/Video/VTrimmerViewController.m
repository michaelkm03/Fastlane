//
//  VTrimmerViewController.m
//  victorious
//
//  Created by Michael Sena on 12/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrimmerViewController.h"

#warning Remove me?
@import AVFoundation;

#import "VThumbnailCell.h"
#import "VTrimControl.h"

static NSString *const emptyCellIdentifier = @"emptyCell";

@interface VTrimmerViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *thumbnailCollecitonView;

@property (nonatomic, strong) VTrimControl *trimControl;

@property (nonatomic, strong) UIView *trimDimmingView;
@property (nonatomic, strong) NSLayoutConstraint *dimmingViewWidthConstraint;

@property (nonatomic, strong) UIView *currentPlayBackOverlayView;
@property (nonatomic, strong) NSLayoutConstraint *currentPlayBackWidthConstraint;

@property (nonatomic, assign) CMTime offsetTime;

@end

@implementation VTrimmerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(CGRectGetHeight(self.view.frame), CGRectGetHeight(self.view.frame));
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.thumbnailCollecitonView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                      collectionViewLayout:layout];
    [self.thumbnailCollecitonView registerNib:[VThumbnailCell nibForCell]
                   forCellWithReuseIdentifier:[VThumbnailCell suggestedReuseIdentifier]];
    [self.thumbnailCollecitonView registerClass:[UICollectionViewCell class]
                     forCellWithReuseIdentifier:emptyCellIdentifier];
    self.thumbnailCollecitonView.dataSource = self;
    self.thumbnailCollecitonView.delegate = self;
    self.thumbnailCollecitonView.alwaysBounceHorizontal = YES;
    self.thumbnailCollecitonView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.thumbnailCollecitonView];
    self.thumbnailCollecitonView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewMap = @{@"collectionView": self.thumbnailCollecitonView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[collectionView]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewMap]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-48-[collectionView]-30-|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewMap]];
    
    
    self.trimDimmingView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.trimDimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    self.trimDimmingView.userInteractionEnabled = NO;
    [self.view addSubview:self.trimDimmingView];
    self.trimDimmingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[trimDimmingView]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:@{@"trimDimmingView":self.trimDimmingView}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.trimDimmingView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.thumbnailCollecitonView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.trimDimmingView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.thumbnailCollecitonView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    self.dimmingViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.trimDimmingView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0f
                                                                    constant:0.0f];
    [self.view addConstraint:self.dimmingViewWidthConstraint];
    
    self.trimControl = [[VTrimControl alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(self.view.frame))];
    self.trimControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.trimControl addTarget:self
                         action:@selector(trimSelectionChanged:)
               forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.trimControl];
    viewMap = @{@"trimControl": self.trimControl};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[trimControl]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewMap]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[trimControl]-30-|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewMap]];
    
    self.currentPlayBackOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.currentPlayBackOverlayView.userInteractionEnabled = NO;
    self.currentPlayBackOverlayView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2f];
    [self.view addSubview:self.currentPlayBackOverlayView];
    self.currentPlayBackOverlayView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[overlayView]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:@{@"overlayView":self.currentPlayBackOverlayView}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.currentPlayBackOverlayView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.thumbnailCollecitonView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.currentPlayBackOverlayView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.thumbnailCollecitonView
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

#pragma mark - Property Accessors

- (void)setMaximumTrimDuration:(CMTime)maximumTrimDuration
{
    _maximumTrimDuration = maximumTrimDuration;
    self.trimControl.maxDuration = maximumTrimDuration;
    [self updateTrimControlTitleWithTime:self.trimControl.selectedDuration];
}

- (void)setMaximumEndTime:(CMTime)maximumEndTime
{
    _maximumEndTime = maximumEndTime;
    [self.thumbnailCollecitonView reloadData];
}

- (CMTimeRange)selectedTimeRange
{
    return CMTimeRangeMake([self currentTimeOffset], self.trimControl.selectedDuration);
}

- (void)setCurrentPlayTime:(CMTime)currentPlayTime
{
    _currentPlayTime = currentPlayTime;
    if (CMTimeCompare(currentPlayTime, kCMTimeZero))
    {
        Float64 progress = (CMTimeGetSeconds(currentPlayTime) - CMTimeGetSeconds([self currentTimeOffset])) / CMTimeGetSeconds(self.maximumTrimDuration);
        self.currentPlayBackWidthConstraint.constant = CGRectGetWidth(self.view.bounds) * progress;
        [self.view layoutIfNeeded];
    }
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
    
    return numberOfFrames + 1; // 1 extra for a spacer cell
//    return cgrect
//    Float64 maxTimeOverMaxTrim = CMTimeGetSeconds(self.maximumEndTime) / CMTimeGetSeconds(self.maximumTrimDuration);
//    VLog(@"Max end time: %@, Max trim duration: %@, maxTimeOverMaxTrim: %@", [NSValue valueWithCMTime:self.maximumEndTime], [NSValue valueWithCMTime:self.maximumTrimDuration], @(maxTimeOverMaxTrim));
//    return isnan(maxTimeOverMaxTrim) ? 4 : maxTimeOverMaxTrim;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfItems = [self collectionView:collectionView
                            numberOfItemsInSection:indexPath.section];
    
    if (indexPath.row == --numberOfItems)
    {
        UICollectionViewCell *emptyCell = [collectionView dequeueReusableCellWithReuseIdentifier:emptyCellIdentifier
                                                                                    forIndexPath:indexPath];
        emptyCell.backgroundColor = [UIColor clearColor];
        emptyCell.contentView.backgroundColor = [UIColor clearColor];
        return emptyCell;
    }
    
    VThumbnailCell *thumnailCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VThumbnailCell suggestedReuseIdentifier]
                                                                             forIndexPath:indexPath];
    thumnailCell.thumbnail = [UIImage imageNamed:@"bike"];
    return thumnailCell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfItems = [self collectionView:collectionView
                            numberOfItemsInSection:indexPath.section];
    
    // Empty Cell
    if (indexPath.row == --numberOfItems)
    {
        CGFloat timelinePercentOfWidth = CMTimeGetSeconds(self.maximumEndTime) / CMTimeGetSeconds(self.maximumTrimDuration);
        if (timelinePercentOfWidth < 1)
        {
            CGFloat widthForTimeline = timelinePercentOfWidth * CGRectGetWidth(collectionView.bounds);
            return CGSizeMake(CGRectGetWidth(collectionView.bounds) - widthForTimeline + [self timelineWidthPerSecond], CGRectGetHeight(collectionView.bounds));
        }
        else
        {
            return CGSizeMake(CGRectGetWidth(collectionView.bounds), CGRectGetHeight(collectionView.bounds) - [self timelineWidthPerSecond]);
        }
    }
    // Frames
    return CGSizeMake(CGRectGetHeight(collectionView.frame), CGRectGetHeight(collectionView.frame));
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateAndNotify];
}

#pragma mark - Private Methods

- (void)updateAndNotify
{
    [self updateTrimControlTitleWithTime:self.trimControl.selectedDuration];
    
//    VLog(@"Content Offset: %@, Time offset: %@", NSStringFromCGPoint(self.thumbnailCollecitonView.contentOffset), @(self.thumbnailCollecitonView.contentOffset.x / [self timelineWidthPerSecond]));
    VLog(@"Selected time range: %@", [NSValue valueWithCMTimeRange:[self selectedTimeRange]]);
    
    if ([self.delegate respondsToSelector:@selector(trimmerViewControllerDidUpdateSelectedTimeRange:trimmerViewController:)])
    {
        [self.delegate trimmerViewControllerDidUpdateSelectedTimeRange:[self selectedTimeRange]
                                                 trimmerViewController:self];
    }
    Float64 progress = CMTimeGetSeconds(self.trimControl.selectedDuration) / CMTimeGetSeconds(self.trimControl.maxDuration);
    self.dimmingViewWidthConstraint.constant = CGRectGetWidth(self.view.bounds) - (CGRectGetWidth(self.view.bounds) * progress);
    [self.view layoutIfNeeded];
}

- (void)updateTrimControlTitleWithTime:(CMTime)time
{
    NSString *title = [NSString stringWithFormat:@"%@ secs", [NSString stringWithFormat:@"%.0f", CMTimeGetSeconds(time)]];
    self.trimControl.attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                                  attributes:nil];
}

- (CGFloat)timelineWidthPerSecond
{
    return CGRectGetWidth(self.thumbnailCollecitonView.bounds) / CMTimeGetSeconds(self.maximumTrimDuration);
}

- (CGFloat)timelineWidthForFullTrack
{
    return [self timelineWidthPerSecond] * CMTimeGetSeconds(self.maximumEndTime);
}

- (CMTime)currentTimeOffset
{
    return CMTimeMake(self.thumbnailCollecitonView.contentOffset.x, [self timelineWidthPerSecond]);
}

@end
