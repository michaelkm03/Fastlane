//
//  VContentViewController+Polls.m
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSURL+MediaType.h"
#import "VAnalyticsRecorder.h"
#import "VAnswer.h"
#import "VContentViewController+Polls.h"
#import "VContentViewController+Videos.h"
#import "VImageLightboxViewController.h"
#import "VLightboxTransitioningDelegate.h"
#import "VObjectManager+Sequence.h"
#import "VPollResult.h"
#import "VVideoLightboxViewController.h"

@implementation VContentViewController (Polls)

#pragma mark - Animation
- (void)pollAnimation
{
    self.orImageView.hidden = ![self.currentNode isPoll];

    self.orAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.orContainerView];
    self.orAnimator.delegate = self;
    
    UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.orImageView]];
    gravityBehavior.magnitude = 4;
    [self.orAnimator addBehavior:gravityBehavior];
    
    UIDynamicItemBehavior *elasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.orImageView]];
    elasticityBehavior.elasticity = 0.2f;
    [self.orAnimator addBehavior:elasticityBehavior];
    
    UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.orImageView]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [self.orAnimator addBehavior:collisionBehavior];
    
    [UIView animateWithDuration:.2f
                     animations:^{
                         self.leftSmallPreviewImageWidthConstraint.constant = 159.0f;
                         self.rightSmallPreviewImageWidthConstraint.constant = 159.0f;
                         [self.pollPreviewView layoutIfNeeded];
                     }];
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    if ([self.actionBarVC isKindOfClass:[VPollAnswerBarViewController class]])
    {
        ((VPollAnswerBarViewController*)self.actionBarVC).orImageView.hidden = NO;
            [((VPollAnswerBarViewController*)self.actionBarVC) checkIfAnswered];
        self.orImageView.hidden = YES;
        
    }
}

#pragma mark - Poll
- (void)loadPoll
{
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    
    [self.firstSmallPreviewImage setImageWithURL:[NSURL URLWithString:((VAnswer*)[answers firstObject]).mediaUrl]
                                placeholderImage:self.leftPollThumbnail];
    [self.secondSmallPreviewImage setImageWithURL:[NSURL URLWithString:((VAnswer*)[answers lastObject]).mediaUrl]
                                 placeholderImage:self.rightPollThumbnail];
 
    if ([((VAnswer*)[answers firstObject]).mediaUrl v_hasVideoExtension])
    {
        self.firstPollPlayIcon.hidden = NO;
    }
    else
    {
        self.firstPollPlayIcon.hidden = YES;
    }
    if ([((VAnswer*)[answers lastObject]).mediaUrl v_hasVideoExtension])
    {
        self.secondPollPlayIcon.hidden = NO;
    }
    else
    {
        self.secondPollPlayIcon.hidden = YES;
    }
    
    self.pollPreviewView.hidden = NO;
    self.mediaSuperview.hidden = YES;
}

- (IBAction)playPoll:(UIButton *)sender
{
    if (self.collapsePollMedia)
    {
        self.collapsePollMedia(YES, nil);
        return;
    }
    
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    NSURL* contentURL;
    UIImageView *thumbnailView;
    UIImageView *otherThumbnailView;
    UIView *playIcon;
    UIView *otherPlayIcon;
    NSLayoutConstraint *thumbnailWidthConstraint;
    NSLayoutConstraint *thumbnailHeightConstraint;
    if (sender == self.firstPollButton)
    {
        thumbnailView = self.firstSmallPreviewImage;
        otherThumbnailView = self.secondSmallPreviewImage;
        playIcon = self.firstPollPlayIcon;
        otherPlayIcon = self.secondPollPlayIcon;
        thumbnailWidthConstraint = self.leftImageViewWidthConstraint;
        thumbnailHeightConstraint = self.leftImageViewHeightConstraint;
        contentURL = [NSURL URLWithString:((VAnswer*)[answers firstObject]).mediaUrl];
    }
    else if (sender == self.secondPollButton)
    {
        thumbnailView = self.secondSmallPreviewImage;
        otherThumbnailView = self.firstSmallPreviewImage;
        playIcon = self.secondPollPlayIcon;
        otherPlayIcon = self.firstPollPlayIcon;
        thumbnailWidthConstraint = self.rightImageViewWidthConstraint;
        thumbnailHeightConstraint = self.rightImageViewHeightConstraint;
        contentURL = [NSURL URLWithString:((VAnswer*)[answers lastObject]).mediaUrl];
    }

    CGFloat previousWidth = thumbnailWidthConstraint.constant;
    CGFloat previousHeight = thumbnailHeightConstraint.constant;
    CGFloat previousPollMaskAlpha = self.answeredPollMaskingView.alpha;
    
    [self.pollPreviewView sendSubviewToBack:otherPlayIcon];
    [self.pollPreviewView sendSubviewToBack:otherThumbnailView];
    [UIView animateKeyframesWithDuration:kVContentPollAnimationDuration
                                   delay:0
                                 options:0
                              animations:^(void)
    {
        [UIView addKeyframeWithRelativeStartTime:0
                                relativeDuration:0.9
                                      animations:^(void)
        {
            if ([contentURL v_hasVideoExtension])
            {
                thumbnailWidthConstraint.constant = CGRectGetWidth(self.previewImage.frame);
                thumbnailHeightConstraint.constant = CGRectGetHeight(self.previewImage.frame);
            }
            else
            {
                CGFloat width = CGRectGetWidth(self.pollPreviewView.frame);
                thumbnailWidthConstraint.constant = width;
                thumbnailHeightConstraint.constant = MIN(width * thumbnailView.image.size.height / thumbnailView.image.size.width,
                                                         CGRectGetHeight(self.pollPreviewView.frame));
            }
            [self.pollPreviewView layoutIfNeeded];
            playIcon.alpha = 0;
            self.firstResultView.alpha = 0;
            self.secondResultView.alpha = 0;
            self.answeredPollMaskingView.alpha = 0;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.9
                                relativeDuration:0.1
                                      animations:^(void)
        {
            otherThumbnailView.alpha = 0;
            otherPlayIcon.alpha = 0;
        }];
    }
                              completion:^(BOOL complete)
    {
        if ([contentURL v_hasVideoExtension])
        {
            self.mediaSuperview.hidden = NO;
            self.previewImage.image = thumbnailView.image;
            self.pollPreviewView.hidden = YES;
            [self playVideoAtURL:contentURL withPreviewView:self.previewImage];
            VContentViewController * __weak weakSelf = self;
            self.onVideoCompletionBlock = ^(void)
            {
                VContentViewController *strongSelf = weakSelf;
                if (strongSelf && strongSelf.collapsePollMedia)
                {
                    strongSelf.collapsePollMedia(YES, nil);
                }
            };
        }
    }];
    
    VContentViewController * __weak weakSelf = self;
    self.collapsePollMedia = ^(BOOL animated, void (^completion)())
    {
        if ([contentURL v_hasVideoExtension])
        {
            weakSelf.mediaSuperview.hidden = YES;
            weakSelf.pollPreviewView.hidden = NO;
            thumbnailView.frame = weakSelf.previewImage.frame;
            [weakSelf unloadVideoAnimated:NO withDuration:0 completion:nil];
        }
        
        void (^firstKeyframe)() = ^(void)
        {
            otherPlayIcon.alpha = 1.0f;
            otherThumbnailView.alpha = 1.0f;
        };
        void (^secondKeyframe)() = ^(void)
        {
            playIcon.alpha = 1.0f;
            weakSelf.firstResultView.alpha = 1.0f;
            weakSelf.secondResultView.alpha = 1.0f;
            if (previousPollMaskAlpha)
            {
                weakSelf.answeredPollMaskingView.alpha = previousPollMaskAlpha;
            }
            thumbnailWidthConstraint.constant = previousWidth;
            thumbnailHeightConstraint.constant = previousHeight;
            [weakSelf.pollPreviewView layoutIfNeeded];
        };
        void (^animationCompletion)(BOOL) = ^(BOOL finished)
        {
            if (completion)
            {
                completion();
            }
        };
        
        if (animated)
        {
            [UIView animateKeyframesWithDuration:kVContentPollAnimationDuration
                                           delay:0
                                         options:0
                                      animations:^(void)
            {
                [UIView addKeyframeWithRelativeStartTime:0
                                        relativeDuration:0.1
                                              animations:firstKeyframe];
                [UIView addKeyframeWithRelativeStartTime:0.1
                                        relativeDuration:0.9
                                              animations:secondKeyframe];
            }
                                      completion:animationCompletion];
        }
        else
        {
            firstKeyframe();
            secondKeyframe();
            animationCompletion(YES);
        }
        weakSelf.collapsePollMedia = nil;
    };
}

#pragma mark - VPollAnswerBarDelegate
- (void)answeredPollWithAnswerId:(NSNumber *)answerId
{
    self.firstResultView.hidden = NO;
    self.secondResultView.hidden = NO;
    [self.firstResultView setProgress:0 animated:NO];
    [self.secondResultView setProgress:0 animated:NO];
    
    NSInteger totalVotes = 0;
    for(VPollResult* result in self.sequence.pollResults)
    {
        totalVotes+= result.count.integerValue;
    }
    totalVotes = totalVotes ? totalVotes : 1; //dividing by 0 is bad.
    
    VLog(@"Answer: %@", answerId);
    
    for(VPollResult* result in self.sequence.pollResults)
    {
        VResultView* resultView = [self resultViewForAnswerId:result.answerId];
        
        CGFloat progress = result.count.doubleValue / totalVotes;
        
        VLog(@"Result :%@", result);
        if ([result.answerId isEqualToNumber:answerId])
        {
            resultView.color = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        }
        else
        {
            resultView.color = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
        }
        
        [resultView setProgress:progress animated:YES];
    }
    
    if (self.collapsePollMedia)
    {
        void (^previousCollapsePollMedia)(BOOL, void(^)()) = self.collapsePollMedia;
        VContentViewController * __weak weakSelf = self;
        self.collapsePollMedia = ^(BOOL animated, void (^completion)())
        {
            previousCollapsePollMedia(animated, completion);
            weakSelf.answeredPollMaskingView.alpha = 1.0f;
        };
    }
    else
    {
        [UIView animateWithDuration:0.5f
                         animations:^(void)
        {
            self.answeredPollMaskingView.alpha = 1.0f;
        }];
    }
}

- (VResultView*)resultViewForAnswerId:(NSNumber*)answerId
{
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    if ([answerId isEqualToNumber:((VAnswer*)[answers firstObject]).remoteId])
        return self.firstResultView;
    
    else if ([answerId isEqualToNumber:((VAnswer*)[answers lastObject]).remoteId])
        return self.secondResultView;
    
    else return nil;
}

@end
