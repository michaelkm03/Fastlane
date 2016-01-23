//
//  VVideoBackground.m
//  victorious
//
//  Created by Michael Sena on 5/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoBackground.h"
#import "VDependencyManager.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"
#import "victorious-swift.h"

static NSString * const kSequenceURLKey = @"sequenceURL";

@interface VVideoBackground () <VVideoPlayerDelegate>

@property (nonatomic, strong) VVideoView *videoView;

@end

@implementation VVideoBackground

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self)
    {
        _videoView = [[VVideoView alloc] initWithFrame:CGRectZero];
        _videoView.delegate = self;
        _videoView.backgroundColor = [UIColor blackColor];
        
        NSString *sequenceURL = [dependencyManager stringForKey:kSequenceURLKey];
        NSString *sequenceID = [sequenceURL lastPathComponent];
        if (sequenceID != nil)
        {
            SequenceFetchOperation *operation = [[SequenceFetchOperation alloc] initWithSequenceID:sequenceID];
            [operation queueOn:operation.defaultQueue completionBlock:^(NSError *_Nullable error)
             {
                 VSequence *sequence = operation.result;
                 if ( error == nil && sequence != nil )
                 {
                     VNode *node = (VNode *)[sequence firstNode];
                     VAsset *asset = [node httpLiveStreamingAsset];
                     if (asset.dataURL != nil)
                     {
                         VVideoPlayerItem *item = [[VVideoPlayerItem alloc] initWithURL:asset.dataURL];
                         item.muted = YES;
                         item.loop = YES;
                         [self.videoView setItem:item];
                     }
                 }
             }];
        }
    }
    return self;
}

#pragma mark - Overrides

- (UIView *)viewForBackground
{
    return self.videoView;
}

#pragma mark - VVideoPlayerDelegate

- (void)videoPlayerDidBecomeReady:(id<VVideoPlayer>)videoPlayer
{
    [self.videoView playFromStart];
}

@end
