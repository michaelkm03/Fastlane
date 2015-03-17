//
//  VAssetLoader.m
//  victorious
//
//  Created by Michael Sena on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetLoader.h"

@import AVFoundation;

@interface VAssetLoader ()

@property (nonatomic, copy) VAssetLoaderCompletion completion;
@property (nonatomic, assign, readwrite) VAssetLoaderState state;
@property (nonatomic, strong) AVURLAsset *loadedAsset;
@property (nonatomic, strong) NSArray *keysToLoad;
@property (nonatomic, strong) NSError *error;

@end

@implementation VAssetLoader

- (instancetype)initWithAssetURL:(NSURL *)URL
                      keysToLoad:(NSArray *)keysToLoad
          prefersPreciseDuration:(BOOL)prefersPreciseDuration
                      completion:(VAssetLoaderCompletion)completion
{
    self = [super init];
    if (self)
    {
        _completion = completion;
        _loadedAsset = nil;
        _keysToLoad = keysToLoad;
        _loadedAsset = [[AVURLAsset alloc] initWithURL:URL options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@(prefersPreciseDuration),
                                                               AVURLAssetReferenceRestrictionsKey:@(AVAssetReferenceRestrictionForbidAll)}];
        _state = -1;
        [self transitionToNewState:VAssetLoaderStateLoading];
    }
    return self;
}

- (void)transitionToNewState:(VAssetLoaderState)newState
{
    if (self.state == newState)
    {
        return;
    }
    self.state = newState;

    switch (newState)
    {
        case VAssetLoaderStateLoading:
        {
            __weak typeof(self) welf = self;
            [self.loadedAsset loadValuesAsynchronouslyForKeys:self.keysToLoad
                                  completionHandler:^
             {
                 dispatch_async(dispatch_get_main_queue(), ^
                 {
                     [welf transitionToNewState:VAssetLoaderStateAllKeysLoaded];
                 });
             }];
            break;
        }
        case VAssetLoaderStateAllKeysLoaded:
        {
            for (NSString *keyToLoad in self.keysToLoad)
            {
                NSError *error = nil;
                switch ([self.loadedAsset statusOfValueForKey:keyToLoad error:&error])
                {
                    case AVKeyValueStatusUnknown:
                    case AVKeyValueStatusLoading:
                        [self transitionToNewState:VAssetLoaderStateLoading];
                        return;
                    case AVKeyValueStatusCancelled:
                    case AVKeyValueStatusFailed:
                        [self transitionToNewState:VAssetLoaderStateFailed];
                        return;
                    case AVKeyValueStatusLoaded:
                        break;
                }
                self.error = error;
            };
            if (self.completion != nil)
            {
                self.completion(self.error, self.loadedAsset);
            }
        }
            break;
        case VAssetLoaderStateFailed:
            if (self.completion != nil)
            {
                self.completion(self.error, nil);
            }
            break;
    }
}

@end
