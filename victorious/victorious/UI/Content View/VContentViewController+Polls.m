//
//  VContentViewController+Polls.m
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewController+Polls.h"

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
    self.mpPlayerContainmentView.hidden = YES;
    self.remixButton.hidden = YES;
}

- (IBAction)playPoll:(id)sender
{
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    NSURL* contentURL;
    if( ((UIButton*)sender).tag == self.firstPollButton.tag)
    {
        contentURL = [NSURL URLWithString:((VAnswer*)[answers firstObject]).mediaUrl];
    }
    else if ( ((UIButton*)sender).tag == self.secondPollButton.tag)
    {
        contentURL = [NSURL URLWithString:((VAnswer*)[answers lastObject]).mediaUrl];
    }
    
    [self.mpController.view removeFromSuperview];
    self.mpController = [[MPMoviePlayerController alloc] initWithContentURL:contentURL];
    self.mpController.scalingMode = MPMovieScalingModeAspectFit;
    self.mpController.view.frame = self.pollPreviewView.frame;
    self.mpController.shouldAutoplay = NO;
    [self.mpPlayerContainmentView addSubview:self.mpController.view];
    [self.mpController prepareToPlay];
    
    self.activityIndicator.center = self.mpController.view.center;
    [self.mediaView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
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
