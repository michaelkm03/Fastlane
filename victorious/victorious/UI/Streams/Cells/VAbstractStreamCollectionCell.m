//
//  VAbstractStreamCollectionCell.m
//  victorious
//
//  Created by Michael Sena on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractStreamCollectionCell.h"

// Libraries
#import <FBKVOController.h>

// Delegate
#import "VSequenceActionsDelegate.h"

// Dependencies
#import "VDependencyManager.h"

// Views
#import "UIImageView+VLoadingAnimations.h"
#import "UIView+AutoLayout.h"
#import "VTextPostViewController.h"
#import "VPollView.h"
#import "UIColor+VHex.h"

// Models
#import "VUser+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VAsset+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAnswer+Fetcher.h"

@interface VAbstractStreamCollectionCell ()

@property (nonatomic, strong, readwrite) UIView *previewView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIImageView *playCircleImageView;
@property (nonatomic, strong) VTextPostViewController *textPostViewController;
@property (nonatomic, strong) VPollView *pollView;

@property (nonatomic, strong, readwrite) VDependencyManager *dependencyManager;

@property (nonatomic, weak) id <VSequenceActionsDelegate> sequenceActionsDelegate;

@end

@implementation VAbstractStreamCollectionCell

#pragma mark - Class Methods

+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence
{
    NSAssert(false, @"Must implement in subclasses!");
    return nil;
}

+ (BOOL)canOverlayContentForSequence:(VSequence *)sequence
{
    if ([sequence isText])
    {
        return NO;
    }

    BOOL nameIsEmpty = ((sequence.name.length == 0) || ([sequence.name isEqualToString:@""]));
    if (nameIsEmpty)
    {
        return NO;
    }
    
    BOOL nameIsEmbedded = [sequence.nameEmbeddedInContent boolValue];
    if (nameIsEmbedded)
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - Property Accessors

- (UIView *)previewView
{
    if (_previewView == nil)
    {
        _previewView = [[UIView alloc] initWithFrame:CGRectZero];
        _previewView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _previewView;
}

- (void)setSequence:(VSequence *)sequence
{
    [self unobserveSequence:_sequence];
    
    _sequence = sequence;
    
    [self observeSequence:_sequence];
    
    if ([sequence isText])
    {
        if (self.textPostViewController == nil)
        {
            self.textPostViewController = [VTextPostViewController newWithDependencyManager:self.dependencyManager];
            [self.previewView addSubview:self.textPostViewController.view];
            [self.previewView v_addFitToParentConstraintsToSubview:self.textPostViewController.view];
        }
        
        VAsset *textAsset = [self.sequence.firstNode textAsset];
        if ( textAsset.data != nil )
        {
            VAsset *imageAsset = [self.sequence.firstNode imageAsset];
            self.textPostViewController.text = textAsset.data;
            self.textPostViewController.color = [UIColor v_colorFromHexString:textAsset.backgroundColor];
            self.textPostViewController.imageURL = [NSURL URLWithString:imageAsset.data];
        }
    }
    else if ([sequence isPoll])
    {
        if (self.pollView == nil)
        {
            self.pollView = [[VPollView alloc] initWithFrame:CGRectZero];
            [self.previewView addSubview:self.pollView];
            [self.previewView v_addFitToParentConstraintsToSubview:self.pollView];
        }
        [self.pollView setImageURL:[[[sequence firstNode] answerA] previewMediaURL]
                     forPollAnswer:VPollAnswerA];
        [self.pollView setImageURL:[[[sequence firstNode] answerB] previewMediaURL]
                     forPollAnswer:VPollAnswerB];
        self.pollView.pollIcon = [self.dependencyManager imageForKey:@"orIcon"];
    }
    else if ([sequence isVideo])
    {
        [self.previewImageView fadeInImageAtURL:sequence.inStreamPreviewImageURL];
        self.playCircleImageView.hidden = NO;
    }
    else if ([sequence isImage])
    {
        [self.previewImageView fadeInImageAtURL:sequence.inStreamPreviewImageURL];
    }
    else if ([sequence isAnnouncement])
    {
        [self.previewImageView fadeInImageAtURL:sequence.inStreamPreviewImageURL];
    }
    else
    {
        NSAssert(false, @"Not setup for sequence!");
    }
    
    [self updateCommentsForSequence:_sequence];
}

- (UIImageView *)playCircleImageView
{
    if (_playCircleImageView == nil)
    {
        _playCircleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PlayCircle"]];
        _playCircleImageView.translatesAutoresizingMaskIntoConstraints = NO;
        UIImageView *playtriangle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PlayTriangle"]];
        playtriangle.translatesAutoresizingMaskIntoConstraints = NO;
        [_playCircleImageView addSubview:playtriangle];
        [_playCircleImageView v_addFitToParentConstraintsToSubview:playtriangle];
        [self.previewView addSubview:_playCircleImageView];
        [self.previewView v_addCenterToParentContraintsToSubview:_playCircleImageView];
    }
    return _playCircleImageView;
}

- (UIImageView *)previewImageView
{
    if (_previewImageView == nil)
    {
        _previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.previewView addSubview:_previewImageView];
        [self.previewView v_addFitToParentConstraintsToSubview:_previewImageView];
    }
    return _previewImageView;
}

#pragma mark - Observers

- (void)unobserveSequence:(VSequence *)sequence
{
    [self.KVOController unobserve:sequence.user
                          keyPath:NSStringFromSelector(@selector(name))];
    [self.KVOController unobserve:sequence.user
                          keyPath:NSStringFromSelector(@selector(pictureUrl))];
}

- (void)observeSequence:(VSequence *)sequence
{
    __weak typeof(self) welf = self;
    [self.KVOController observe:sequence.user
                       keyPaths:@[NSStringFromSelector(@selector(name))]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
    {
                              [welf updateUsernameForSequence:welf.sequence];
    }];
    [self.KVOController observe:sequence.user
                       keyPaths:@[NSStringFromSelector(@selector(pictureUrl))]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf updateUsernameForSequence:welf.sequence];
     }];
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    self.pollView.pollIcon = [dependencyManager imageForKey:@"orIcon"];
}

#pragma mark - VBackgroundContainer

- (UIView *)loadingBackgroundContainerView
{
    return self.previewView;
}

@end

#pragma mark - Categories

@implementation VAbstractStreamCollectionCell (Sizing)

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds
                                    sequence:(VSequence *)sequence
                           dependencyManager:(VDependencyManager *)dependencyManager
{
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds));
}

@end

@implementation VAbstractStreamCollectionCell (Actions)

- (void)selectedHashTag:(NSString *)hashTag
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(hashTag:tappedFromSequence:fromView:)])
    {
        [self.sequenceActionsDelegate hashTag:hashTag
                           tappedFromSequence:self.sequence
                                     fromView:self];
    }
}

- (void)comment
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willCommentOnSequence:fromView:)])
    {
        [self.sequenceActionsDelegate willCommentOnSequence:self.sequence
                                                   fromView:self];
    }
}

@end

@implementation VAbstractStreamCollectionCell (UpdateHooks)

- (void)updateCommentsForSequence:(VSequence *)sequence
{
    // Implement in subclasses
}

- (void)updateUsernameForSequence:(VSequence *)sequence
{
    // Implement in sublcasses
}

- (void)updateUserAvatarForSequence:(VSequence *)sequence
{
    // Implement in subclasses
}

@end