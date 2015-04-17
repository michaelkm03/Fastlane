//
//  VAbstractActionView.m
//  victorious
//
//  Created by Michael Sena on 4/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractActionView.h"

// Action Bar
#import "VActionBar.h"

// Views + Helpers
#import "UIView+Autolayout.h"

@interface VAbstractActionView ()

@property (nonatomic, strong) VActionBar *actionBar;

@end

@implementation VAbstractActionView

@synthesize sequence = _sequence;
@synthesize sequenceActionsDelegate = _sequenceActionsDelegate;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.actionBar = [[VActionBar alloc] initWithFrame:self.bounds];
    [self addSubview:self.actionBar];
    [self v_addFitToParentConstraintsToSubview:self.actionBar];
    
    // If we got a sequence before we setup our aciton bar
    if (self.sequence)
    {
        [self updateActionItemsOnBar:self.actionBar
                         forSequence:self.sequence];

    }
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self updateActionItemsOnBar:self.actionBar
                     forSequence:_sequence];
    [self updateRepostButtonForSequence:_sequence];
    [self updateCommentCountForSequence:_sequence];
}

@end

@implementation VAbstractActionView (VActionMethods)

- (void)comment:(id)sender
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willCommentOnSequence:fromView:)])
    {
        [self.sequenceActionsDelegate willCommentOnSequence:self.sequence
                                                   fromView:self];
    }
}

- (void)share:(id)sender
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willShareSequence:fromView:)])
    {
        [self.sequenceActionsDelegate willShareSequence:self.sequence
                                               fromView:self];
    }
}

- (void)repost:(id)sender
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willRepostSequence:fromView:completion:)])
    {
        self.reposting = YES;
        __weak typeof(self) welf = self;
        [self.sequenceActionsDelegate willRepostSequence:self.sequence
                                                fromView:self
                                              completion:^(BOOL success)
         {
             welf.reposting = NO;
         }];
    }
}

- (void)meme:(id)meme
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willRemixSequence:fromView:videoEdit:)])
    {
        [self.sequenceActionsDelegate willRemixSequence:self.sequence
                                               fromView:self
                                              videoEdit:VDefaultVideoEditSnapshot];
    }
}

- (void)gif:(id)gif
{
    [self.sequenceActionsDelegate willRemixSequence:self.sequence
                                           fromView:self
                                          videoEdit:VDefaultVideoEditGIF];
}

@end

@implementation VAbstractActionView (VUpdateHooks)

- (void)updateActionItemsOnBar:(VActionBar *)actionBar
                   forSequence:(VSequence *)sequence
{
    // Implement in subclasses
}

- (void)updateCommentCountForSequence:(VSequence *)sequence
{
    // Implement in subclasses
}

- (void)updateRepostButtonForSequence:(VSequence *)sequence
{
    // Implement in subclasses
}

@end
