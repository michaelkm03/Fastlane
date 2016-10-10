//
//  VVideoUtils.m
//  victorious
//
//  Created by Patrick Lynch on 1/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoUtils.h"
#import "VConstants.h"
@import KVOController;

@implementation VVideoUtils

- (void)createPlayerItemWithURL:(NSURL *)itemURL
                           loop:(BOOL)loop
                  readyCallback:(void(^)(AVPlayerItem *, NSURL *composedItemURL, CMTime originalAssetDuration))onReady
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^
    {
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:itemURL
                                                options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@(NO)}];
        [asset loadValuesAsynchronouslyForKeys:@[NSStringFromSelector(@selector(duration))]
                             completionHandler:^
         {
             AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
             dispatch_async( dispatch_get_main_queue(), ^
             {
                 if ( onReady != nil )
                 {
                     onReady( playerItem, itemURL, asset.duration );
                 }
             });
         }];
    });
}

@end

