//
//  VCVideoPlayerViewController.m
//

#import "VCVideoPlayerToolbarView.h"
#import "VCVideoPlayerViewController.h"
#import "VElapsedTimeFormatter.h"
#import "VVideoDownloadProgressIndicatorView.h"

@interface VCVideoPlayerViewController ()

@property (nonatomic, weak)   VCVideoPlayerToolbarView *toolbarView;
@property (nonatomic, weak)   UITapGestureRecognizer   *videoFrameTapGesture;
@property (nonatomic, strong) VElapsedTimeFormatter    *timeFormatter;
@property (nonatomic)         BOOL                      toolbarAnimating;
@property (nonatomic)         BOOL                      sliderTouchActive;
@property (nonatomic, strong) AVPlayerLayer            *playerLayer;
@property (nonatomic, strong) id                        timeObserver;
@property (nonatomic)         BOOL                      delegateNotifiedOfReadinessToPlay;
@property (nonatomic)         CMTime                    startTime;
@property (nonatomic)         CMTime                    endTime;
@property (nonatomic)         BOOL                      didPlayToEnd;
@property (nonatomic, strong) NSTimer                  *toolbarHideTimer;
@property (nonatomic, strong) NSDate                   *toolbarShowDate;

@end

static const CGFloat        kToolbarHeight            = 41.0f;
static const NSTimeInterval kToolbarHideDelay         =  5.0;
static const NSTimeInterval kToolbarAnimationDuration =  0.2;

static __weak VCVideoPlayerViewController *_currentPlayer = nil;

@implementation VCVideoPlayerViewController

+ (VCVideoPlayerViewController *)currentPlayer
{
    return _currentPlayer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.shouldShowToolbar = YES;
        self.shouldLoop = NO;
        self.startTime = CMTimeMakeWithSeconds(0, 1);
        self.player = [[AVPlayer alloc] init];
        [self.player addObserver:self
                      forKeyPath:NSStringFromSelector(@selector(currentItem))
                         options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         context:NULL];
        [self.player addObserver:self
                      forKeyPath:NSStringFromSelector(@selector(rate))
                         options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                         context:NULL];

        VCVideoPlayerViewController * __weak weakSelf = self;
        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 24)
                                                                      queue:dispatch_get_main_queue()
                                                                 usingBlock:^(CMTime time)
        {
            [weakSelf didPlayToTime:time];
        }];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserverFromOldPlayerItem:_player.currentItem andAddObserverToPlayerItem:nil];
    [_player removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentItem))];
    [_player removeObserver:self forKeyPath:NSStringFromSelector(@selector(rate))];
    [_player removeTimeObserver:_timeObserver]; _timeObserver = nil;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.clipsToBounds = YES;

    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.playerLayer];
    
    VCVideoPlayerToolbarView *toolbarView = [VCVideoPlayerToolbarView toolbarFromNibWithOwner:self];
    toolbarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toolbarView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolbarView(==toolbarHeight)]|"
                                                                      options:0
                                                                      metrics:@{ @"toolbarHeight": @(kToolbarHeight) }
                                                                        views:NSDictionaryOfVariableBindings(toolbarView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbarView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(toolbarView)]];
    self.toolbarView = toolbarView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoFrameTapped:)];
    [self.view addGestureRecognizer:tap];
    self.videoFrameTapGesture = tap;
    
    self.timeFormatter = [[VElapsedTimeFormatter alloc] init];
    self.toolbarView.elapsedTimeLabel.text = [self.timeFormatter stringForCMTime:kCMTimeInvalid];
    self.toolbarView.remainingTimeLabel.text = [self.timeFormatter stringForCMTime:kCMTimeInvalid];
    
    self.overlayView = [[UIView alloc] init];
    
    [self updateViewForShowToolbarValue];
}

- (void)viewDidLayoutSubviews
{
    [CATransaction begin];
    CAAnimation *boundsAnimation = [self.view.layer animationForKey:NSStringFromSelector(@selector(bounds))];
    if (boundsAnimation)
    {
        [CATransaction setAnimationDuration:boundsAnimation.duration];
        [CATransaction setAnimationTimingFunction:boundsAnimation.timingFunction];
    }
    
    self.playerLayer.frame = self.view.layer.bounds;
    [CATransaction commit];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.player pause];
}

#pragma mark - Properties

- (void)setPlayer:(AVPlayer *)player
{
    _player = player;
}

- (void)setItemURL:(NSURL *)itemURL withLoopCount:(NSUInteger)loopCount
{
    _itemURL = itemURL;
    _loopCount = loopCount;
    
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

- (void)setStartSeconds:(Float64)startSeconds
{
    self.startTime = CMTimeMakeWithSeconds(startSeconds, NSEC_PER_SEC);
}

- (void)setEndSeconds:(Float64)endSeconds
{
    if (!endSeconds)
    {
        self.endTime = kCMTimeInvalid;
    }
    else
    {
        self.endTime = CMTimeMakeWithSeconds(endSeconds, NSEC_PER_SEC);
    }
}

- (Float64)startSeconds
{
    return CMTimeGetSeconds(self.startTime);
}

- (Float64)endSeconds
{
    return CMTimeGetSeconds(self.endTime);
}

- (BOOL)isPlaying
{
    return self.player.rate > 0;
}

- (void)setNaturalSize:(CGSize)naturalSize
{
    _naturalSize = naturalSize;
}

- (void)setShouldShowToolbar:(BOOL)shouldShowToolbar
{
    _shouldShowToolbar = shouldShowToolbar;
    if ([self isViewLoaded])
    {
        [self updateViewForShowToolbarValue];
    }
}

- (void)updateViewForShowToolbarValue
{
    self.toolbarView.hidden = !self.shouldShowToolbar;
    self.videoFrameTapGesture.enabled = self.shouldShowToolbar;
}

- (void)setOverlayView:(UIView *)overlayView
{
    if (_overlayView)
    {
        [_overlayView removeFromSuperview];
    }
    _overlayView = overlayView;
    _overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:_overlayView belowSubview:self.toolbarView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[overlayView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(overlayView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[overlayView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(overlayView)]];
}

#pragma mark - Toolbar

- (void)toggleToolbarHidden
{
    if (self.toolbarAnimating || !self.shouldShowToolbar)
    {
        return;
    }
    if (self.toolbarView.hidden)
    {
        self.toolbarView.hidden = NO;
        self.overlayView.hidden = NO;
        self.toolbarView.alpha  =  0;
        self.overlayView.alpha  =  0;
        self.toolbarAnimating = YES;
        [UIView animateWithDuration:kToolbarAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(void)
        {
            self.toolbarView.alpha = 1.0f;
            self.overlayView.alpha = 1.0f;
        }
                         completion:^(BOOL finished)
        {
            self.toolbarAnimating = NO;
        }];
    }
    else
    {
        [self stopToolbarTimer];
        self.toolbarAnimating = YES;
        [UIView animateWithDuration:kToolbarAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(void)
         {
             self.toolbarView.alpha = 0;
             self.overlayView.alpha = 0;
         }
                         completion:^(BOOL finished)
         {
             self.toolbarView.alpha  = 1.0f;
             self.overlayView.alpha  = 1.0f;
             self.toolbarView.hidden =  YES;
             self.overlayView.hidden =  YES;
             self.toolbarAnimating = NO;
         }];
    }
}

- (void)startToolbarTimer
{
    self.toolbarShowDate = [NSDate date];
    [self.toolbarHideTimer invalidate]; // just in case--losing a reference to an active timer would be bad
    self.toolbarHideTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(toolbarTimerFired) userInfo:nil repeats:YES];
}

- (void)stopToolbarTimer
{
    [self.toolbarHideTimer invalidate];
    self.toolbarHideTimer = nil;
}

- (void)toolbarTimerFired
{
    if (self.toolbarView.hidden)
    {
        [self stopToolbarTimer];
    }
    else if (!self.sliderTouchActive && [self.toolbarShowDate timeIntervalSinceNow] <= -kToolbarHideDelay)
    {
        [self stopToolbarTimer];
        [self toggleToolbarHidden];
    }
}

#pragma mark -

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

- (void)didPlayToTime:(CMTime)time
{
    if (!self.sliderTouchActive)
    {
        Float64 durationInSeconds = CMTimeGetSeconds([self playerItemDuration]);
        Float64 timeInSeconds     = CMTimeGetSeconds(time);
        float percentElapsed    = timeInSeconds / durationInSeconds;
        self.toolbarView.slider.value = percentElapsed;
    }
    
    CMTime duration = [self playerItemDuration];
    Float64 playedSeconds = round(CMTimeGetSeconds(time));
    Float64 durationSeconds = round(CMTimeGetSeconds(duration));
    self.toolbarView.elapsedTimeLabel.text = [self.timeFormatter stringForCMTime:CMTimeMakeWithSeconds(playedSeconds, time.timescale)];
    self.toolbarView.remainingTimeLabel.text = [self.timeFormatter stringForCMTime:CMTimeMakeWithSeconds(durationSeconds - playedSeconds, duration.timescale)];
    
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didPlayToTime:)])
    {
        [self.delegate videoPlayer:self didPlayToTime:time];
    }

    if (CMTIME_IS_VALID(self.endTime) && CMTIME_COMPARE_INLINE(time, >=, self.endTime))
    {
        if (self.shouldLoop)
        {
            if (CMTIME_IS_VALID(self.startTime))
            {
                [self.player seekToTime:self.startTime];
            }
            else
            {
                [self.player seekToTime:CMTimeMake(0, 1)];
            }
        }
        else
        {
            [self.player pause];
        }
    }
}

- (void)removeObserverFromOldPlayerItem:(AVPlayerItem *)oldItem andAddObserverToPlayerItem:(AVPlayerItem *)currentItem
{
    if ([oldItem isKindOfClass:[AVPlayerItem class]])
    {
        [oldItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];
        [oldItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(tracks))];
        [oldItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(loadedTimeRanges))];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:oldItem];
    }
    if ([currentItem isKindOfClass:[AVPlayerItem class]])
    {
        [currentItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status))           options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
        [currentItem addObserver:self forKeyPath:NSStringFromSelector(@selector(tracks))           options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
        [currentItem addObserver:self forKeyPath:NSStringFromSelector(@selector(loadedTimeRanges)) options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:)      name:AVPlayerItemDidPlayToEndTimeNotification      object:currentItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemFailedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:currentItem];
    }
}

- (void)refreshNaturalSizePropertyFromTrack:(AVPlayerItemTrack *)track inItem:(AVPlayerItem *)item
{
    VCVideoPlayerViewController * __weak weakSelf = self;
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

#pragma mark - Actions

- (IBAction)playButtonTapped:(UIButton *)sender
{
    self.toolbarShowDate = [NSDate date];
    if ([self isPlaying])
    {
        [self.player pause];
    }
    else
    {
        [self.player play];
    }
}

- (void)videoFrameTapped:(UITapGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:self.view];
    if (!CGRectContainsPoint(self.toolbarView.frame, touchPoint))
    {
        if (self.toolbarView.hidden && [self isPlaying])
        {
            [self startToolbarTimer];
        }
        [self toggleToolbarHidden];
    }
}

- (IBAction)sliderTouchDown:(UISlider *)sender
{
    self.sliderTouchActive = YES;
}

- (IBAction)sliderTouchUp:(UISlider *)sender
{
    self.toolbarShowDate = [NSDate date];
    self.sliderTouchActive = NO;
    CMTime duration = [self playerItemDuration];
    [self.player seekToTime:CMTimeMultiplyByFloat64(duration, self.toolbarView.slider.value)];
}

- (IBAction)sliderTouchCancelled:(id)sender
{
    self.sliderTouchActive = NO;
}

#pragma mark - NSNotification handlers

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification
{
    if (notification.object == self.player.currentItem)
    {
        if (self.shouldLoop)
        {
            if (CMTIME_IS_VALID(self.startTime))
            {
                [self.player seekToTime:self.startTime];
            }
            else
            {
                [self.player seekToTime:CMTimeMake(0, 1)];
            }
        }
        else
        {
            self.toolbarView.slider.value = 1.0f;
            self.didPlayToEnd = YES;
            self.player.rate = 0;
            if ([self.delegate respondsToSelector:@selector(videoPlayerDidReachEndOfVideo:)])
            {
                [self.delegate videoPlayerDidReachEndOfVideo:self];
            }
        }
    }
}

- (void)playerItemFailedToPlayToEndTime:(NSNotification *)notification
{
    if (notification.object == self.player.currentItem)
    {
        self.player.rate = 0;
    }
}

#pragma mark - Key-Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.player && [keyPath isEqualToString:NSStringFromSelector(@selector(currentItem))])
    {
        self.toolbarView.progressIndicator.duration = kCMTimeIndefinite;
        self.toolbarView.progressIndicator.loadedTimeRanges = nil;
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
                self.toolbarView.playButton.selected = YES;
                [self startToolbarTimer];
                
                if (self.didPlayToEnd)
                {
                    self.didPlayToEnd = NO;
                    if (newRate > 0)
                    {
                        if (CMTIME_IS_VALID(self.startTime))
                        {
                            [self.player seekToTime:self.startTime];
                        }
                        else
                        {
                            [self.player seekToTime:CMTimeMake(0, 1)];
                        }
                    }
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
                self.toolbarView.playButton.selected = NO;
                if (self.toolbarView.hidden)
                {
                    [self toggleToolbarHidden];
                }
                [self stopToolbarTimer];
            }
        }
    }
    else if (object == self.player.currentItem && [keyPath isEqualToString:NSStringFromSelector(@selector(status))])
    {
        NSNumber *status = change[NSKeyValueChangeNewKey];
        if ((id)status != [NSNull null])
        {
            switch (status.integerValue)
            {
                case AVPlayerItemStatusReadyToPlay:
                {
                    self.toolbarView.progressIndicator.duration = self.player.currentItem.duration;
                    if (!self.delegateNotifiedOfReadinessToPlay)
                    {
                        if ([self.delegate respondsToSelector:@selector(videoPlayerReadyToPlay:)])
                        {
                            [self.delegate videoPlayerReadyToPlay:self];
                        }
                        self.delegateNotifiedOfReadinessToPlay = YES;
                    }
                    break;
                }
                case AVPlayerItemStatusFailed:
                {
                    if ([self.delegate respondsToSelector:@selector(videoPlayerFailed:)])
                    {
                        [self.delegate videoPlayerFailed:self];
                    }
                    break;
                }
            }
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
    else if (object == self.player.currentItem && [keyPath isEqualToString:NSStringFromSelector(@selector(loadedTimeRanges))])
    {
        NSArray *loadedTimeRanges = change[NSKeyValueChangeNewKey];
        if ([loadedTimeRanges isKindOfClass:[NSArray class]])
        {
            // commented out because the loadedTimeRanges value is unreliable
//            self.toolbarView.progressIndicator.loadedTimeRanges = loadedTimeRanges;
        }
    }
}

@end
