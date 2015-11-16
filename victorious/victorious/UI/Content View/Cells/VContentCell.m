//
//  VContentCell.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentCell.h"
#import "UIView+Autolayout.h"
#import "VAdVideoPlayerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "VTimerManager.h"
#import "victorious-Swift.h"
#import "VSequencePreviewView.h"

static const NSTimeInterval kAdTimeoutTimeInterval = 3.0;

@interface VContentCell () <VEndCardViewControllerDelegate, VAdVideoPlayerViewControllerDelegate, VContentPreviewViewReceiver>

@property (nonatomic, assign) BOOL isPreparedForDismissal;
@property (nonatomic, assign) BOOL shrinkingDisabled;
@property (nonatomic, strong) UIView *adContainer;
@property (nonatomic, strong) UIView *shrinkingContentView;
@property (nonatomic, strong) VEndCardViewController *endCardViewController;
@property (nonatomic, strong) VTimerManager *adTimeoutTimer;
@property (nonatomic, strong, readwrite) VAdVideoPlayerViewController *adVideoPlayerViewController;
@property (nonatomic, weak) UIImageView *animationImageView;
@property (nonatomic, weak, readwrite) VSequencePreviewView *sequencePreviewView;
@property (nonatomic, weak) id<VVideoPlayer> videoPlayer;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation VContentCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds));
}

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.activityIndicatorView];
    [self v_addCenterToParentContraintsToSubview:self.activityIndicatorView];
    self.activityIndicatorView.hidesWhenStopped = YES;
    [self.activityIndicatorView stopAnimating];
    
    UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    animationImageView.backgroundColor = [UIColor clearColor];
    animationImageView.userInteractionEnabled = NO;
    self.animationImageView = animationImageView;
    [self.contentView addSubview:animationImageView];
    
    // Set some initial/default values
    self.maxSize = self.frame.size;
    self.minSize = CGSizeMake( self.frame.size.width, 0.0f );
    
    self.repeatCount = 1;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.shrinkingContentView = [[UIView alloc] initWithFrame:self.bounds];
    self.shrinkingContentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.shrinkingContentView];
    [self.shrinkingContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.shrinkingContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shrinkingContentView
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1.0
                                                                           constant:CGRectGetHeight(self.shrinkingContentView.frame)]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shrinkingContentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:@{ @"view" : self.shrinkingContentView }]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.isPreparedForDismissal = NO;
}

#pragma mark - Shrinking Layout

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    [self updateShrinkingView];
}

- (void)updateShrinkingView
{
    if ( self.shrinkingDisabled )
    {
        self.shrinkingContentView.transform = CGAffineTransformIdentity;
    }
    else
    {
        CGFloat scale = CGRectGetHeight(self.contentView.bounds) / CGRectGetWidth(self.contentView.bounds);
        self.shrinkingContentView.transform = CGAffineTransformMakeScale( scale, scale );
    }
}

#pragma mark - Rotation

- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.endCardViewController handleRotationToInterfaceOrientation:toInterfaceOrientation];
    self.shrinkingDisabled = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    [self.shrinkingContentView layoutIfNeeded];
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView bringSubviewToFront:self.animationImageView];
    [self updateShrinkingView];
}

#pragma mark - VContentPreviewViewReceiver

- (UIView *)getTargetSuperview
{
    return self.shrinkingContentView;
}

- (void)setPreviewView:(VSequencePreviewView *)previewView
{
    self.sequencePreviewView = previewView;
}

- (void)setVideoPlayer:(id<VVideoPlayer>)videoPlayer
{
    _videoPlayer = videoPlayer;
}

- (void)prepareForDismissal
{
    self.isPreparedForDismissal = YES;
    [self resumeContentPlaybackAnimated:NO];
    [self hideEndCard:YES];
}

#pragma mark - End Card

- (BOOL)isEndCardShowing
{
    return self.endCardViewController != nil && [self.contentView.subviews containsObject:self.endCardViewController.view];
}

- (void)disableEndcardAutoplay
{
    [self.endCardViewController disableAutoplay];
}

- (void)showEndCardWithViewModel:(VEndCardModel *)model
{
    if ( self.endCardViewController == nil )
    {
        self.endCardViewController = [VEndCardViewController newWithDependencyManager:model.dependencyManager
                                                                                model:model
                                                                        minViewHeight:self.minSize.height
                                                                        maxViewHeight:self.maxSize.height];
        self.endCardViewController.delegate = self;
    }
    
    [self.contentView addSubview:self.endCardViewController.view];
    self.endCardViewController.view.frame = self.contentView.bounds;
    [self.contentView v_addFitToParentConstraintsToSubview:self.endCardViewController.view];
    
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self.endCardViewController handleRotationToInterfaceOrientation:currentOrientation];
    [self.endCardViewController transitionIn];
}

- (void)hideEndCard
{
    [self hideEndCard:NO];
}

- (void)hideEndCard:(BOOL)cleanup
{
    if ( self.endCardViewController != nil )
    {
        [self.endCardViewController.view removeFromSuperview];
        if ( cleanup )
        {
            self.endCardViewController = nil;
        }
    }
}

- (void)resumeContentPlaybackAnimated:(BOOL)animated
{
    [self.activityIndicatorView stopAnimating];
    
    [self.adTimeoutTimer invalidate];
    self.adTimeoutTimer = nil;
    
    [self.videoPlayer play];
    self.sequencePreviewView.hidden = NO;
    [self layoutIfNeeded];
    
    [self.sequencePreviewView.layer removeAllAnimations];
    [self.adVideoPlayerViewController.view.layer removeAllAnimations];
    
    void (^animations)() = ^
    {
        self.sequencePreviewView.alpha = 1.0f;
        self.adVideoPlayerViewController.view.alpha = 0.0f;
        self.backgroundColor = [UIColor clearColor];
    };
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        self.adVideoPlayerViewController.delegate = nil;
        [self.adVideoPlayerViewController.view removeFromSuperview];
        self.adVideoPlayerViewController = nil;
    };
    
    if ( animated )
    {
        [self.sequencePreviewView.layer removeAllAnimations];
        [self.adVideoPlayerViewController.view.layer removeAllAnimations];
        [UIView animateWithDuration:0.5f animations:animations completion:completion];
    }
    else
    {
        animations();
        completion(YES);
    }
}

- (BOOL)isPlayingAd
{
    return self.adVideoPlayerViewController != nil;
}

#pragma mark - VEndCardViewControllerDelegate

- (void)replaySelectedFromEndCard:(VEndCardViewController *)endCardViewController
{
    [self.endCardDelegate replaySelectedFromEndCard:endCardViewController];
}

- (void)nextSelectedFromEndCard:(VEndCardViewController *)endCardViewController
{
    [self.endCardDelegate nextSelectedFromEndCard:endCardViewController];
}

- (void)actionCellSelected:(VEndCardActionCell *)actionCell atIndex:(NSUInteger)index
{
    [self.endCardDelegate actionCellSelected:actionCell atIndex:index];
}

#pragma mark  Ad Video Player

- (void)playAd:(VMonetizationPartner)monetizationPartner details:(NSArray *)details
{
    if ( self.isPreparedForDismissal || self.isPlayingAd )
    {
        return;
    }
    
    self.backgroundColor = [UIColor blackColor];
    self.adVideoPlayerViewController = [[VAdVideoPlayerViewController alloc] initWithMonetizationPartner:monetizationPartner
                                                                                                 details:details];
    self.adVideoPlayerViewController.delegate = self;
    self.adVideoPlayerViewController.view.frame = self.shrinkingContentView.bounds;
    self.adVideoPlayerViewController.view.alpha = 0.0f;
    [self.shrinkingContentView addSubview:self.adVideoPlayerViewController.view];
    [self.shrinkingContentView v_addFitToParentConstraintsToSubview:self.adVideoPlayerViewController.view];
    [self.activityIndicatorView startAnimating];
    [self.adVideoPlayerViewController start];
    
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.5f animations:^
     {
         if ( !self.isPreparedForDismissal )
         {
             self.sequencePreviewView.alpha = 0.0f;
             self.adVideoPlayerViewController.view.alpha = 1.0f;
         }
     }
                     completion:^(BOOL finished)
     {
         if ( !self.isPreparedForDismissal )
         {
             [self.videoPlayer pause];
             self.sequencePreviewView.hidden = YES;
         }
     }];
    
    // This timer is added as a workaround to kill the ad video if it has not started playing
    self.adTimeoutTimer = [VTimerManager scheduledTimerManagerWithTimeInterval:kAdTimeoutTimeInterval
                                                                        target:self
                                                                      selector:@selector(adTimerDidFire)
                                                                      userInfo:nil
                                                                       repeats:NO];
}

- (void)adTimerDidFire
{
    [self resumeContentPlaybackAnimated:YES];
}

#pragma mark  VAdVideoPlayerViewControllerDelegate

- (void)adHadErrorForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    [self.activityIndicatorView stopAnimating];
    [self resumeContentPlaybackAnimated:NO];
}

- (void)adDidLoadForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    // This is where we can preload the content video after the ad video has loaded
}

- (void)adDidStartPlaybackForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    [self.activityIndicatorView stopAnimating];
    [self.delegate contentCellDidStartPlayingAd:self];
    [self.adTimeoutTimer invalidate];
    self.adTimeoutTimer = nil;
}

- (void)adDidStopPlaybackForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    [self.delegate contentCellDidEndPlayingAd:self];
    [self resumeContentPlaybackAnimated:YES];
}

- (void)adDidFinishForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    [self.activityIndicatorView stopAnimating];
    [self.delegate contentCellDidEndPlayingAd:self];
    [self resumeContentPlaybackAnimated:YES];
}

@end
