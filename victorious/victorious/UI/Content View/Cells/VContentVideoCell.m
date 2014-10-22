//
//  VContentVideoCell.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentVideoCell.h"

#import "VCVideoPlayerViewController.h"

@interface VContentVideoCell () <VCVideoPlayerDelegate>

@property (nonatomic, strong, readwrite) VCVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic, assign, readwrite) BOOL isPlayingAd;

@end

@implementation VContentVideoCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds));
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
// iOS 7 bug when built with 6 http://stackoverflow.com/questions/15303100/uicollectionview-cell-subviews-do-not-resize
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
// End iOS 7 bug when built with 6
    self.videoPlayerViewController = [[VCVideoPlayerViewController alloc] initWithNibName:nil
                                                                                   bundle:nil];
    self.videoPlayerViewController.delegate = self;
    self.videoPlayerViewController.view.frame = self.contentView.bounds;
    self.videoPlayerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.videoPlayerViewController.shouldContinuePlayingAfterDismissal = YES;

    [self.contentView addSubview:self.videoPlayerViewController.view];
}

- (void)dealloc
{
    [self.videoPlayerViewController disableTracking];
}

#pragma mark - Property Accessors

- (void)setViewModel:(VVideoCellViewModel *)viewModel
{
    _viewModel = viewModel;
    
    if (viewModel.adSystem == VAdSystemNone)
    {
        self.isPlayingAd = NO;
        self.videoPlayerViewController.itemURL = viewModel.itemURL;
        return;
    }
    self.isPlayingAd = YES;
    // Setup addVC
    // Add to Content view
}

#pragma mark - Public Methods

- (void)play
{
    [self.videoPlayerViewController.player play];
}

#pragma mark - VCVideoPlayerDelegate

- (void)videoPlayer:(VCVideoPlayerViewController *)videoPlayer
      didPlayToTime:(CMTime)time
{
    [self.delegate videoCell:self
               didPlayToTime:time
                   totalTime:[videoPlayer playerItemDuration]];
}

- (void)videoPlayerReadyToPlay:(VCVideoPlayerViewController *)videoPlayer
{
    [self.delegate videoCellReadyToPlay:self];
}

- (void)videoPlayerDidReachEndOfVideo:(VCVideoPlayerViewController *)videoPlayer
{
    // If videoPlayer is ad video player then swap to item video player and do not forward to our delegate
//    if (videoPlayer == self.adPlayer)
//    {
//        self.isPlayingAd = NO;
//        //Swap to content Video player
//        return;
//    }
    
    // This should only be forwarded from the content video player
    [self.delegate videoCellPlayedToEnd:self
                          withTotalTime:[videoPlayer playerItemDuration]];
}

@end
