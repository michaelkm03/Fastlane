//
//  VLoopingComposition.m
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLoopingAssetGenerator.h"

@import AVFoundation;

typedef NS_ENUM(NSInteger, VLoopingCompositionState)
{
    VLoopingCompositionStateUnkown,
    VLoopingCompositionStateLoading,
    VLoopingCompositionStateGeneratingComposition,
    VLoopingCompositionStateLoaded,
    VLoopingCompositionStateFailed,
};

@interface VLoopingAssetGenerator ()

@property (nonatomic, assign) VLoopingCompositionState state;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVComposition *tenMinuteLoopedComposition;
@property (nonatomic, assign) CMTimeRange trimRange;

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
    if (!CMTimeRangeContainsTimeRange(CMTimeRangeMake(kCMTimeZero, self.tenMinuteLoopedComposition.duration), trimRange))
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
    if (_state == newState)
    {
        VLog(@"already in newState: %@, trimRange: %@", @(newState), [NSValue valueWithCMTimeRange:self.trimRange]);
//        return;
    }
    
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
            AVMutableComposition *composition = [[AVMutableComposition alloc] init];
            CMTimeRange assetRange = kCMTimeRangeInvalid;
            CMTime startingOffset = CMTimeMake(200, 600);
            if (CMTIMERANGE_IS_VALID(self.trimRange))
            {
                assetRange = self.trimRange;
            }
            else
            {
                assetRange = CMTimeRangeMake(startingOffset, CMTimeSubtract(self.asset.duration, startingOffset));
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
                CMTime tenMinutes = CMTimeMake(10 * 60 * 600, 600);
                while (CMTIME_COMPARE_INLINE(composition.duration, <, tenMinutes))
                {
                    [composition insertTimeRange:assetRange
                                         ofAsset:self.asset
                                          atTime:composition.duration
                                           error:&compositionError];
                }
            }
            self.tenMinuteLoopedComposition = [composition copy];
            [self transitionToState:VLoopingCompositionStateLoaded];
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
    
    _state = newState;
}

@end
