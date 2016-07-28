//
//  VCVideoPlayerViewController.m
//

#import "VVideoPlayerToolbarView.h"
#import "VCVideoPlayerViewController.h"
#import "VElapsedTimeFormatter.h"
#import "VVideoDownloadProgressIndicatorView.h"
#import "victorious-Swift.h"
#import "VVideoUtils.h"
#import "VCVideoPlayerView.h"

static const CGFloat kToolbarHeight = 41.0f;
static const NSTimeInterval kToolbarHideDelay =  2.0;
static const NSTimeInterval kToolbarAnimationDuration =  0.2;

static NSString * const kPlaybackBufferEmpty = @"playbackBufferEmpty";
static NSString * const kPlaybackLikelyToKeepUp = @"playbackLikelyToKeepUp";

static __weak VCVideoPlayerViewController *_currentPlayer = nil;

@interface VCVideoPlayerViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) VVideoPlayerToolbarView *toolbarView;
@property (nonatomic, weak) UITapGestureRecognizer *videoFrameTapGesture;
@property (nonatomic, weak) UITapGestureRecognizer *videoFrameDoubleTapGesture;
@property (nonatomic, strong) VElapsedTimeFormatter *timeFormatter;
@property (nonatomic) BOOL toolbarAnimating;
@property (nonatomic) BOOL sliderTouchActive;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) AVPlayerItem *playerItemBeingObserved;
@property (nonatomic) BOOL delegateNotifiedOfReadinessToPlay;
@property (nonatomic) CMTime startTime;
@property (nonatomic) CMTime endTime;
@property (nonatomic) CMTime originalAssetDuration;
@property (nonatomic) BOOL didPlayToEnd;
@property (nonatomic, strong) NSTimer *toolbarHideTimer;
@property (nonatomic, strong) NSDate *toolbarShowDate;

// These BOOLs prevent multiple notifications due to scrubbing of the video past the quarter-points
@property (nonatomic) BOOL startedVideo;
@property (nonatomic) BOOL finishedFirstQuartile;
@property (nonatomic) BOOL finishedMidpoint;
@property (nonatomic) BOOL finishedThirdQuartile;
@property (nonatomic) BOOL finishedFourthQuartile;
@property (nonatomic) BOOL hasCaculatedItemTime;
@property (nonatomic) BOOL wasPlayingBeforeDissappeared;
@property (nonatomic) BOOL hasCalculatedItemSize;

@property (nonatomic, readwrite) CMTime previousTime;
@property (nonatomic, readwrite) CMTime currentTime;
@property (nonatomic, readonly) BOOL isAtEnd;
@property (nonatomic, strong) VVideoUtils *videoUtils;

@property (nonatomic, readonly) NSDictionary *trackingParameters;
@property (nonatomic, readonly) NSDictionary *trackingParametersForSkipEvent;
@property (nonatomic, strong) VTrackingManager *trackingManager;
@property (nonatomic, strong) VTracking *trackingData;
@property (nonatomic, strong) NSString *streamID;

@property (nonatomic, assign) float rateBeforeScrubbing;

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
    self.shouldRestorePlaybackAfterSeeking = YES;
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
    
    self.videoUtils = [[VVideoUtils alloc] init];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserverFromOldPlayerItemAndAddObserverToPlayerItem:nil];
    [_player removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentItem))];
    [_player removeObserver:self forKeyPath:NSStringFromSelector(@selector(rate))];
    [_player removeTimeObserver:_timeObserver]; _timeObserver = nil;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    self.view = [[VCVideoPlayerView alloc] init];
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor clearColor];
    
    if (self.shouldShowToolbar)
    {
        VVideoPlayerToolbarView *toolbarView = [VVideoPlayerToolbarView toolbarFromNibWithOwner:self];
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
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoFrameTapped:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    self.videoFrameTapGesture = tap;
    
    self.timeFormatter = [[VElapsedTimeFormatter alloc] init];
    self.toolbarView.elapsedTimeLabel.text = [self.timeFormatter stringForCMTime:kCMTimeInvalid];
    self.toolbarView.remainingTimeLabel.text = [self.timeFormatter stringForCMTime:kCMTimeInvalid];
    
    self.overlayView = [[UIView alloc] init];
    
    [self updateViewForShowToolbarValue];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.wasPlayingBeforeDissappeared = (self.player.rate > 0.0f);
    [self.player pause];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.wasPlayingBeforeDissappeared && self.shouldContinuePlayingAfterDismissal)
    {
        self.wasPlayingBeforeDissappeared = NO;
        [self.player play];
    }
    
    if (!self.audioMuted)
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(returnFromBackground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)addDoubleTapGestureRecognizer
{
    if (self.videoFrameDoubleTapGesture)
    {
        return;
    }
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoFrameDoubleTapped:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    self.videoFrameDoubleTapGesture = doubleTap;
    [self.view addGestureRecognizer:doubleTap];
}

- (void)returnFromBackground
{
    // Indicates a GIF
    if (!self.shouldShowToolbar)
    {
        [self.player play];
    }
}

#pragma mark - Properties

- (void)setAnimateWithPlayControls:(void (^)(BOOL))animateWithPlayControls
{
    _animateWithPlayControls = animateWithPlayControls;
    if (_animateWithPlayControls != nil)
    {
        self.animateWithPlayControls(self.toolbarHidden);
    }
}

- (void)setAudioMuted:(BOOL)audioMuted
{
    _audioMuted = audioMuted;
    self.player.muted = _audioMuted;
}

- (void)setShouldChangeVideoGravityOnDoubleTap:(BOOL)shouldChangeVideoGravityOnDoubleTap
{
    _shouldChangeVideoGravityOnDoubleTap = shouldChangeVideoGravityOnDoubleTap;
    
    if (shouldChangeVideoGravityOnDoubleTap)
    {
        [self addDoubleTapGestureRecognizer];
    }
    else
    {
        [self.view removeGestureRecognizer:self.videoFrameDoubleTapGesture];
    }
}

- (void)setPlayer:(AVPlayer *)player
{
    _player = player;
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    _playerItem = playerItem;
    
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
}

- (void)setLoopWithoutComposition:(BOOL)loopWithoutComposition
{
    _loopWithoutComposition = loopWithoutComposition;
    _isLooping = YES;
}

- (void)setItemURL:(NSURL *)itemURL loop:(BOOL)loop
{
    if ([_itemURL isEqual:itemURL])
    {
        VLog(@"Setting same item URL again!");
        return;
    }
    
    _itemURL = itemURL;
    _isLooping = self.loopWithoutComposition ? YES : loop;
    
    self.player.actionAtItemEnd = loop ? AVPlayerActionAtItemEndNone : AVPlayerActionAtItemEndPause;
    const BOOL shouldLoopWithComposition = loop && !self.loopWithoutComposition;
    [self.videoUtils createPlayerItemWithURL:itemURL
                                        loop:shouldLoopWithComposition
                               readyCallback:^(AVPlayerItem *playerItem, NSURL *itemURL, CMTime originalAssetDuration)
     {
         if ( [itemURL isEqual:_itemURL] )
         {
             self.originalAssetDuration = originalAssetDuration;
             [self.player replaceCurrentItemWithPlayerItem:playerItem];
         }
     }];
}

- (void)setItemURL:(NSURL *)itemURL
{
    [self setItemURL:itemURL loop:NO];
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
}

- (void)setOverlayView:(UIView *)overlayView
{
    if (_overlayView)
    {
        [_overlayView removeFromSuperview];
    }
    _overlayView = overlayView;
    _overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    if ([self.view.subviews containsObject:self.toolbarView])
    {
        [self.view insertSubview:_overlayView belowSubview:self.toolbarView];
    }
    else
    {
        [self.view addSubview:_overlayView];
    }
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[overlayView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(overlayView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[overlayView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(overlayView)]];
}

- (void)setVideoPlayerLayerVideoGravity:(NSString *)videoPlayerLayerVideoGravity
{
    [(VCVideoPlayerView *)self.view setVideoGravity:videoPlayerLayerVideoGravity];
}

- (NSString *)videoPlayerLayerVideoGravity
{
    return [(VCVideoPlayerView *)self.view videoGravity];
}

#pragma mark - Toolbar

- (void)setToolbarHidden:(BOOL)toolbarHidden
{
    _toolbarHidden = toolbarHidden;
    
    if ( _toolbarHidden )
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
    else
    {
        self.toolbarView.hidden = NO;
        self.overlayView.hidden = NO;
        self.toolbarView.alpha  =  0;
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
}

- (void)toggleToolbarHidden
{
    if (self.toolbarAnimating || !self.shouldShowToolbar)
    {
        return;
    }
    
    self.toolbarHidden = !self.toolbarHidden;
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

- (CMTime)timeAdjustedForLoopingVideoFromTime:(CMTime)time
{
    int currentLoop = 0;
    CMTime compareTime = time;
    
    if (!CMTIME_IS_VALID(self.originalAssetDuration))
    {
        return time;
    }
    
    while ( CMTIME_COMPARE_INLINE( compareTime, >, self.originalAssetDuration) )
    {
        compareTime = CMTimeSubtract( compareTime, self.originalAssetDuration );
        currentLoop++;
    }
    
    CMTime adjustment = CMTimeMultiply( self.originalAssetDuration, currentLoop );
    CMTime output = CMTimeSubtract( time, adjustment );
    
    // Uncomment to debug adjusted time and current loop:
//     VLog( @"adjusted time (%i): %.2f", currentLoop, CMTimeGetSeconds( output ) );
    
    return output;
}

- (void)didPlayToTime:(CMTime)time
{
    time = [self timeAdjustedForLoopingVideoFromTime:time];
    
    Float64 durationInSeconds = CMTimeGetSeconds( self.originalAssetDuration );
    Float64 timeInSeconds     = CMTimeGetSeconds(time);
    float percentElapsed      = timeInSeconds / durationInSeconds;
    
    self.previousTime = self.currentTime;
    self.currentTime = time;
    
    if (!self.sliderTouchActive)
    {
        self.toolbarView.slider.value = percentElapsed;
    }
    
    CMTime duration = self.originalAssetDuration;
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
        if ( self.isTrackingEnabled )
        {
            NSDictionary *params = @{ VTrackingKeyTimeCurrent : @( self.currentTimeMilliseconds ),
                                      VTrackingKeyUrls : self.trackingData.videoComplete25,
                                      VTrackingKeyStreamId : self.streamID };
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventVideoDidComplete25 parameters:params];
        }
        self.finishedFirstQuartile = YES;
    }
    if (!self.finishedMidpoint && percentElapsed >= 0.5f)
    {
        if ([self.delegate respondsToSelector:@selector(videoPlayerDidReachMidpoint:)])
        {
            [self.delegate videoPlayerDidReachMidpoint:self];
        }
        if ( self.isTrackingEnabled )
        {
            NSDictionary *params = @{ VTrackingKeyTimeCurrent : @( self.currentTimeMilliseconds ),
                                      VTrackingKeyUrls : self.trackingData.videoComplete50,
                                      VTrackingKeyStreamId : self.streamID };
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventVideoDidComplete50 parameters:params];
        }
        self.finishedMidpoint = YES;
    }
    if (!self.finishedThirdQuartile && percentElapsed >= 0.75f)
    {
        if ([self.delegate respondsToSelector:@selector(videoPlayerDidFinishThirdQuartile:)])
        {
            [self.delegate videoPlayerDidFinishThirdQuartile:self];
        }
        if ( self.isTrackingEnabled )
        {
            NSDictionary *params = @{ VTrackingKeyTimeCurrent : @( self.currentTimeMilliseconds ),
                                      VTrackingKeyUrls : self.trackingData.videoComplete75,
                                      VTrackingKeyStreamId : self.streamID };
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventVideoDidComplete75 parameters:params];
        }
        self.finishedThirdQuartile = YES;
    }
    
    // `shouldShowToolbar` indicates a GIF, and since GIFs are trimmed slightly at their ends for clean looping, we compare against just under 1.0f
    // Tracking the final quartile for videos without composition-based looping occurrs in `playerItemDidPlayToEndTime`:
    if ( !self.shouldShowToolbar && !self.finishedFourthQuartile && percentElapsed >= 0.98f)
    {
        if ( self.isTrackingEnabled )
        {
            NSDictionary *params = @{ VTrackingKeyTimeCurrent : @( self.currentTimeMilliseconds ),
                                      VTrackingKeyUrls : self.trackingData.videoComplete100,
                                      VTrackingKeyStreamId : self.streamID };
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventVideoDidComplete100 parameters:params];
        }
        self.finishedFourthQuartile = YES;
    }
    
    if (CMTIME_IS_VALID(self.endTime) && CMTIME_COMPARE_INLINE(time, >=, self.endTime))
    {
        if (self.isLooping)
        {
            if (CMTIME_IS_VALID(self.startTime))
            {
                [self.player seekToTime:self.startTime];
            }
            else
            {
                [self.player seekToTime:kCMTimeZero];
            }
        }
        else
        {
            [self.player pause];
        }
    }
}

- (void)removeObserverFromOldPlayerItemAndAddObserverToPlayerItem:(AVPlayerItem *)currentItem
{
    if ([self.playerItemBeingObserved isKindOfClass:[AVPlayerItem class]])
    {
        [self.playerItemBeingObserved removeObserver:self forKeyPath:kPlaybackBufferEmpty];
        [self.playerItemBeingObserved removeObserver:self forKeyPath:kPlaybackLikelyToKeepUp];
        [self.playerItemBeingObserved removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];
        [self.playerItemBeingObserved removeObserver:self forKeyPath:NSStringFromSelector(@selector(tracks))];
        [self.playerItemBeingObserved removeObserver:self forKeyPath:NSStringFromSelector(@selector(loadedTimeRanges))];
        [self.playerItemBeingObserved removeObserver:self forKeyPath:NSStringFromSelector(@selector(duration))];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:self.playerItemBeingObserved];
        self.playerItemBeingObserved = nil;
    }
    if ([currentItem isKindOfClass:[AVPlayerItem class]])
    {
        self.playerItemBeingObserved = currentItem;
        self.hasCaculatedItemTime = NO;
        [currentItem addObserver:self
                      forKeyPath:kPlaybackBufferEmpty
                         options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         context:nil];
        [currentItem addObserver:self
                      forKeyPath:kPlaybackLikelyToKeepUp
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
                                [(VCVideoPlayerView *)weakSelf.view setPlayer:self.player];
                                [self notifyDelegateReadyToPlayIfReallyReady];
                            }
                        });
     }];
}

- (NSInteger)currentTimeMilliseconds
{
    return (NSUInteger)(CMTimeGetSeconds( self.currentTime ) * 1000.0);
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
        // If we are at the end we need to seek to the begginning
        if (self.didPlayToEnd && CMTIME_COMPARE_INLINE(self.player.currentItem.currentTime, >=, self.player.currentItem.duration))
        {
            [self.player seekToTime:kCMTimeZero
                  completionHandler:^(BOOL finished)
            {
                [self.player play];
            }];
        }
        else
        {
            [self.player play];
        }
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

- (void)videoFrameDoubleTapped:(UITapGestureRecognizer *)sender
{
    NSString *oldVideoGravity = [(VCVideoPlayerView *)self.view videoGravity];
    NSString *newVideoGravity = [oldVideoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill] ? AVLayerVideoGravityResizeAspect : AVLayerVideoGravityResizeAspectFill;
    [(VCVideoPlayerView *)self.view setVideoGravity:newVideoGravity];
}

- (IBAction)sliderTouchDown:(UISlider *)sender
{
    self.sliderTouchActive = YES;
    self.rateBeforeScrubbing = self.player.rate;
    [self.player pause];
    
    [self didBeginSliderTouchInteraction];
}

- (IBAction)sliderValueChanged:(UISlider *)slider
{
    CMTime duration = [self playerItemDuration];
    [self.player seekToTime:CMTimeMultiplyByFloat64(duration, slider.value)];
}

- (IBAction)sliderTouchUp:(UISlider *)slider
{
    self.toolbarShowDate = [NSDate date];
    CMTime duration = [self playerItemDuration];
    [self.player seekToTime:CMTimeMultiplyByFloat64(duration, slider.value)
          completionHandler:^(BOOL finished)
    {
        if (self.shouldRestorePlaybackAfterSeeking)
        {
            [self.player setRate:self.rateBeforeScrubbing];
        }
        self.sliderTouchActive = NO;
        
        [self didCompleteTouchSliderInteraction];
    }];
}

- (IBAction)sliderTouchCancelled:(id)sender
{
    self.sliderTouchActive = NO;
    
    [self didCompleteTouchSliderInteraction];
}

#pragma mark - Skip detection

- (void)didBeginSliderTouchInteraction
{
    self.sliderTouchInteractionStartTime = self.player.currentTime;
}

- (void)didCompleteTouchSliderInteraction
{
    CMTime currentTime = self.player.currentTime;
    
    if ( CMTIME_IS_INDEFINITE(currentTime) || CMTIME_IS_INVALID(self.sliderTouchInteractionStartTime) )
    {
        return;
    }
    
    if ( self.isTrackingEnabled && self.shouldShowToolbar )
    {
        NSDictionary *params = @{ VTrackingKeyTimeCurrent : @( self.currentTimeMilliseconds ),
                                  VTrackingKeyFromTime : @( CMTimeGetSeconds( self.sliderTouchInteractionStartTime ) ),
                                  VTrackingKeyToTime : @( CMTimeGetSeconds( currentTime) ),
                                  VTrackingKeyUrls : self.trackingData.videoSkip,
                                  VTrackingKeyStreamId : self.streamID };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventVideoDidSkip parameters:params];
    }
}

#pragma mark - NSNotification handlers

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification
{
    if (notification.object == self.player.currentItem)
    {
        if (self.isLooping)
        {
            if (CMTIME_IS_VALID(self.startTime))
            {
                [self.player seekToTime:self.startTime];
            }
            else
            {
                [self.player seekToTime:kCMTimeZero];
            }
            [self.player setRate:1.0f];
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
    
    if (!self.finishedFourthQuartile )
    {
        if ( self.isTrackingEnabled )
        {
            NSDictionary *params = @{ VTrackingKeyTimeCurrent : @( self.currentTimeMilliseconds ),
                                      VTrackingKeyUrls : self.trackingData.videoComplete100,
                                      VTrackingKeyStreamId : self.streamID };
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventVideoDidComplete100 parameters:params];
        }
        
        self.finishedFourthQuartile = YES;
    }
}

- (void)playerItemFailedToPlayToEndTime:(NSNotification *)notification
{
    NSDictionary *params = @{ VTrackingKeyTimeCurrent : @( self.currentTimeMilliseconds ),
                              VTrackingKeyErrorMessage : @"AVPlayerItemFailedToPlayToEndTimeNotification" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventVideoDidFail parameters:params];
    
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
        AVPlayerItem *newItem = change[NSKeyValueChangeNewKey];
        [self removeObserverFromOldPlayerItemAndAddObserverToPlayerItem:newItem];
        self.startedVideo           = NO;
        self.finishedFirstQuartile  = NO;
        self.finishedMidpoint       = NO;
        self.finishedThirdQuartile  = NO;
        self.finishedFourthQuartile = NO;
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
                    if ([newRate floatValue] > 0)
                    {
                        if (CMTIME_IS_VALID(self.startTime))
                        {
                            [self.player seekToTime:self.startTime];
                        }
                        else
                        {
                            [self.player seekToTime:kCMTimeZero];
                        }
                    }
                }
                if (!self.startedVideo)
                {
                    self.startedVideo = YES;
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
                        NSDictionary *params = @{ VTrackingKeyTimeCurrent : @( self.currentTimeMilliseconds ),
                                                  VTrackingKeyErrorMessage : @"AVPlayerItemStatusFailed" };
                        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventVideoDidFail parameters:params];
                        
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
    else if (object == self.player.currentItem && [keyPath isEqualToString:kPlaybackBufferEmpty])
    {
        if ( self.player.currentItem.playbackBufferEmpty )
        {
            if ( !self.isAtEnd )
            {
                if ( self.isTrackingEnabled )
                {
                    NSDictionary *params = @{ VTrackingKeyTimeCurrent : @( self.currentTimeMilliseconds ),
                                              VTrackingKeyUrls : self.trackingData.videoStall,
                                              VTrackingKeyStreamId : self.streamID };
                    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventVideoDidStall parameters:params];
                }
            }
        }
    }
    else if (object == self.player.currentItem && [keyPath isEqualToString:kPlaybackLikelyToKeepUp])
    {
        // This is where playback resumes after having been stalled.  Do nothing for now
    }
}

- (BOOL)isAtEnd
{
    CMTime time = self.currentTime;
    CMTime duration = self.currentTime;
    return time.value == duration.value;
}

- (BOOL)didFinishPlayingOnce
{
    return self.finishedFourthQuartile;
}

#pragma mark - Notifiers

- (void)notifyDelegateReadyToPlayIfReallyReady
{
    if ((!self.delegateNotifiedOfReadinessToPlay) && (self.player.status == AVPlayerStatusReadyToPlay) )
    {
        if ([self.delegate respondsToSelector:@selector(videoPlayerReadyToPlay:)])
        {
            [self.delegate videoPlayerReadyToPlay:self];
            self.delegateNotifiedOfReadinessToPlay = YES;
        }
    }
}

#pragma mark - Tracking

- (BOOL)isTrackingEnabled
{
    return self.trackingData != nil;
}

- (void)enableTrackingWithTrackingItem:(VTracking *)trackingData streamID:(NSString *)streamID
{
    if ( trackingData == nil )
    {
        return;
    }
    
    NSAssert( [trackingData isKindOfClass:[VTracking class]] && trackingData != nil,
             @"Cannot track video events in VCVideoPlayerViewController because tracking data is missing or invalid." );
    
    self.trackingData = trackingData;
    self.streamID = streamID ?: @"";
}

- (void)disableTracking
{
    self.trackingData = nil;
}

- (NSString *)streamID
{
    if ( _streamID != nil )
    {
        return _streamID;
    }
    return @"";
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return (((gestureRecognizer == self.videoFrameTapGesture) || (gestureRecognizer == self.videoFrameDoubleTapGesture)) &&
            ((otherGestureRecognizer == self.videoFrameTapGesture) || (otherGestureRecognizer == self.videoFrameDoubleTapGesture))) ? YES : NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return ((gestureRecognizer == self.videoFrameTapGesture) && (otherGestureRecognizer == self.videoFrameDoubleTapGesture)) ? YES : NO;
}

@end
