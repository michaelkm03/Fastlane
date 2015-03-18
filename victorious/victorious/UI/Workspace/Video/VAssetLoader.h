//
//  VAssetLoader.h
//  victorious
//
//  Created by Michael Sena on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVAsset;

/**
 *  Typedef'd completion block for asset loading.
 */
typedef void (^VAssetLoaderCompletion)(NSError *error, AVAsset *loadedAsset);

/**
 *  Enum for the state representation of the asset loader.
 */
typedef NS_ENUM(NSInteger, VAssetLoaderState)
{
    VAssetLoaderStateLoading,
    VAssetLoaderStateAllKeysLoaded,
    VAssetLoaderStateFailed,
};

/**
 *  VAssetLoader provides some convenience in loading assets. It only calls its completion block once for all keys.
 */
@interface VAssetLoader : NSObject

/**
 *  Completion is called on the main queue.
 *
 *  @param URL A url for a given audio/video asset.
 *  @param keysToLoad The AVAsset keys (as NSStrings) to load.
 *  @param prefersPreciseDuration Whether or not to use precise duration. See AVAsset documentation.
 *  @param completion An optional completion block.
 *
 */
- (instancetype)initWithAssetURL:(NSURL *)URL
                      keysToLoad:(NSArray *)keysToLoad
          prefersPreciseDuration:(BOOL)prefersPreciseDuration
                      completion:(VAssetLoaderCompletion)completion;

/**
 *  A loaded AVAsset. Will be nil unless state is VAssetLoaderStateAllKeysLoaded.
 */
@property (nonatomic, readonly) AVAsset *loadedAsset;

/**
 *  The current state of the asset loader.
 */
@property (nonatomic, readonly) VAssetLoaderState state;

@end
