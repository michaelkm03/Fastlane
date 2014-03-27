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

@implementation VContentViewController (Polls)

#pragma mark - Animation
- (void)pollAnimation
{
    [UIView animateWithDuration:.2f
                     animations:^{
                         
                         [self.firstSmallPreviewImage setXOrigin:self.firstSmallPreviewImage.frame.origin.x - 1];
                         [self.secondSmallPreviewImage setXOrigin:self.secondSmallPreviewImage.frame.origin.x + 1];
                         
                         self.orImageView.hidden = ![self.currentNode isPoll];
                         self.orImageView.center = CGPointMake(self.orImageView.center.x, self.pollPreviewView.center.y);
                         self.orAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.orContainerView];
                         
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

#pragma mark - Poll
- (void)loadPoll
{
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    [self.firstSmallPreviewImage setImageWithURL:[((VAnswer*)[answers firstObject]).mediaUrl convertToPreviewImageURL]];
    [self.secondSmallPreviewImage setImageWithURL:[((VAnswer*)[answers lastObject]).mediaUrl convertToPreviewImageURL]];
    
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
    
    [self updateActionBar];
}

- (IBAction)playPoll:(id)sender
{
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    if( ((UIButton*)sender).tag == self.firstPollButton.tag)
    {
        [self.mpController setContentURL:[NSURL URLWithString:((VAnswer*)[answers firstObject]).mediaUrl]];
    }
    else if ( ((UIButton*)sender).tag == self.secondPollButton.tag)
    {
        [self.mpController setContentURL:[NSURL URLWithString:((VAnswer*)[answers lastObject]).mediaUrl]];
    }
    [self.mpController prepareToPlay];
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
    
    for(VPollResult* result in self.sequence.pollResults)
    {
        VResultView* resultView = [self resultViewForAnswerId:result.answerId];
        
        CGFloat progress = result.count.doubleValue / totalVotes;
        
        if (result.answerId == answerId)
        {
            resultView.color = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainColor];
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
