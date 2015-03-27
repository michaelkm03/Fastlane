//
//  VLoopingAssetGenerator.h
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@class AVAsset, AVComposition;

@import CoreMedia; // For CMTime + CMTimeRange

typedef void (^VLoopingCompositionCompletionBlock)(NSError *error, AVComposition *loopedComposition);

typedef NS_ENUM(NSInteger, VLoopingCompositionState)
{
    VLoopingCompositionStateUnknown,
    VLoopingCompositionStateLoading,
    VLoopingCompositionStateGeneratingComposition,
    VLoopingCompositionStateLoaded,
    VLoopingCompositionStateFailed,
};

@interface VLoopingCompositionGenerator : NSObject

- (instancetype)initWithURL:(NSURL *)assetURL;

/**
 *  Cues the Looping Composition Generator to begin loading the asset specified in the initializer.
 */
- (void)startLoading;

/**
 *  Generates an AVComposition that composes the asset at assetURL of the media at assetURL.
 *
 *  @param trimRange A trim range within the time range of the original asset. Specifying an indefinite time range results in the original asset's full duration being used.
 *  @param minimumDuration A minimumd duration that this looping composition should be.
 *  @param completion A VLoopingCompositionCompletionBlock completion block. Must not be nil.
 */
- (void)setTrimRange:(CMTimeRange)trimRange
              CMTime:(CMTime)minimumDuration
      withCompletion:(VLoopingCompositionCompletionBlock)completion;

/**
 *  The duration of the original asset. Becomes available when state is:
 *  VLoopingCompositionStateLoaded or VLoopingCompositionStateGeneratingComposition.
 */
@property (nonatomic, readonly) CMTime assetOriginalDuration;

/**
 *  The current state of the looping composition generator KVO-Able.
 */
@property (nonatomic, assign, readonly) VLoopingCompositionState state;

/**
 *  An error if state is VLoopingCompositionStateFailed.
 */
@property (nonatomic, readonly) NSError *error;

@end
