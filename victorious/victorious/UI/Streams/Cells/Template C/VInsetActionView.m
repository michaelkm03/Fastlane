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

@interface VInsetActionView ()

@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *gifButton;
@property (nonatomic, strong) UIButton *memeButton;
@property (nonatomic, strong) UIButton *repostButton;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VActionBar *actionBar;
@property (nonatomic, strong) VRepostButtonController *repostButtonController;

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
    self.gifButton = [self actionButtonWithImage:[[UIImage imageNamed:@"C_gifIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                          action:@selector(gif:)];
    self.memeButton = [self actionButtonWithImage:[[UIImage imageNamed:@"C_memeIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                           action:@selector(meme:)];
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
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [actionButton setImage:actionImage forState:UIControlStateNormal];
    actionButton.tintColor = [UIColor blackColor];
    [actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return actionButton;
}

- (void)setSequence:(VSequence *)sequence
{
    [self.repostButtonController invalidate];
    
    _sequence = sequence;
    
    [self updateActionItemsForSequence:_sequence];
    self.repostButtonController = [[VRepostButtonController alloc] initWithSequence:sequence
                                                                       repostButton:self.repostButton
                                                                      repostedImage:[UIImage imageNamed:@"C_repostIcon-success"]
                                                                    unRepostedImage:[UIImage imageNamed:@"C_repostIcon"]];
}

- (void)updateActionItemsForSequence:(VSequence *)sequence
{
    NSMutableArray *actionItems = [[NSMutableArray alloc] init];
    
    [actionItems addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    [actionItems addObject:self.shareButton];
    [actionItems addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    
    if ([sequence canRemix] && [sequence isVideo])
    {
        [actionItems addObject:self.gifButton];
        [actionItems addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    }
    if ([sequence canRemix])
    {
        [actionItems addObject:self.memeButton];
        [actionItems addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    }
    
    if ([sequence canRepost])
    {
        [actionItems addObject:self.repostButton];
        [actionItems addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    }

    self.actionBar.actionItems = actionItems;
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

@end
