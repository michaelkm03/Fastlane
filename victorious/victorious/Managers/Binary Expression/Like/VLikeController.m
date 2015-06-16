//
//  VExpressionController.m
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLikeController.h"
#import <KVOController/FBKVOController.h>
#import "VSequence.h"
#import "VLikeHelper.h"
#import "VSequence+Fetcher.h"

@interface VLikeController()

@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, strong) UIControl<VBinaryExpressionControl> *control;
@property (nonatomic, strong) id<VBinaryExpressionCountDisplay> countDisplay;

@end

@implementation VLikeController

- (void)dealloc
{
    [self stopObserving];
}

- (void)startObservingWithSequence:(VSequence *)sequence
                           control:(UIControl<VBinaryExpressionControl> *)control
                      countDisplay:(id<VBinaryExpressionCountDisplay>)countDisplay
{
    NSParameterAssert( control != nil );
    NSParameterAssert( sequence != nil );
    
    [self stopObserving];
    
    self.sequence = sequence;
    self.control = control;
    self.countDisplay = countDisplay;
    
    [self.control addTarget:self
                    action:@selector(onLikeButtonSelected:)
          forControlEvents:UIControlEventTouchUpInside];
    
    __weak typeof(self) welf = self;
    
    [self.KVOController observe:self.sequence keyPath:NSStringFromSelector(@selector(isLikedByMainUser))
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf onObservedPropertyChanged];
     }];
    
    if ( self.countDisplay != nil )
    {
        [self.KVOController observe:self.sequence keyPath:NSStringFromSelector(@selector(likeCount))
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                              block:^(id observer, id object, NSDictionary *change)
         {
             [welf onObservedPropertyChanged];
         }];
    }
    
    [self onObservedPropertyChanged];
}

- (void)stopObserving
{
    [self.KVOController unobserve:self.sequence];
}

- (void)onLikeButtonSelected:(UIButton<VBinaryExpressionControl> *)sender
{
    id <VLikeResponder> responder = [[sender nextResponder] targetForAction:@selector(likeHelper) withSender:self];
    
    VLikeHelper *likeHelper = responder.likeHelper;
    NSAssert( likeHelper != nil && responder != nil, @"Could not find a responder to provide VLikeHelper instance." );
    [likeHelper toggleLikeWithSequence:self.sequence completion:^(VSequence *sequence) {}];
}

- (void)onObservedPropertyChanged
{
    BOOL isLiked = self.sequence.isLikedByMainUser.boolValue;
    [self.control setActive:isLiked];
    
    if ( self.countDisplay != nil )
    {
        NSInteger count = self.sequence.likeCount.integerValue;
        [self.countDisplay setCount:count];
    }
}

@end
