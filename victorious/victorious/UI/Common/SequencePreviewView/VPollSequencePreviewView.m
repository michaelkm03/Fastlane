//
//  VPollSequencePreviewView.m
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPollSequencePreviewView.h"
#import "VDependencyManager.h"
#import "VSequence+Fetcher.h"
#import "VAnswer+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VImageAssetFinder+PollAssets.h"
#import "VPollView.h"
#import "UIView+AutoLayout.h"
#import "VImageAssetFinder.h"

static NSString *kOrIconKey = @"orIcon";

@interface VPollSequencePreviewView ()

@property (nonatomic, strong) VPollView *pollView;
@property (nonatomic, assign) BOOL loadedBothPollImages;
@property (nonatomic, assign) BOOL cancelingImageLoads;

@end

@implementation VPollSequencePreviewView

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    self.pollView.pollIcon = [dependencyManager imageForKey:kOrIconKey];
}

#pragma mark - Property Accessors

- (VPollView *)pollView
{
    if (_pollView == nil)
    {
        _pollView = [[VPollView alloc] initWithFrame:CGRectZero];
        [self addSubview:_pollView];
        [self v_addFitToParentConstraintsToSubview:_pollView];
    }
    return _pollView;
}

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    //Cancel the prior image downloads in the pollview
    self.cancelingImageLoads = YES;
    [self.pollView setImageURL:nil forPollAnswer:VPollAnswerA completion:nil];
    [self.pollView setImageURL:nil forPollAnswer:VPollAnswerB completion:nil];
    self.loadedBothPollImages = NO;
    
    __weak VPollSequencePreviewView *weakSelf = self;
    void (^pollImageCompletionBlock)(UIImage *) = ^void(UIImage *image)
    {
        __strong VPollSequencePreviewView *strongSelf = weakSelf;
        if ( strongSelf == nil )
        {
            return;
        }
        
        if ( strongSelf.cancelingImageLoads )
        {
            return;
        }
        
        if ( strongSelf.loadedBothPollImages )
        {
            strongSelf.readyForDisplay = YES;
        }
        strongSelf.loadedBothPollImages = YES;
    };
    
    VImageAssetFinder *assetFinder = [[VImageAssetFinder alloc] init];
    
    VAnswer *answerA = [assetFinder answerAFromAssets:sequence.previewAssets];
    VAnswer *answerB = [assetFinder answerBFromAssets:sequence.previewAssets];
    
    if (answerA == nil)
    {
        // fall back if needed
        answerA = [sequence.firstNode answerA];
    }
    if (answerB == nil)
    {
        // fall back if needed
        answerB = [sequence.firstNode answerB];
    }
    
    self.cancelingImageLoads = NO;
    [self.pollView setImageURL:answerA.previewMediaURL
                 forPollAnswer:VPollAnswerA
                    completion:pollImageCompletionBlock];
    [self.pollView setImageURL:answerB.previewMediaURL
                 forPollAnswer:VPollAnswerB
                    completion:pollImageCompletionBlock];
}

#pragma mark - IBActions

- (IBAction)pressedAnswerAButton:(id)sender
{
#warning Define media url
    NSURL *mediaURL;
    
    NSDictionary *params = @{ VTrackingKeyIndex : @0,
                              VTrackingKeyMediaType : [mediaURL pathExtension] ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectPollMedia parameters:params];
    
    /*[self.detailDelegate previewView:self
                   didSelectMediaURL:mediaURL
                      previewImage:weakPollCell.answerAPreviewImage
                           isVideo:isVideo
                        sourceView:weakPollCell.answerAContainer];*/
}

- (IBAction)pressedAnswerBButton:(id)sender
{
#warning Define media url
    NSURL *mediaURL;
    NSDictionary *params = @{ VTrackingKeyIndex : @1, VTrackingKeyMediaType : [mediaURL pathExtension] ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectPollMedia parameters:params];
    
   /* [self.detailDelegate previewView:self
                   didSelectMediaURL:mediaURL
                      previewImage:weakPollCell.answerBPreviewImage
                           isVideo:isVideo
                        sourceView:weakPollCell.answerBContainer];*/
}

- (void)shareAnimationCurveWithAnimations:(void (^)(void))animations
                           withCompletion:(void (^)(void))completion
{
//    [self bringSubviewToFront:self.answerAResultView];
//    [self bringSubviewToFront:self.answerBResultView];
//    [self bringSubviewToFront:self.pollCountContainer];
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.5f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         if (animations)
         {
             animations();
         }
     }
                     completion:^(BOOL finished)
     {
         if (completion && finished)
         {
             completion();
         }
     }];
}

@end
