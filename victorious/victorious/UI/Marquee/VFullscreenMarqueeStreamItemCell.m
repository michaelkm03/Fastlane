//
//  VFullscreenMarqueeStreamItemCell.m
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFullscreenMarqueeStreamItemCell.h"

// Stream Support
#import "VStreamItem+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VUser.h"

#import "VStreamWebViewController.h"

// Views + Helpers
#import "VDefaultProfileButton.h"
#import "UIView+Autolayout.h"
#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"
#import "VCompatibility.h"

// Dependencies
#import "VDependencyManager.h"

CGFloat const kVDetailVisibilityDuration = 3.0f;
CGFloat const kVDetailHideDuration = 2.0f;
static NSTimeInterval const kVDetailHideTime = 0.2f;
static CGFloat const kVDetailBounceHeight = 4.0f;
static NSTimeInterval const kVDetailBounceTime = 0.35f;
static CGFloat const kVCellHeightRatio = 0.884375; //from spec, 283 height for 320 width
static NSString * const kVOrIconKey = @"orIcon";

@interface VFullscreenMarqueeStreamItemCell ()

@property (nonatomic, assign) BOOL detailsVisible;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIView *loadingBackgroundContainer;
@property (nonatomic, weak) IBOutlet UIView *detailsContainer;
@property (nonatomic, weak) IBOutlet UIView *detailsContainerBackdrop;
@property (nonatomic, weak) IBOutlet UIView *detailsBackgroundView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *detailsContainerTopToStreamItemBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelTopLayoutConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelBottomLayoutConstraint;

@property (nonatomic, strong) NSTimer *hideTimer;

@end

@implementation VFullscreenMarqueeStreamItemCell

- (void)setStreamItem:(VStreamItem *)streamItem
{
    [super setStreamItem:streamItem];
    
    self.nameLabel.text = streamItem.name;

    NSURL *previewImageUrl = [NSURL URLWithString: [streamItem.previewImagePaths firstObject]];
    [self.previewImageView fadeInImageAtURL:previewImageUrl
                           placeholderImage:nil];

    //Timer for marquee details auto-hiding
    [self setDetailsContainerVisible:YES animated:NO];
    [self restartHideTimer];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    
    if ( dependencyManager != nil )
    {
        self.detailsContainerBackdrop.backgroundColor = [dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
        self.nameLabel.textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        self.nameLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
        UIImage *orIcon = [dependencyManager imageForKey:kVOrIconKey];
        self.pollOrImageView.image = orIcon;
        
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
    if (_detailsVisible == visible)
    {
        return;
    }
    _detailsVisible = visible;
    
    CGFloat detailsContainerHeight = CGRectGetHeight(self.detailsContainer.bounds);
    
    CGFloat targetConstraintValue = visible ? -detailsContainerHeight : detailsContainerHeight;
    
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
                 self.detailsContainerTopToStreamItemBottom.constant = -detailsContainerHeight -kVDetailBounceHeight;
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
    return self.loadingBackgroundContainer;
}

@end
