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
                         
                         CGRect firstSmallFrame = self.firstSmallPreviewImage.frame;
                         self.firstSmallPreviewImage.frame = CGRectMake(CGRectGetMinX(firstSmallFrame) - 1.0f, CGRectGetMinY(firstSmallFrame), CGRectGetWidth(firstSmallFrame), CGRectGetHeight(firstSmallFrame));
                         
                         CGRect secondSmallFrame = self.secondSmallPreviewImage.frame;
                         self.secondSmallPreviewImage.frame = CGRectMake(CGRectGetMinX(secondSmallFrame) + 1.0f, CGRectGetMinY(secondSmallFrame), CGRectGetWidth(secondSmallFrame), CGRectGetHeight(secondSmallFrame));
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
    self.previewImage.hidden = YES;
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

    [self.activityIndicator removeFromSuperview];
    if (self.imageRequestOperation)
    {
        AFImageRequestOperation *oldImageRequest = self.imageRequestOperation;
        self.imageRequestOperation = nil;
        [oldImageRequest cancel];
    }
    
    if ([contentURL v_hasVideoExtension])
    {
        VVideoLightboxViewController *lightbox = [[VVideoLightboxViewController alloc] initWithPreviewImage:thumbnailView.image videoURL:contentURL];
        [VLightboxTransitioningDelegate addNewTransitioningDelegateToLightboxController:lightbox referenceView:thumbnailView];
        lightbox.onCloseButtonTapped = ^(void)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        lightbox.onVideoFinished = lightbox.onCloseButtonTapped;
        lightbox.titleForAnalytics = self.sequence.name;
        [self presentViewController:lightbox animated:YES completion:nil];
    }
    else if ([contentURL v_hasImageExtension] && ![self.imageRequestOperation.request.URL isEqual:contentURL])
    {
        VActivityIndicatorView *activityIndicator = [[VActivityIndicatorView alloc] init];
        activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.pollPreviewView addSubview:activityIndicator];
        [self.pollPreviewView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:thumbnailView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0f
                                                                          constant:0.0f]];
        [self.pollPreviewView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:thumbnailView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0f
                                                                          constant:0.0f]];
        [activityIndicator startAnimating];
        self.activityIndicator = activityIndicator;
        
        VContentViewController * __weak weakSelf = self;
        void (^cleanup)(void) = ^(void)
        {
            [activityIndicator removeFromSuperview];
            weakSelf.activityIndicator = nil;
            weakSelf.imageRequestOperation = nil;
        };
        
        AFImageRequestOperation *imageRequestOperation = [[AFImageRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:contentURL]];
        [imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            AFImageRequestOperation *imageRequestOperation = (AFImageRequestOperation *)operation;
            if (operation == weakSelf.imageRequestOperation)
            {
                VImageLightboxViewController *lightbox = [[VImageLightboxViewController alloc] initWithImage:imageRequestOperation.responseImage];
                [VLightboxTransitioningDelegate addNewTransitioningDelegateToLightboxController:lightbox referenceView:thumbnailView];
                lightbox.onCloseButtonTapped = ^(void)
                {
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                };
                [weakSelf presentViewController:lightbox animated:YES completion:cleanup];
                [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation action:@"Display Poll Image" label:self.sequence.name value:nil];
            }
        }
                                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            if (operation == weakSelf.imageRequestOperation)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:NSLocalizedString(@"ImageDownloadFailed", @"")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                          otherButtonTitles:nil];
                [alertView show];
                cleanup();
            }
        }];
        self.imageRequestOperation = imageRequestOperation;
        [imageRequestOperation start];
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
    
    [UIView animateWithDuration:0.5f
                     animations:^(void)
    {
        self.answeredPollMaskingView.alpha = 1.0f;
    }];
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
