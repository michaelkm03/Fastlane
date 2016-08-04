//
//  VVideoBackground.m
//  victorious
//
//  Created by Michael Sena on 5/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoBackground.h"
#import "VDependencyManager.h"
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
#warning Fix me!
//        _videoView = [[VVideoView alloc] initWithFrame:CGRectZero];
//        _videoView.delegate = self;
//        _videoView.backgroundColor = [UIColor blackColor];
//        
//        NSString *sequenceURL = [dependencyManager stringForKey:kSequenceURLKey];
//        NSString *sequenceID = [sequenceURL lastPathComponent];
//        if (sequenceID != nil)
//        {
//            SequenceFetchOperation *operation = [[SequenceFetchOperation alloc] initWithSequenceID:sequenceID streamID:nil];
//            [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
//             {
//                 VSequence *sequence = operation.result;
//                 if ( error == nil && sequence != nil )
//                 {
//                     VNode *node = (VNode *)[sequence firstNode];
//                     VAsset *asset = [node httpLiveStreamingAsset];
//                     if (asset.dataURL != nil)
//                     {
//                         VVideoPlayerItem *item = [[VVideoPlayerItem alloc] initWithURL:asset.dataURL];
//                         item.muted = YES;
//                         item.loop = YES;
//                         [self.videoView setItem:item];
//                     }
//                 }
//             }];
//        }
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
