//
//  VPollSequencePreviewView.m
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPollSequencePreviewView.h"

// Dependencies
#import "VDependencyManager.h"

// Models + Helpers
#import "VSequence+Fetcher.h"
#import "VAnswer+Fetcher.h"
#import "VNode+Fetcher.h"

// Views + Helpers
#import "VPollView.h"
#import "UIView+AutoLayout.h"

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
    
    VAnswer *answerA = [sequence.firstNode answerA];
    VAnswer *answerB = [sequence.firstNode answerB];
    self.cancelingImageLoads = NO;
    [self.pollView setImageURL:answerA.previewMediaURL
                 forPollAnswer:VPollAnswerA
                    completion:pollImageCompletionBlock];
    [self.pollView setImageURL:answerB.previewMediaURL
                 forPollAnswer:VPollAnswerB
                    completion:pollImageCompletionBlock];
}

@end
