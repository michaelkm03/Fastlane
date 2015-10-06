//
//  VVideoBackground.m
//  victorious
//
//  Created by Michael Sena on 5/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoBackground.h"

// Dependencies
#import "VDependencyManager.h"

// Fetching
#import "VObjectManager+Sequence.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"

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
        
        NSString *sequenceId = [[dependencyManager stringForKey:kSequenceURLKey] lastPathComponent];
        if (sequenceId != nil)
        {
            [[VObjectManager sharedManager] fetchSequenceByID:sequenceId
                                                 successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
             {
                 VSequence *sequence = (VSequence *)resultObjects.firstObject;
                 VNode *node = (VNode *)[sequence firstNode];
                 VAsset *asset = [node httpLiveStreamingAsset];
                 if (asset.dataURL != nil)
                 {
                     VVideoPlayerItem *item = [[VVideoPlayerItem alloc] initWithURL:asset.dataURL];
                     item.muted = YES;
                     item.loop = YES;
                     item.remoteContentId = asset.remoteContentId;
                     [self.videoView setItem:item];
                 }
             }
                                                    failBlock:^(NSOperation *operation, NSError *error)
             {
                 self.videoView.backgroundColor = [UIColor blackColor];
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
