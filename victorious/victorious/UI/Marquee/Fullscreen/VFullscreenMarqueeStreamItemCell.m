//
//  VFullscreenMarqueeStreamItemCell.m
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFullscreenMarqueeStreamItemCell.h"

// Stream Support
#import "VSequence+Fetcher.h"

// Views + Helpers
#import "VDefaultProfileButton.h"
#import "UIView+Autolayout.h"
#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"
#import "VCompatibility.h"
#import "VStreamItemPreviewView.h"

// Dependencies
#import "VDependencyManager+VBackgroundContainer.h"

#import "VMarqueeCaptionView.h"

CGFloat const kVDetailVisibilityDuration = 3.0f;
CGFloat const kVDetailHideDuration = 2.0f;
static NSTimeInterval const kVDetailHideTime = 0.2f;
static CGFloat const kVDetailBounceOffset = 36.0f;
static CGFloat const kVDetailStartOverflowOffset = 40.0f;
static NSTimeInterval const kVDetailBounceTime = 0.35f;
static CGFloat const kVCellHeightRatio = 0.884375; //from spec, 283 height for 320 width

@interface VFullscreenMarqueeStreamItemCell ()

@property (nonatomic, assign) BOOL detailsVisible;
@property (nonatomic, weak) IBOutlet UIView *detailsBackgroundView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *detailsContainerTopToStreamItemBottom;
@property (nonatomic, weak) IBOutlet VMarqueeCaptionView *marqueeCaptionView;

@property (nonatomic, strong) NSTimer *hideTimer;

@end

@implementation VFullscreenMarqueeStreamItemCell

- (void)setupWithStreamItem:(VStreamItem *)streamItem fromStreamWithStreamID:(NSString *)streamID
{
    [super setupWithStreamItem:streamItem fromStreamWithStreamID:streamID];
    
    if ( streamItem != nil )
    {
        [self.marqueeCaptionView setupWithMarqueeItem:streamItem fromStreamWithStreamID:streamID];
    }
    
    //Timer for marquee details auto-hiding
    [self setDetailsContainerVisible:YES animated:NO];
    [self restartHideTimer];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    
    if ( dependencyManager != nil )
    {
        self.marqueeCaptionView.dependencyManager = dependencyManager;
    }
}

- (void)restartHideTimer
{
    [self.hideTimer invalidate];
    self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:kVDetailVisibilityDuration
                                                      target:self
                                                    selector:@selector(hideDetailContainer)
                                                    userInfo:nil
                                                     repeats:NO];
}

#pragma mark - Detail container animation

//Selector hit by timer
- (void)hideDetailContainer
{
    [self setDetailsContainerVisible:NO animated:YES];
}

- (void)setDetailsContainerVisible:(BOOL)visible animated:(BOOL)animated
{
    if ( self.marqueeCaptionView.captionLabel.text == nil )
    {
        //Never make the details container visible if there is no caption
        visible = NO;
    }
    
    if (_detailsVisible == visible)
    {
        animated = NO;
    }
    _detailsVisible = visible;
    
    CGFloat detailsContainerHeight = CGRectGetHeight(self.detailsBackgroundView.bounds);
    
    CGFloat targetConstraintValue = visible ? - kVDetailStartOverflowOffset : - detailsContainerHeight;
    
    [self cancelDetailsAnimation];
    if ( animated )
    {
        [UIView animateKeyframesWithDuration:kVDetailBounceTime + kVDetailHideTime
                                       delay:0.0f
                                     options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                  animations:^
         {
            [UIView addKeyframeWithRelativeStartTime:0.0f
                                    relativeDuration:kVDetailBounceTime / (kVDetailBounceTime + kVDetailHideTime)
                                          animations:^
             {
                 self.detailsContainerTopToStreamItemBottom.constant = -kVDetailBounceOffset;
                 [self layoutIfNeeded];
             }];
             [UIView addKeyframeWithRelativeStartTime:kVDetailBounceTime / (kVDetailBounceTime + kVDetailHideTime)
                                     relativeDuration:kVDetailHideTime
                                           animations:^
              {
                  self.detailsContainerTopToStreamItemBottom.constant = targetConstraintValue;
                  [self layoutIfNeeded];
              }];
         }
                                  completion:nil];
    }
    else
    {
        self.detailsContainerTopToStreamItemBottom.constant = targetConstraintValue;
    }
}

- (void)cancelDetailsAnimation
{
    [((UIView *)self.detailsContainerTopToStreamItemBottom.firstItem).layer removeAllAnimations];
    [((UIView *)self.detailsContainerTopToStreamItemBottom.secondItem).layer removeAllAnimations];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = VFLOOR(width * kVCellHeightRatio);
    return CGSizeMake(width, height);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self setDetailsContainerVisible:YES animated:NO];
}

#pragma mark - VBackgroundContainer

- (UIView *)loadingBackgroundContainerView
{
    return self.previewContainer;
}

- (UIView *)backgroundContainerView
{
    return self.detailsBackgroundView;
}

@end
