//
//  VRepostButtonController.m
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VRepostButtonController.h"

// Frameworks
#import <FBKVOController.h>

// Model Helpers
#import "VSequence+Fetcher.h"

static CGFloat const kScaleActive               = 1.0f;
static CGFloat const kScaleScaledUp             = 1.4f;
static CGFloat const kRepostedDisabledAlpha     = 0.3f;

@interface VRepostButtonController ()

@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, weak) UIButton *repostButton;
@property (nonatomic, strong) UIImage *repostedImage;
@property (nonatomic, strong) UIImage *unRepostedImage;

@end

@implementation VRepostButtonController

- (instancetype)initWithSequence:(VSequence *)sequenceToObserve
                    repostButton:(UIButton *)repostButton
                   repostedImage:(UIImage *)repostedImage
                 unRepostedImage:(UIImage *)unRepostedImage
{
    self = [super init];
    if (self != nil)
    {
        _sequence = sequenceToObserve;
        _repostButton = repostButton;
        _repostedImage = [repostedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _unRepostedImage = [unRepostedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        [self setupKVO];
        [self updateRepostButtonForRepostState];
    }
    return self;
}

- (id)init
{
    NSAssert(false, @"Invalid initializer use initWithSequence:repostButton:repostedImage:unRepostedImage:");
    return nil;
}

#pragma mark - Property Accessors

- (void)setReposting:(BOOL)reposting
{
    _reposting = reposting;
    
    BOOL hasRespoted = [self.sequence.hasReposted boolValue];
    if (!hasRespoted)
    {
        self.repostButton.enabled = !reposting;
    }
}

#pragma mark - Public Methods

- (void)invalidate
{
    [self.KVOController unobserve:self.sequence
                          keyPath:NSStringFromSelector(@selector(hasReposted))];
}

#pragma mark - Internal

- (void)updateRepostButtonForRepostState
{
    BOOL hasRespoted = [self.sequence.hasReposted boolValue];
    
    if (hasRespoted)
    {
        [self.repostButton setImage:self.repostedImage
                           forState:UIControlStateNormal];
        self.repostButton.enabled = NO;
        self.repostButton.alpha = kRepostedDisabledAlpha;
    }
    else
    {
        [self.repostButton setImage:self.unRepostedImage
                           forState:UIControlStateNormal];
        self.repostButton.enabled = YES;
        self.repostButton.alpha = 1.0f;
    }
}

- (void)updateRepostWithAnimations:(void (^)())animations
                          onButton:(UIButton *)button
                          animated:(BOOL)animated
{
    if (!animated)
    {
        if (animations)
        {
            animations();
        }
        return;
    }
    
    if (self.isAnimating)
    {
        if (animations)
        {
            animations();
        }
        return;
    }
    
    self.isAnimating = YES;
    [UIView animateWithDuration:0.15f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:kNilOptions
                     animations:^
     {
         if (animations != nil)
         {
             animations();
         }
         button.transform = CGAffineTransformMakeScale( kScaleScaledUp, kScaleScaledUp );
         button.alpha = kRepostedDisabledAlpha;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.5f
                               delay:0.0f
              usingSpringWithDamping:0.8f
               initialSpringVelocity:0.9f
                             options:kNilOptions
                          animations:^
          {
              button.transform = CGAffineTransformMakeScale( kScaleActive, kScaleActive );
          }
                          completion:^(BOOL finished)
          {
              self.isAnimating = NO;
          }];
     }];
}

- (void)setupKVO
{
    __weak typeof(self) welf = self;
    [self.KVOController observe:self.sequence
                        keyPath:NSStringFromSelector(@selector(hasReposted))
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                          block:^(id observer, id object, NSDictionary *change)
     {
         NSNumber *oldValue = change[NSKeyValueChangeOldKey];
         NSNumber *newValue = change[NSKeyValueChangeNewKey];
         if ([newValue boolValue] == [oldValue boolValue])
         {
             return;
         }
         
         // Animate here
         [welf updateRepostWithAnimations:^
          {
              [welf updateRepostButtonForRepostState];
          }
                                 onButton:welf.repostButton
                                 animated:YES];
     }];
}

@end
