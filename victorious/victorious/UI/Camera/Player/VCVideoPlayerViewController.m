//
//  VCVideoPlayerViewController.m
//

#import "VAnalyticsRecorder.h"
#import "VCVideoPlayerToolbarView.h"
#import "VCVideoPlayerViewController.h"
#import "VElapsedTimeFormatter.h"
#import "VVideoDownloadProgressIndicatorView.h"
#import "VTrackingManager.h"

static const CGFloat kToolbarHeight = 41.0f;
static const NSTimeInterval kToolbarHideDelay =  2.0;
static const NSTimeInterval kToolbarAnimationDuration =  0.2;

static __weak VCVideoPlayerViewController *_currentPlayer = nil;

@interface VCVideoPlayerViewController ()

@property (nonatomic, weak) VCVideoPlayerToolbarView *toolbarView;
@property (nonatomic, weak) UITapGestureRecognizer *videoFrameTapGesture;
@property (nonatomic, strong) VElapsedTimeFormatter *timeFormatter;
@property (nonatomic) BOOL toolbarAnimating;
@property (nonatomic) BOOL sliderTouchActive;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic) BOOL delegateNotifiedOfReadinessToPlay;
@property (nonatomic) CMTime startTime;
@property (nonatomic) CMTime endTime;
@property (nonatomic) BOOL didPlayToEnd;
@property (nonatomic, strong) NSTimer *toolbarHideTimer;
@property (nonatomic, strong) NSDate *toolbarShowDate;

// These BOOLs prevent multiple notifications due to scrubbing of the video past the quarter-points
@property (nonatomic) BOOL startedVideo;
@property (nonatomic) BOOL finishedFirstQuartile;
@property (nonatomic) BOOL finishedMidpoint;
@property (nonatomic) BOOL finishedThirdQuartile;
@property (nonatomic) BOOL hasCaculatedItemTime;
@property (nonatomic) BOOL wasPlayingBeforeDissappeared;
@property (nonatomic) BOOL hasCalculatedItemSize;

@property (nonatomic, readwrite) CMTime previousTime;
@property (nonatomic, readwrite) CMTime currentTime;

@property (nonatomic, readonly) NSDictionary *trackingParameters;
@property (nonatomic, readonly) NSDictionary *trackingParametersForSkipEvent;
@property (nonatomic, strong) VTrackingManager *trackingManager;
@property (nonatomic, strong) VTracking *trackingItem;

@end

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
    self.wasPlayingBeforeDissappeared = NO;
    self.shouldContinuePlayingAfterDismissal = YES;
    self.shouldShowToolbar = YES;
    self.shouldFireAnalytics = YES;
    self.shouldLoop = NO;
    self.startTime = CMTimeMakeWithSeconds(0, 1);
    self.player = [[AVPlayer alloc] init];
    [self.player addObserver:self
                  forKeyPath:NSStringFromSelector(@selector(currentItem))
                     options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                     context:nil];
    [self.player addObserver:self
                  forKeyPath:NSStringFromSelector(@selector(rate))
                     options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                     context:nil];
    
    VCVideoPlayerViewController *__weak weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 24)
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:^(CMTime time)
    {
        [weakSelf didPlayToTime:time];
    }];
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
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
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

    self.wasPlayingBeforeDissappeared = (self.player.rate > 0.0f);
    [self.player pause];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.wasPlayingBeforeDissappeared && self.shouldContinuePlayingAfterDismissal)
    {
        self.wasPlayingBeforeDissappeared = NO;
        [self.player play];
    }
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
        AVMutableComposition *composition = [AVMutableComposition composition];
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
            if (self.animateWithPlayControls)
            {
                self.animateWithPlayControls(NO);
            }
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
             if (self.animateWithPlayControls)
             {
                 self.animateWithPlayControls(YES);
             }
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
    
    if (CMTIME_IS_VALID(playerItem.duration))
    {
        return playerItem.duration;
    }
    return kCMTimeInvalid;
}

- (void)didPlayToTime:(CMTime)time
{
    Float64 durationInSeconds = CMTimeGetSeconds([self playerItemDuration]);
    Float64 timeInSeconds     = CMTimeGetSeconds(time);
    float percentElapsed      = timeInSeconds / durationInSeconds;
    
    self.previousTime = self.currentTime;
    self.currentTime = time;
    
    if ( [self didSkipFromPreviousTime:self.previousTime toCurrentTime:self.currentTime] )
    {
        VLog( @"Video did skip from: %.2f to %.2f", CMTimeGetSeconds( self.previousTime ), CMTimeGetSeconds( self.currentTime ) );
        if ( self.isTrackingEnabled )
        {
            [self.trackingManager trackEventWithUrls:self.trackingItem.videoSkip andParameters:self.trackingParametersForSkipEvent];
        }
    }

    if (!self.sliderTouchActive)
    {
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
    
    if (!self.finishedFirstQuartile && percentElapsed >= 0.25f)
    {
        if ([self.delegate respondsToSelector:@selector(videoPlayerDidFinishFirstQuartile:)])
        {
            [self.delegate videoPlayerDidFinishFirstQuartile:self];
        }
        if (self.shouldFireAnalytics)
        {
            [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryVideo action:@"Video Play First Quartile" label:self.titleForAnalytics value:nil];
        }
        if ( self.isTrackingEnabled )
        {
            [self.trackingManager trackEventWithUrls:self.trackingItem.videoComplete25 andParameters:self.trackingParameters];
        }
        self.finishedFirstQuartile = YES;
    }
    if (!self.finishedMidpoint && percentElapsed >= 0.5f)
    {
        if ([self.delegate respondsToSelector:@selector(videoPlayerDidReachMidpoint:)])
        {
            [self.delegate videoPlayerDidReachMidpoint:self];
        }
        if (self.shouldFireAnalytics)
        {
            [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryVideo action:@"Video Play Halfway" label:self.titleForAnalytics value:nil];
        }
        if ( self.isTrackingEnabled )
        {
            [self.trackingManager trackEventWithUrls:self.trackingItem.videoComplete50 andParameters:self.trackingParameters];
        }
        self.finishedMidpoint = YES;
    }
    if (!self.finishedThirdQuartile && percentElapsed >= 0.75f)
    {
        if ([self.delegate respondsToSelector:@selector(videoPlayerDidFinishThirdQuartile:)])
        {
            [self.delegate videoPlayerDidFinishThirdQuartile:self];
        }
        if (self.shouldFireAnalytics)
        {
            [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryVideo action:@"Video Play Third Quartile" label:self.titleForAnalytics value:nil];
        }
        if ( self.isTrackingEnabled )
        {
            [self.trackingManager trackEventWithUrls:self.trackingItem.videoComplete75 andParameters:self.trackingParameters];
        }
        self.finishedThirdQuartile = YES;
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

- (BOOL)didSkipFromPreviousTime:(CMTime)previousTime toCurrentTime:(CMTime)currentTime
{
    NSTimeInterval difference = CMTimeGetSeconds(self.currentTime) - CMTimeGetSeconds(self.previousTime);
    NSTimeInterval limit = 1.0f;
    
    return abs( difference ) > limit;
}

- (void)removeObserverFromOldPlayerItem:(AVPlayerItem *)oldItem andAddObserverToPlayerItem:(AVPlayerItem *)currentItem
{
    if ([oldItem isKindOfClass:[AVPlayerItem class]])
    {
        [oldItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];
        [oldItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(tracks))];
        [oldItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(loadedTimeRanges))];
        [oldItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(duration))];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:oldItem];
    }
    if ([currentItem isKindOfClass:[AVPlayerItem class]])
    {
        self.hasCaculatedItemTime = NO;
        [currentItem addObserver:self
                      forKeyPath:@"playbackBufferEmpty"
                         options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         context:nil];
        [currentItem addObserver:self
                      forKeyPath:@"playbackLikelyToKeepUp"
                         options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         context:nil];
        [currentItem addObserver:self
                      forKeyPath:NSStringFromSelector(@selector(status))
                         options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         context:nil];
        [currentItem addObserver:self
                      forKeyPath:NSStringFromSelector(@selector(tracks))
                         options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         context:nil];
        [currentItem addObserver:self
                      forKeyPath:NSStringFromSelector(@selector(loadedTimeRanges))
                         options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         context:nil];
        [currentItem addObserver:self
                      forKeyPath:NSStringFromSelector(@selector(duration))
                         options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         context:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidPlayToEndTime:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:currentItem];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemFailedToPlayToEndTime:)
                                                     name:AVPlayerItemFailedToPlayToEndTimeNotification object:currentItem];
    }
}

- (void)refreshNaturalSizePropertyFromTrack:(AVPlayerItemTrack *)track inItem:(AVPlayerItem *)item
{
    self.hasCalculatedItemSize = NO;
    VCVideoPlayerViewController *__weak weakSelf = self;
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
                // sometimes the size is incorrect
                if (CGSizeEqualToSize(assetTrack.naturalSize, CGSizeZero))
                {
                    return;
                }
                weakSelf.naturalSize = assetTrack.naturalSize;
                weakSelf.hasCalculatedItemSize = YES;
                [self notifyDelegateReadyToPlayIfReallyReady];
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
        
        if ([self.delegate respondsToSelector:@selector(videoPlayerWasTapped)])
        {
            [self.delegate videoPlayerWasTapped];
        }
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
            if (self.shouldFireAnalytics)
            {
                [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryVideo action:@"Video Play to End" label:self.titleForAnalytics value:nil];
            }
            if ( self.isTrackingEnabled )
            {
                [self.trackingManager trackEventWithUrls:self.trackingItem.videoComplete100 andParameters:self.trackingParameters];
            }
            self.startedVideo          = NO;
            self.finishedFirstQuartile = NO;
            self.finishedMidpoint      = NO;
            self.finishedThirdQuartile = NO;
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
        self.startedVideo          = NO;
        self.finishedFirstQuartile = NO;
        self.finishedMidpoint      = NO;
        self.finishedThirdQuartile = NO;
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
                if ( self.isTrackingEnabled )
                {
                    [self.trackingManager trackEventWithUrls:self.trackingItem.videoStart andParameters:self.trackingParameters];
                }
                self.toolbarView.playButton.selected = YES;
                [self startToolbarTimer];
                
                if (self.didPlayToEnd)
                {
                    self.didPlayToEnd = NO;
                    if ([newRate floatValue] > 0)
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
                if (!self.startedVideo)
                {
                    self.startedVideo = YES;
                    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryVideo action:@"Video Play Start" label:self.titleForAnalytics value:nil];
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
                    [self notifyDelegateReadyToPlayIfReallyReady];
                    break;
                }
                case AVPlayerItemStatusFailed:
                {
                    if ([self.delegate respondsToSelector:@selector(videoPlayerFailed:)])
                    {
                        [self.delegate videoPlayerFailed:self];
                    }
                    if ( self.isTrackingEnabled )
                    {
                        [self.trackingManager trackEventWithUrls:self.trackingItem.videoError andParameters:self.trackingParameters];
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
            // self.toolbarView.progressIndicator.loadedTimeRanges = loadedTimeRanges;
        }
    }
    else if (object == self.player.currentItem && [keyPath isEqualToString:NSStringFromSelector(@selector(duration))])
    {
        if (CMTIME_IS_VALID([self playerItemDuration]) && (CMTimeGetSeconds([self playerItemDuration]) > 0))
        {
            self.hasCaculatedItemTime = YES;
            [self notifyDelegateReadyToPlayIfReallyReady];
        }
    }
    else if (object == self.player.currentItem && [keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if ( self.player.currentItem.playbackBufferEmpty )
        {
            CMTime time = self.currentTime;
            CMTime duration = self.currentTime;
            BOOL isAtEnd = time.value == duration.value;
            if ( !isAtEnd )
            {
                VLog( @"Video did skip from: %.2f to %.2f", CMTimeGetSeconds( self.previousTime ), CMTimeGetSeconds( self.currentTime ) );
                if ( self.isTrackingEnabled )
                {
                    [self.trackingManager trackEventWithUrls:self.trackingItem.videoStall andParameters:self.trackingParameters];
                }
            }
        }
    }
    else if (object == self.player.currentItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        // This is where playback resumes after having been stalled.  Do nothing for now
    }
    
}

#pragma mark - Notifiers

- (void)notifyDelegateReadyToPlayIfReallyReady
{
    if ((!self.delegateNotifiedOfReadinessToPlay) && (self.player.status == AVPlayerStatusReadyToPlay) && (self.hasCaculatedItemTime) && (self.hasCalculatedItemSize))
    {
        if ([self.delegate respondsToSelector:@selector(videoPlayerReadyToPlay:)])
        {
            [self.delegate videoPlayerReadyToPlay:self];
            self.delegateNotifiedOfReadinessToPlay = YES;
        }
    }
}

#pragma mark - Tracking

- (NSDictionary *)trackingParametersForSkipEvent
{
    return @{ kTrackingKeyTimeFrom  : @( CMTimeGetSeconds( self.currentTime ) ),
              kTrackingKeyTimeTo    : @( CMTimeGetSeconds( self.previousTime ) ) };
}

- (NSDictionary *)trackingParameters
{
    return @{ kTrackingKeyTimeCurrent : @( CMTimeGetSeconds( self.currentTime ) ) };
}

- (BOOL)isTrackingEnabled
{
    return self.trackingItem != nil && self.trackingManager != nil;
}

- (void)enableTrackingWithTrackingItem:(VTracking *)trackingItem
{
    NSParameterAssert( [trackingItem isKindOfClass:[VTracking class]] && trackingItem != nil );
    
    self.trackingItem = trackingItem;
    self.trackingManager = [[VTrackingManager alloc] init];
}

- (void)disableTracking
{
    self.trackingItem = nil;
    self.trackingManager = nil;
}

@end
