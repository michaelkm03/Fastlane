//
//  VInsetActionView.m
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInsetActionView.h"

// Frameworks
#import <FBKVOController.h>

// Dependencies
#import "VDependencyManager.h"

// Stream Support
#import "VSequence+Fetcher.h"

// Action Bar
#import "VActionBar.h"
#import "VActionBarFlexibleSpaceItem.h"
#import "VActionBarFixedWidthItem.h"
#import "VRoundedBackgroundButton.h"

// Views + Helpers
#import "UIView+Autolayout.h"
#import "VLargeNumberFormatter.h"
#import "VRepostButtonController.h"

static CGFloat const kRepostedDisabledAlpha     = 0.3f;

@interface VInsetActionView ()

@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *repostButton;
@property (nonatomic, strong) UIButton *memeButton;
@property (nonatomic, strong) UIButton *gifButton;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VActionBar *actionBar;
@property (nonatomic, strong) VRepostButtonController *repostAnimator;

@end

@implementation VInsetActionView

@synthesize sequence = _sequence;
@synthesize sequenceActionsDelegate = _sequenceActionsDelegate;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.actionBar = [[VActionBar alloc] initWithFrame:self.bounds];
    [self addSubview:self.actionBar];
    [self v_addFitToParentConstraintsToSubview:self.actionBar];
    
    self.shareButton = [self actionButtonWithImage:[[UIImage imageNamed:@"C_shareIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                            action:@selector(share:)];
    self.repostButton = [self actionButtonWithImage:[[UIImage imageNamed:@"C_repostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                                                 action:@selector(repost:)];
    
    self.actionBar.actionItems = @[
                                   [VActionBarFlexibleSpaceItem flexibleSpaceItem],
                                   self.shareButton,
                                   [VActionBarFlexibleSpaceItem flexibleSpaceItem],
                                   self.repostButton,
                                   [VActionBarFlexibleSpaceItem flexibleSpaceItem],
                                   ];
    ;
}

- (UIButton *)actionButtonWithImage:(UIImage *)actionImage
                             action:(SEL)action
{
    UIButton *actionButton = [[UIButton alloc] initWithFrame:CGRectZero];
    
    actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [actionButton setImage:actionImage forState:UIControlStateNormal];
    actionButton.tintColor = [UIColor blackColor];
    
    
    return actionButton;
}

#pragma mark - Actions

- (void)comment:(VRoundedBackgroundButton *)sender
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willCommentOnSequence:fromView:)])
    {
        [self.sequenceActionsDelegate willCommentOnSequence:self.sequence
                                                   fromView:self];
    }
}

- (void)share:(VRoundedBackgroundButton *)sender
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willShareSequence:fromView:)])
    {
        [self.sequenceActionsDelegate willShareSequence:self.sequence
                                               fromView:self];
    }
}

- (void)repost:(VRoundedBackgroundButton *)sender
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willRepostSequence:fromView:completion:)])
    {
        sender.enabled = NO;
        [self.sequenceActionsDelegate willRepostSequence:self.sequence
                                                fromView:self
                                              completion:^(BOOL success)
         {
             sender.enabled = YES;
         }];
    }
}

- (void)meme:(VRoundedBackgroundButton *)meme
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willRemixSequence:fromView:videoEdit:)])
    {
        [self.sequenceActionsDelegate willRemixSequence:self.sequence
                                               fromView:self
                                              videoEdit:VDefaultVideoEditSnapshot];
    }
}

- (void)gif:(VRoundedBackgroundButton *)gif
{
    [self.sequenceActionsDelegate willRemixSequence:self.sequence
                                           fromView:self
                                          videoEdit:VDefaultVideoEditGIF];
}

#pragma mark - Repost Animation

- (void)updateRepostButtonForRepostState
{
    BOOL hasRespoted = [self.sequence.hasReposted boolValue];
    
    UIImage *selectedImage = [[UIImage imageNamed:@"C_repostIcon-success"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *unselectedImage = [[UIImage imageNamed:@"C_repostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.repostButton setImage:hasRespoted ? selectedImage : unselectedImage
                       forState:UIControlStateNormal];
    self.repostButton.enabled = !hasRespoted;
    self.repostButton.alpha = hasRespoted ? kRepostedDisabledAlpha : 1.0f;
}

@end
