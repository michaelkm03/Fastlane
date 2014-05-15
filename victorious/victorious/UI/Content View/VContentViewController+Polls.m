//
//  VContentViewController+Polls.m
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewController+Polls.h"
#import "VContentViewController+Videos.h"

#import "VPollResult.h"
#import "VAnswer.h"

#import "VObjectManager+Sequence.h"

@implementation VContentViewController (Polls)

#pragma mark - Animation
- (void)pollAnimation
{
    [UIView animateWithDuration:.2f
                     animations:^{
                         
                         CGRect firstSmallFrame = self.firstSmallPreviewImage.frame;
                         self.firstSmallPreviewImage.frame = CGRectMake(CGRectGetMinX(firstSmallFrame) - 1.0f, CGRectGetMinY(firstSmallFrame), CGRectGetWidth(firstSmallFrame), CGRectGetHeight(firstSmallFrame));
                         
                         CGRect secondSmallFrame = self.secondSmallPreviewImage.frame;
                         self.secondSmallPreviewImage.frame = CGRectMake(CGRectGetMinX(secondSmallFrame) + 1.0f, CGRectGetMinY(secondSmallFrame), CGRectGetWidth(secondSmallFrame), CGRectGetHeight(secondSmallFrame));
                         
                         self.orImageView.hidden = ![self.currentNode isPoll];
                         self.orImageView.center = CGPointMake(self.orImageView.center.x, self.pollPreviewView.center.y);
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
    
    [self.firstSmallPreviewImage setImageWithURL:[NSURL URLWithString:((VAnswer*)[answers firstObject]).thumbnailUrl]
                                placeholderImage:self.backgroundImage.image];
    [self.secondSmallPreviewImage setImageWithURL:[NSURL URLWithString:((VAnswer*)[answers lastObject]).thumbnailUrl]
                                 placeholderImage:self.backgroundImage.image];
 
    if ([[((VAnswer*)[answers firstObject]).mediaUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
    {
        self.firstPollButton.hidden = NO;
    }
    else
    {
        self.firstPollButton.hidden = YES;
    }
    if ([[((VAnswer*)[answers lastObject]).mediaUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
    {
        self.secondPollButton.hidden = NO;
    }
    else
    {
        self.secondPollButton.hidden = YES;
    }
    
    self.pollPreviewView.hidden = NO;
    self.previewImage.hidden = YES;
    self.remixButton.hidden = YES;
}

- (IBAction)playPoll:(UIButton *)sender
{
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    NSURL* contentURL;
    UIImageView *thumbnailView;
    if (sender == self.firstPollButton)
    {
        thumbnailView = self.firstSmallPreviewImage;
        contentURL = [NSURL URLWithString:((VAnswer*)[answers firstObject]).mediaUrl];
    }
    else if (sender == self.secondPollButton)
    {
        thumbnailView = self.secondSmallPreviewImage;
        contentURL = [NSURL URLWithString:((VAnswer*)[answers lastObject]).mediaUrl];
    }

    void (^playVideo)(void) = ^(void)
    {
        UIImageView *temporaryThumbnailView = [[UIImageView alloc] initWithImage:thumbnailView.image];
        temporaryThumbnailView.contentMode = thumbnailView.contentMode;
        temporaryThumbnailView.clipsToBounds = thumbnailView.clipsToBounds;
        temporaryThumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.mediaView addSubview:temporaryThumbnailView];
        thumbnailView.hidden = YES;
        
        CGRect desiredFrame = [self.mediaView convertRect:thumbnailView.bounds fromView:thumbnailView];
        NSLayoutConstraint *xConstraint = [NSLayoutConstraint constraintWithItem:temporaryThumbnailView
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.mediaView
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1.0f
                                                                        constant:CGRectGetMinX(desiredFrame)];
        xConstraint.priority = UILayoutPriorityDefaultHigh;
        [self.mediaView addConstraint:xConstraint];
        
        NSLayoutConstraint *yConstraint = [NSLayoutConstraint constraintWithItem:temporaryThumbnailView
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.mediaView
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0f
                                                                        constant:CGRectGetMinY(desiredFrame)];
        yConstraint.priority = UILayoutPriorityDefaultHigh;
        [self.mediaView addConstraint:yConstraint];
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:temporaryThumbnailView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0f
                                                                            constant:CGRectGetWidth(desiredFrame)];
        widthConstraint.priority = UILayoutPriorityDefaultHigh;
        [self.mediaView addConstraint:widthConstraint];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:temporaryThumbnailView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0f
                                                                             constant:CGRectGetHeight(desiredFrame)];
        heightConstraint.priority = UILayoutPriorityDefaultHigh;
        [self.mediaView addConstraint:heightConstraint];
        
        [self playVideoAtURL:contentURL withPreviewView:temporaryThumbnailView];
        
        typeof(self) __weak weakSelf = self;
        [self setOnVideoUnloadBlock:^(void)
        {
            thumbnailView.hidden = NO;
            [temporaryThumbnailView removeFromSuperview];
        }];
        [self setOnVideoCompletionBlock:^(void)
        {
            [weakSelf unloadVideoWithDuration:0.2f completion:nil];
        }];
    };
    
    if ([self isVideoLoadingOrLoaded])
    {
        [self unloadVideoWithDuration:0.2f
                           completion:^(void)
        {
            playVideo();
        }];
    }
    else
    {
        playVideo();
    }
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
