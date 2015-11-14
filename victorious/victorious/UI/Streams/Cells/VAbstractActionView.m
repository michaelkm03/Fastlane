//
//  VAbstractActionView.m
//  victorious
//
//  Created by Michael Sena on 4/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractActionView.h"

// Action Bar
#import "VFlexBar.h"

// Views + Helpers
#import "UIView+Autolayout.h"

// Models
#import "VSequence+Fetcher.h"

// Frameworks
@import KVOController;

@interface VAbstractActionView ()

@property (nonatomic, strong) VFlexBar *actionBar;

@end

@implementation VAbstractActionView

@synthesize sequence = _sequence;
@synthesize sequenceActionsDelegate = _sequenceActionsDelegate;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // If we got a sequence before we setup our action bar
    if (self.sequence != nil)
    {
        [self updateActionItemsOnBar:self.actionBar
                         forSequence:self.sequence];
    }
}

- (VFlexBar *)actionBar
{
    if (_actionBar == nil)
    {
        _actionBar = [[VFlexBar alloc] initWithFrame:self.bounds];
        [self addSubview:_actionBar];
        [self v_addFitToParentConstraintsToSubview:_actionBar];
    }
    return _actionBar;
}

- (void)setSequence:(VSequence *)sequence
{
    [self.KVOController unobserve:_sequence];
    
    _sequence = sequence;
    
    [self updateActionItemsOnBar:self.actionBar forSequence:_sequence];
}

#pragma mark - VStreamCellSpecialization

+ (NSString *)reuseIdentifierForStreamItem:(VStreamItem *)streamItem
                            baseIdentifier:(NSString *)baseIdentifie
                         dependencyManager:(VDependencyManager *)dependencyManager
{
    NSAssert(false, @"Implement in subclasses");
    return nil;
}

@end

@implementation VAbstractActionView (VActionMethods)

- (void)comment:(id)sender
{
    UIResponder<VSequenceActionsDelegate> *targetForComment = [self targetForAction:@selector(willCommentOnSequence:fromView:)
                                                                         withSender:self];
    NSAssert( targetForComment != nil, @"We need an object in the respodner chain for commenting.");
    [targetForComment willCommentOnSequence:self.sequence
                                   fromView:self];
}

- (void)share:(id)sender
{
    UIResponder<VSequenceActionsDelegate> *targetForShare = [self targetForAction:@selector(willShareSequence:fromView:)
                                                                       withSender:self];
    NSAssert( targetForShare != nil, @"We need an object in the responder chain for sharing.");
    [targetForShare willShareSequence:self.sequence
                             fromView:self];
}

- (void)repost:(id)sender
{
    if ([self.sequence.hasReposted boolValue] || ![self.sequence.permissions canRepost])
    {
        // do nothing if we have already reposted
        return;
    }
    
    UIResponder<VSequenceActionsDelegate> *targetForRepost = [self targetForAction:@selector(willRepostSequence:fromView:completion:)
                                                                        withSender:self];
    NSAssert( targetForRepost != nil, @"We need an object in the responder chain for resposting.");
    [targetForRepost willRepostSequence:self.sequence
                               fromView:self
                             completion:nil];
}

- (void)meme:(id)sender
{
    UIResponder<VSequenceActionsDelegate> *targetForMeme = [self targetForAction:@selector(willRemixSequence:fromView:videoEdit:)
                                                                      withSender:self];
    NSAssert( targetForMeme != nil, @"We need an object in the responder chain for memeing.");
    [targetForMeme willRemixSequence:self.sequence
                            fromView:self
                           videoEdit:VDefaultVideoEditSnapshot];
}

- (void)gif:(id)sender
{
    UIResponder<VSequenceActionsDelegate> *targetForGIF = [self targetForAction:@selector(willRemixSequence:fromView:videoEdit:)
                                                                     withSender:self];
    NSAssert( targetForGIF != nil , @"We need an object in the responder chain for gifing.");
    [targetForGIF willRemixSequence:self.sequence
                           fromView:self
                          videoEdit:VDefaultVideoEditGIF];
}

- (void)like:(id)sender
{
    UIResponder<VSequenceActionsDelegate> *responder = [self targetForAction:@selector(willLikeSequence:withView:completion:)
                                                                     withSender:self];
    
    NSAssert( responder != nil , @"We need an object in the responder chain for liking.");
    
    [responder willLikeSequence:self.sequence withView:sender completion:nil];
}

@end

@implementation VAbstractActionView (VUpdateHooks)

- (void)updateActionItemsOnBar:(VFlexBar *)actionBar
                   forSequence:(VSequence *)sequence
{
    // Implement in subclasses
}

@end
