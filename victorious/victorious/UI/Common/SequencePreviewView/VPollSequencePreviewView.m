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

@property (nonatomic, strong) VSequence *sequence;

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
    _sequence = sequence;
    
    NSArray *answers = [[self.sequence firstNode] firstAnswers];
    VAnswer *answerA = [answers firstObject];
    VAnswer *answerB = [answers lastObject];
    [self.pollView setImageURL:answerA.previewMediaURL
                 forPollAnswer:VPollAnswerA];
    [self.pollView setImageURL:answerB.previewMediaURL
                 forPollAnswer:VPollAnswerB];
}

@end
