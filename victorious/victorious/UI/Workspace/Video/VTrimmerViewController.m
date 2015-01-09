//
//  VTrimmerViewController.m
//  victorious
//
//  Created by Michael Sena on 12/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrimmerViewController.h"

#import "VThumbnailCell.h"
#import "VTrimControl.h"

@interface VTrimmerViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *thumbnailCollecitonView;

@property (nonatomic, strong) VTrimControl *trimControl;

@property (nonatomic, strong) UIView *currentPlayBackOverlayView;
@property (nonatomic, strong) NSLayoutConstraint *currentPlayBackWidthConstraint;

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
    self.thumbnailCollecitonView.dataSource = self;
    self.thumbnailCollecitonView.delegate = self;
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
}

- (void)setMaximumEndTime:(CMTime)maximumEndTime
{
    _maximumEndTime = maximumEndTime;
}

- (CMTimeRange)selectedTimeRange
{
    return CMTimeRangeMake(self.minimumStartTime, self.trimControl.selectedDuration);
}

- (void)setCurrentPlayTime:(CMTime)currentPlayTime
{
    _currentPlayTime = currentPlayTime;
    if (CMTimeCompare(currentPlayTime, kCMTimeZero))
    {
        Float64 progress = CMTimeGetSeconds(currentPlayTime) / CMTimeGetSeconds(self.maximumTrimDuration);
        self.currentPlayBackWidthConstraint.constant = CGRectGetWidth(self.view.bounds) * progress;
        [self.view layoutIfNeeded];
    }
}

#pragma mark - Target/Action

- (void)trimSelectionChanged:(VTrimControl *)trimControl
{
    trimControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ secs", [NSString stringWithFormat:@"%.0f", CMTimeGetSeconds(trimControl.selectedDuration)]]
                                                                  attributes:nil];
    if ([self.delegate respondsToSelector:@selector(trimmerViewControllerDidUpdateSelectedTimeRange:trimmerViewController:)])
    {
        [self.delegate trimmerViewControllerDidUpdateSelectedTimeRange:[self selectedTimeRange]
                                                 trimmerViewController:self];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    NSInteger visibleCells = CGRectGetWidth(collectionView.bounds) / CGRectGetHeight(collectionView.bounds);
    return visibleCells;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
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
    
}

@end
