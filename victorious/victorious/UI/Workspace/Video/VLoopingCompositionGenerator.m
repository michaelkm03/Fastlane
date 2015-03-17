//
//  VLoopingComposition.m
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLoopingCompositionGenerator.h"

@import AVFoundation;

@interface VLoopingCompositionGenerator ()

@property (nonatomic, assign, readwrite) CMTime assetOriginalDuration;
@property (nonatomic, strong, readwrite) NSError *error;

@property (nonatomic, assign, readwrite) VLoopingCompositionState state;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVComposition *loopedComposition;
@property (nonatomic, assign) CMTimeRange trimRange;

@property (nonatomic, strong) dispatch_queue_t compositionCreationQueue;
@property (nonatomic, assign) BOOL wantsNewCompositionAfterCurrentFinishes;

@property (nonatomic, copy) VLoopingCompositionCompletionBlock completionBlock;

@property (nonatomic, assign) CMTime minDuration;

@end

@implementation VLoopingCompositionGenerator

- (instancetype)initWithURL:(NSURL *)assetURL
{
    NSParameterAssert(assetURL != nil);
    self = [super init];
    if (self)
    {
        _assetOriginalDuration = kCMTimeZero;
        _error = nil;
        _state = VLoopingCompositionStateUnknown;
        _asset = [AVURLAsset URLAssetWithURL:assetURL
                                     options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES,
                                               AVURLAssetReferenceRestrictionsKey:@(AVAssetReferenceRestrictionForbidAll)}];
        _compositionCreationQueue = dispatch_queue_create("com.getVictorious.compositionCreateQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Public Methods

- (void)startLoading
{
    [self transitionToState:VLoopingCompositionStateLoading];
}

- (void)setTrimRange:(CMTimeRange)trimRange
              CMTime:(CMTime)minimumDuration
      withCompletion:(VLoopingCompositionCompletionBlock)completion
{
    NSParameterAssert(completion != nil);
    if (!CMTIMERANGE_IS_VALID(trimRange))
    {
        return;
    }
    trimRange = CMTimeRangeGetIntersection(CMTimeRangeMake(kCMTimeZero, self.assetOriginalDuration), trimRange);
    
    self.minDuration = minimumDuration;
    self.completionBlock = completion;
    self.trimRange = trimRange;
    
    switch (self.state)
    {
        case VLoopingCompositionStateUnknown:
        case VLoopingCompositionStateLoading:
        case VLoopingCompositionStateGeneratingComposition:
            [self startLoading];
            self.wantsNewCompositionAfterCurrentFinishes = YES;
            break;
        case VLoopingCompositionStateLoaded:
        case VLoopingCompositionStateFailed:
            [self transitionToState:VLoopingCompositionStateGeneratingComposition];
            break;
    }
    
}

#pragma mark - State Management

- (void)transitionToState:(VLoopingCompositionState)newState
{
    if (self.state == newState)
    {
        if (newState == VLoopingCompositionStateGeneratingComposition)
        {
            self.wantsNewCompositionAfterCurrentFinishes = YES;
        }
        return;
    }
    self.state = newState;
    
    switch (newState)
    {
        case VLoopingCompositionStateUnknown:
            break;
        case VLoopingCompositionStateLoading:
        {
            NSAssert(self.asset != nil, @"We need an asset to load!");
            
            __weak typeof(self) welf = self;
            [_asset loadValuesAsynchronouslyForKeys:@[NSStringFromSelector(@selector(duration))]
                                  completionHandler:^
             {
                 __strong typeof(welf) strongSelf = welf;
                 if (strongSelf == nil)
                 {
                     return;
                 }
                 NSError *error = nil;
                 AVKeyValueStatus durationStatus = [strongSelf.asset statusOfValueForKey:NSStringFromSelector(@selector(duration))
                                                                             error:&error];
                 if (error != nil)
                 {
                     strongSelf.error = error;
                     [strongSelf transitionToState:VLoopingCompositionStateFailed];
                 }
                 switch (durationStatus)
                 {
                     case AVKeyValueStatusCancelled:
                     case AVKeyValueStatusFailed:
                     case AVKeyValueStatusLoading:
                     case AVKeyValueStatusUnknown:
                         [strongSelf transitionToState:VLoopingCompositionStateUnknown];
                         break;
                     case AVKeyValueStatusLoaded:
                         strongSelf.assetOriginalDuration = strongSelf.asset.duration;
                         [strongSelf transitionToState:VLoopingCompositionStateGeneratingComposition];
                         break;
                 }
             }];
        }
             break;
        case VLoopingCompositionStateGeneratingComposition:
        {
            void (^createComposition)(CMTimeRange trimRange) = ^void(CMTimeRange trimRange)
            {
                AVMutableComposition *composition = [[AVMutableComposition alloc] init];
                CMTimeRange assetRange = kCMTimeRangeInvalid;
                if (CMTIMERANGE_IS_VALID(trimRange))
                {
                    assetRange = trimRange;
                }
                else
                {
                    assetRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
                }
                
                // Ensure we are within the asset's time range
                assetRange = CMTimeRangeGetIntersection(CMTimeRangeMake(kCMTimeZero, self.asset.duration), assetRange);
                
                NSError *compositionError = nil;
                BOOL initialInsertSucceeded = [composition insertTimeRange:assetRange
                                                                   ofAsset:self.asset
                                                                    atTime:composition.duration
                                                                     error:&compositionError];
                if (initialInsertSucceeded)
                {
                    while (CMTIME_COMPARE_INLINE(composition.duration, <, self.minDuration))
                    {
                        [composition insertTimeRange:assetRange
                                             ofAsset:self.asset
                                              atTime:composition.duration
                                               error:&compositionError];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    if (self.wantsNewCompositionAfterCurrentFinishes)
                    {
                        self.wantsNewCompositionAfterCurrentFinishes = NO;
                        self.state = VLoopingCompositionStateLoading;
                        [self transitionToState:VLoopingCompositionStateGeneratingComposition];
                        return;
                    }
                    self.loopedComposition = [composition copy];
                    [self transitionToState:VLoopingCompositionStateLoaded];
                });
            };
            
            CMTimeRange trimRange = self.trimRange;
            dispatch_async(self.compositionCreationQueue, ^
            {
                createComposition(trimRange);
            });
        }
            break;
        case VLoopingCompositionStateLoaded:
        {
            NSAssert(self.loopedComposition != nil, @"We should have our composition here!");
            if (self.completionBlock != nil)
            {
                self.completionBlock(nil, self.loopedComposition);
            }
        }
        case VLoopingCompositionStateFailed:
            break;
    }
}

@end
