//
//  VCVideoPlayerView
//

#import "VCVideoPlayerView.h"

@interface VCVideoPlayerView ()

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) id             timeObserver;
@property (assign, nonatomic) NSUInteger     numberOfLoops;
@property (nonatomic)         BOOL           delegateNotifiedOfReadinessToPlay;

@end

static __weak VCVideoPlayerView *_currentPlayer = nil;

@implementation VCVideoPlayerView
{
    UIView * _loadingView;
}

+ (VCVideoPlayerView *)currentPlayer
{
    return _currentPlayer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }

    return self;
}

- (void)commonInit
{
    _player = [[AVPlayer alloc] init];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:self.playerLayer];
    [self.player addObserver:self
                  forKeyPath:NSStringFromSelector(@selector(currentItem))
                     options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                     context:NULL];
    [self.player addObserver:self
                  forKeyPath:NSStringFromSelector(@selector(rate))
                     options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                     context:NULL];

    __weak VCVideoPlayerView *weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 24)
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:^(CMTime time)
    {
        [weakSelf didPlay:time];
    }];

    self.clipsToBounds = YES;
    self.shouldLoop = NO;
}

- (void)dealloc
{
    [self removeObserverFromOldPlayerItem:_player.currentItem andAddObserverToPlayerItem:nil];
    [_player removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentItem))];
    [_player removeObserver:self forKeyPath:NSStringFromSelector(@selector(rate))];
    [_player removeTimeObserver:_timeObserver]; _timeObserver = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = self.layer.bounds;
}

- (void)setItemURL:(NSURL *)itemURL withLoopCount:(NSUInteger)loopCount
{
    _itemURL = itemURL;

    AVAsset *asset = [AVURLAsset assetWithURL:itemURL];
    AVPlayerItem *playerItem;

    if (loopCount > 1)
    {
        AVMutableComposition * composition = [AVMutableComposition composition];
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        
        for (NSUInteger i = 0; i < loopCount; i++)
        {
            [composition insertTimeRange:timeRange ofAsset:asset atTime:composition.duration error:nil];
        }
        
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        if ([tracks count])
        {
            AVAssetTrack *assetTrack = tracks[0];
            AVMutableCompositionTrack *compositionTrack = [composition mutableTrackCompatibleWithTrack:assetTrack];
            compositionTrack.preferredTransform = assetTrack.preferredTransform;
        }
        playerItem = [AVPlayerItem playerItemWithAsset:composition];
    }
    else
    {
        playerItem = [AVPlayerItem playerItemWithAsset:asset];
    }
    
    self.numberOfLoops = loopCount;
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
}

- (void)setItemURL:(NSURL *)itemURL
{
    [self setItemURL:itemURL withLoopCount:1];
}

- (void)setShouldLoop:(BOOL)shouldLoop
{
    _shouldLoop = shouldLoop;
    self.player.actionAtItemEnd = shouldLoop ? AVPlayerActionAtItemEndNone : AVPlayerActionAtItemEndPause;
}

- (BOOL)isPlaying
{
    return self.player.rate > 0;
}

- (void)setNaturalSize:(CGSize)naturalSize
{
    _naturalSize = naturalSize;
}

- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return playerItem.duration;
    }
    else
    {
        return kCMTimeInvalid;
    }
}

- (CMTime)playableDuration
{
	AVPlayerItem *item = self.player.currentItem;
	CMTime playableDuration = kCMTimeZero;
	
	if (item.status != AVPlayerItemStatusFailed)
    {
		if (item.loadedTimeRanges.count > 0)
        {
			NSValue * value = [item.loadedTimeRanges objectAtIndex:0];
			CMTimeRange timeRange = [value CMTimeRangeValue];
			
			playableDuration = timeRange.duration;
		}
	}
	
	return playableDuration;
}

- (void)didPlay:(CMTime)time
{
    Float64 ratio = 1.0f / (Float64)self.numberOfLoops;
    Float64 seconds = CMTimeGetSeconds(CMTimeMultiplyByFloat64(time, ratio));

    if ([self.delegate respondsToSelector:@selector(videoPlayer:didPlayToSeconds:)])
    {
        [self.delegate videoPlayer:self didPlayToSeconds:seconds];
    }

    if (CMTIME_COMPARE_INLINE(time, >=, self.player.currentItem.duration) ||
        ((self.endSeconds != 0) && (seconds > self.endSeconds)))
    {
        [self.player seekToTime:CMTimeMakeWithSeconds(self.startSeconds, NSEC_PER_SEC)];

        if (!self.shouldLoop)
        {
            [self.player pause];
        }
    }
}

- (void)removeObserverFromOldPlayerItem:(AVPlayerItem *)oldItem andAddObserverToPlayerItem:(AVPlayerItem *)currentItem
{
    if (oldItem && (id)oldItem != [NSNull null])
    {
        [oldItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];
        [oldItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(tracks))];
    }
    if (currentItem && (id)currentItem != [NSNull null])
    {
        [currentItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
        [currentItem addObserver:self forKeyPath:NSStringFromSelector(@selector(tracks)) options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
    }
}

- (void)refreshNaturalSizePropertyFromTrack:(AVPlayerItemTrack *)track inItem:(AVPlayerItem *)item
{
    VCVideoPlayerView * __weak weakSelf = self;
    AVAssetTrack *assetTrack = track.assetTrack;
    [assetTrack loadValuesAsynchronouslyForKeys:@[NSStringFromSelector(@selector(naturalSize))] completionHandler:^(void)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            if (item != weakSelf.player.currentItem)
            {
                return;
            }
            
            AVKeyValueStatus status = [assetTrack statusOfValueForKey:NSStringFromSelector(@selector(naturalSize)) error:nil];
            if (status == AVKeyValueStatusLoaded)
            {
                weakSelf.naturalSize = assetTrack.naturalSize;
            }
        });
    }];
}

#pragma mark - Key-Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.player && [keyPath isEqualToString:NSStringFromSelector(@selector(currentItem))])
    {
        self.delegateNotifiedOfReadinessToPlay = NO;
        AVPlayerItem *oldItem = change[NSKeyValueChangeOldKey];
        AVPlayerItem *newItem = change[NSKeyValueChangeNewKey];
        [self removeObserverFromOldPlayerItem:oldItem andAddObserverToPlayerItem:newItem];
    }
    else if (object == self.player && [keyPath isEqualToString:NSStringFromSelector(@selector(rate))])
    {
        NSNumber *oldRate = change[NSKeyValueChangeOldKey];
        NSNumber *newRate = change[NSKeyValueChangeNewKey];
        if ((id)oldRate != [NSNull null] && (id)newRate != [NSNull null])
        {

            if ([oldRate floatValue] == 0 && [newRate floatValue] != 0)
            {
                if (_currentPlayer != self)
                {
                    [_currentPlayer.player pause];
                    _currentPlayer = self;
                }
                if ([self.delegate respondsToSelector:@selector(videoPlayerWillStartPlaying:)])
                {
                    [self.delegate videoPlayerWillStartPlaying:self];
                }
            }
            else if ([oldRate floatValue] != 0 && [newRate floatValue] == 0)
            {
                if (_currentPlayer == self)
                {
                    _currentPlayer = nil;
                }
                if ([self.delegate respondsToSelector:@selector(videoPlayerWillStopPlaying:)])
                {
                    [self.delegate videoPlayerWillStopPlaying:self];
                }
            }
        }
    }
    else if (object == self.player.currentItem && [keyPath isEqualToString:NSStringFromSelector(@selector(status))])
    {
        NSNumber *status = change[NSKeyValueChangeNewKey];
        if ((id)status != [NSNull null] && status.integerValue == AVPlayerItemStatusReadyToPlay && !self.delegateNotifiedOfReadinessToPlay)
        {
            if ([self.delegate respondsToSelector:@selector(videoPlayerReadyToPlay:)])
            {
                [self.delegate videoPlayerReadyToPlay:self];
            }
            self.delegateNotifiedOfReadinessToPlay = YES;
        }
    }
    else if (object == self.player.currentItem && [keyPath isEqualToString:NSStringFromSelector(@selector(tracks))])
    {
        NSArray *tracks = change[NSKeyValueChangeNewKey];
        if ((id)tracks != [NSNull null])
        {
            for (AVPlayerItemTrack *track in tracks)
            {
                if ([track.assetTrack.mediaType isEqualToString:AVMediaTypeVideo])
                {
                    [self refreshNaturalSizePropertyFromTrack:track inItem:object];
                    break;
                }
            }
        }
    }
}

@end
