//
//  VLoopingComposition.m
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLoopingAssetGenerator.h"

@import AVFoundation;

@interface VLoopingAssetGenerator ()

@property (nonatomic, assign, readwrite) VLoopingCompositionState state;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVComposition *tenMinuteLoopedComposition;
@property (nonatomic, assign) CMTimeRange trimRange;

@property (nonatomic, strong) dispatch_queue_t compositionCreationQueue;
@property (nonatomic, assign) BOOL wantsNewCompositionAfterCurrentFinishes;

@end

@implementation VLoopingAssetGenerator

- (instancetype)initWithURL:(NSURL *)assetURL
{
    NSParameterAssert(assetURL != nil);
    self = [super init];
    if (self)
    {
        _state = VLoopingCompositionStateUnkown;
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
      withCompletion:(void (^)(AVAsset *loopedAsset))completion
{
    if (!CMTIMERANGE_IS_VALID(trimRange))
    {
        return;
    }
    if (!CMTimeRangeContainsTimeRange(CMTimeRangeMake(kCMTimeZero, self.asset.duration), trimRange))
    {
        return;
    }
    
    self.trimRange = trimRange;
    self.loopedAssetBecameAvailable = completion;
    [self transitionToState:VLoopingCompositionStateGeneratingComposition];
}

#pragma mark - State Management

- (void)transitionToState:(VLoopingCompositionState)newState
{
    if (self.state == newState)
    {
        VLog(@"already in newState: %@", @(newState));
        if (newState == VLoopingCompositionStateGeneratingComposition)
        {
            self.wantsNewCompositionAfterCurrentFinishes = YES;
        }
        return;
    }
    self.state = newState;
    
    switch (newState)
    {
        case VLoopingCompositionStateUnkown:
            break;
        case VLoopingCompositionStateLoading:
        {
            NSAssert(self.asset != nil, @"We need an asset to load!");
            
            __weak typeof(self) welf = self;
            [_asset loadValuesAsynchronouslyForKeys:@[NSStringFromSelector(@selector(duration))]
                                  completionHandler:^
             {
                 __strong typeof(welf) strongSelf = welf;
                 if (!strongSelf)
                 {
                     return;
                 }
                 NSError *error = nil;
                 AVKeyValueStatus durationStatus = [welf.asset statusOfValueForKey:NSStringFromSelector(@selector(duration))
                                                                             error:&error];
                 if (error != nil)
                 {
                     [strongSelf transitionToState:VLoopingCompositionStateFailed];
                 }
                 switch (durationStatus)
                 {
                     case AVKeyValueStatusCancelled:
                     case AVKeyValueStatusFailed:
                     case AVKeyValueStatusLoading:
                     case AVKeyValueStatusUnknown:
                         [strongSelf transitionToState:VLoopingCompositionStateUnkown];
                         break;
                     case AVKeyValueStatusLoaded:
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
                    // 20 seconds
                    CMTime tenMinutes = CMTimeMake( 20 * 600, 600);
                    while (CMTIME_COMPARE_INLINE(composition.duration, <, tenMinutes))
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
                    self.tenMinuteLoopedComposition = [composition copy];
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
            NSAssert(self.tenMinuteLoopedComposition != nil, @"We should have our composition here!");
            if (self.loopedAssetBecameAvailable != nil)
            {
                self.loopedAssetBecameAvailable(self.tenMinuteLoopedComposition);
            }
        }
        case VLoopingCompositionStateFailed:
            break;
    }
}

- (void)setState:(VLoopingCompositionState)state
{
    VLog(@"%@", @(state));
    if (state == VLoopingCompositionStateGeneratingComposition)
    {
        
    }
    _state = state;
}

@end
