//
//  VTrimLoopingPlayerViewController.m
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTrimLoopingPlayerViewController.h"
#import "VLoopingAssetGenerator.h"
#import "VPlayerView.h"
#import <KVOController/FBKVOController.h>

@import AVFoundation;

@interface VTrimLoopingPlayerViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) VLoopingAssetGenerator *loopingAssetGenerator;

@end

@implementation VTrimLoopingPlayerViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _player = [[AVPlayer alloc] init];

    }
    return self;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    self.view = [[VPlayerView alloc] initWithPlayer:self.player];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.KVOController observe:self.player
                        keyPath:NSStringFromSelector(@selector(status))
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                          block:^(id observer, id object, NSDictionary *change)
    {
        if (self.player.status != AVPlayerStatusReadyToPlay)
        {
            return;
        }
        [self.player seekToTime:kCMTimeZero
              completionHandler:^(BOOL finished)
         {
             if (finished)
             {
                 [self.player play];
             }
         }];
    }];
}

#pragma mark - Public Methods

- (void)setMediaURL:(NSURL *)mediaURL
{
    _mediaURL = [mediaURL copy];
    
    self.loopingAssetGenerator = [[VLoopingAssetGenerator alloc] initWithURL:mediaURL];
    __weak typeof(self) welf = self;
    self.loopingAssetGenerator.loopedAssetBecameAvailable = ^void(AVAsset *loopedAsset)
    {
        __strong typeof(welf) strongSelf = welf;
        if (strongSelf == nil)
        {
            return;
        }
        [strongSelf playWithNewAsset:loopedAsset];
    };;
    [self.loopingAssetGenerator startLoading];
}

- (void)setTrimRange:(CMTimeRange)trimRange
{
    VLog(@"%@", [NSValue valueWithCMTimeRange:trimRange]);
    if (CMTimeRangeEqual(_trimRange, trimRange))
    {
        return;
    }
    _trimRange = trimRange;
    __weak typeof(self) welf = self;
    [self.loopingAssetGenerator setTrimRange:trimRange
                              withCompletion:^(AVAsset *loopedAsset)
     {
         __strong typeof(welf) strongSelf = welf;
         if (strongSelf == nil)
         {
             return;
         }
         [strongSelf playWithNewAsset:loopedAsset];
     }];
}

#pragma mark - Private Methods

- (void)playWithNewAsset:(AVAsset *)asset
{
    AVPlayerItem *playerItemWithAsset = [AVPlayerItem playerItemWithAsset:asset];
    [self.player replaceCurrentItemWithPlayerItem:playerItemWithAsset];
}

@end
