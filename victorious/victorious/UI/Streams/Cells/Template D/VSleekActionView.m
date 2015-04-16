//
//  VSleekActionView.m
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSleekActionView.h"

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
#import "VRepostAnimator.h"

static CGFloat const kRepostedDisabledAlpha = 0.3f;
static CGFloat const kLeadingTrailingSpace = 15.0f;
static CGFloat const kCommentSpaceToActions = 22.0f;
static CGFloat const kInterActionSpace = 25.0f;

@interface VSleekActionView ()

@property (nonatomic, strong) VRoundedBackgroundButton *commentButton;
@property (nonatomic, strong) VRoundedBackgroundButton *shareButton;
@property (nonatomic, strong) VRoundedBackgroundButton *repostButton;
@property (nonatomic, strong) VRoundedBackgroundButton *memeButton;
@property (nonatomic, strong) VRoundedBackgroundButton *gifButton;
@property (nonatomic, strong) NSArray *actionButtons;

@property (nonatomic, strong) VActionBar *actionBar;
@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VRepostAnimator *repostAnimator;

@end

@implementation VSleekActionView

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
    self.repostAnimator = [[VRepostAnimator alloc] init];
    
    self.actionBar = [[VActionBar alloc] initWithFrame:self.bounds];
    [self addSubview:self.actionBar];
    [self v_addFitToParentConstraintsToSubview:self.actionBar];
    
    self.largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    
    self.commentButton = [[VRoundedBackgroundButton alloc] initWithFrame:CGRectZero];
    [self.commentButton addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentButton setImage:[UIImage imageNamed:@"D_commentIcon"] forState:UIControlStateNormal];
    [self.commentButton v_addWidthConstraint:68.0f];
    [self.commentButton v_addHeightConstraint:31.0f];
    self.commentButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.commentButton.unselectedColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    
    self.shareButton = [self actionButtonWithImage:[UIImage imageNamed:@"D_shareIcon"] action:@selector(share:)];
    self.repostButton = [self actionButtonWithImage:[UIImage imageNamed:@"D_repostIcon"] action:@selector(repost:)];
    self.memeButton = [self actionButtonWithImage:[UIImage imageNamed:@"D_commentIcon"] action:@selector(meme:)];
    self.gifButton = [self actionButtonWithImage:[UIImage imageNamed:@"D_gifIcon"] action:@selector(gif:)];
    self.actionButtons = @[self.shareButton, self.repostButton, self.memeButton, self.gifButton];
    self.actionBar.actionItems = @[
                                   [VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingTrailingSpace],
                                   self.commentButton,
                                   [VActionBarFixedWidthItem fixedWidthItemWithWidth:kCommentSpaceToActions],
                                   self.shareButton,
                                   [VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace],
                                   self.repostButton,
                                   [VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace],
                                   self.memeButton,
                                   [VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace],
                                   self.gifButton,
                                   [VActionBarFlexibleSpaceItem flexibleSpaceItem]
                                   ];
}

- (VRoundedBackgroundButton *)actionButtonWithImage:(UIImage *)actionImage
                                             action:(SEL)action
{
    VRoundedBackgroundButton *actionButton = [[VRoundedBackgroundButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat colorVal = 238.0f / 255.0f;
    actionButton.unselectedColor = [UIColor colorWithRed:colorVal green:colorVal blue:colorVal alpha:1.0f];
    actionButton.selected = NO;
    actionButton.tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    [actionButton setImage:[actionImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                  forState:UIControlStateNormal];
    [actionButton v_addWidthConstraint:31.0f];
    [actionButton v_addHeightConstraint:31.0f];
    [actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return actionButton;
}

- (void)setSequence:(VSequence *)sequence
{
    [self.KVOController unobserve:self.sequence keyPath:NSStringFromSelector(@selector(hasReposted))];

    _sequence = sequence;
    
    __weak typeof(self) welf = self;
    [self.KVOController observe:sequence
                        keyPath:NSStringFromSelector(@selector(hasReposted))
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                          block:^(id observer, id object, NSDictionary *change)
     {
         NSNumber *oldValue = change[NSKeyValueChangeOldKey];
         NSNumber *newValue = change[NSKeyValueChangeNewKey];
         if ([newValue boolValue] == [oldValue boolValue])
         {
             return;
         }
         [welf.repostAnimator updateRepostWithAnimations:^
          {
              [welf updateRepostButtonForRepostState];
          }
                                                onButton:welf.repostButton
                                                animated:YES];
     }];
    
    [self reloadCommentsCount];
    [welf updateRepostButtonForRepostState];
}

- (void)reloadCommentsCount
{
    [self.commentButton setTitle:[self.largeNumberFormatter stringForInteger:[[self.sequence commentCount] integerValue]]
                        forState:UIControlStateNormal];
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
        __weak typeof(self) welf = self;
        [self.sequenceActionsDelegate willRepostSequence:self.sequence
                                                fromView:self
                                              completion:^(BOOL success)
         {
             [welf.repostAnimator updateRepostWithAnimations:^
              {
                  [welf updateRepostButtonForRepostState];
              }
                                                    onButton:welf.repostButton
                                                    animated:YES];
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
    
    UIImage *selectedImage = [[UIImage imageNamed:@"D_repostIcon-success"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *unselectedImage = [[UIImage imageNamed:@"D_repostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.repostButton setImage:hasRespoted ? selectedImage : unselectedImage
                       forState:UIControlStateNormal];
    self.repostButton.enabled = !hasRespoted;
    self.repostButton.alpha = hasRespoted ? kRepostedDisabledAlpha : 1.0f;
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if (_dependencyManager != nil)
    {
        //Override the default tint color to always have white text in the comment label
        [self.commentButton setTintColor:[UIColor whiteColor]];
        [[self.commentButton titleLabel] setFont:[_dependencyManager fontForKey:VDependencyManagerParagraphFontKey]];
        self.commentButton.unselectedColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        
        [self.actionButtons enumerateObjectsUsingBlock:^(VRoundedBackgroundButton *actionButton, NSUInteger idx, BOOL *stop)
         {
             actionButton.tintColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
         }];
    }
}

@end
