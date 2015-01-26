//
//  VCVideoPlayerViewController.h
//

#import <UIKit/UIKit.h>

@import AVFoundation;

@class VCVideoPlayerViewController;

@class VTracking;

@protocol VCVideoPlayerDelegate <NSObject>

@optional

- (void)videoPlayer:(VCVideoPlayerViewController *)videoPlayer didPlayToTime:(CMTime)time;
- (void)videoPlayerReadyToPlay:(VCVideoPlayerViewController *)videoPlayer;
- (void)videoPlayerFailed:(VCVideoPlayerViewController *)videoPlayer;
- (void)videoPlayerWillStartPlaying:(VCVideoPlayerViewController *)videoPlayer;
- (void)videoPlayerWillStopPlaying:(VCVideoPlayerViewController *)videoPlayer;
- (void)videoPlayerDidFinishFirstQuartile:(VCVideoPlayerViewController *)videoPlayer;
- (void)videoPlayerDidReachMidpoint:(VCVideoPlayerViewController *)videoPlayer;
- (void)videoPlayerDidFinishThirdQuartile:(VCVideoPlayerViewController *)videoPlayer;
- (void)videoPlayerDidReachEndOfVideo:(VCVideoPlayerViewController *)videoPlayer;
- (void)videoPlayerWasTapped;

@end

/**
 A UIViewController for displaying video content
 */
@interface VCVideoPlayerViewController : UIViewController

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) NSURL *itemURL;                           ///< The URL of the video to play
@property (nonatomic, weak) id<VCVideoPlayerDelegate> delegate;
@property (nonatomic, readonly) BOOL isLooping;                         ///< If YES, video will loop around at the end
@property (nonatomic, readonly) AVPlayer *player;                       ///< The AVPlayer instance being managed.
@property (nonatomic, assign) Float64 startSeconds;                     ///< Playback will begin at this point
@property (nonatomic, assign) Float64 endSeconds;                       ///< Playback will end (or loop) at this point. Set to 0 to play to end.
@property (nonatomic, readonly) CGSize naturalSize;
@property (nonatomic, readonly, getter = isPlaying) BOOL playing;       ///< YES if a video is playing
@property (nonatomic) BOOL shouldShowToolbar;                           ///< If NO, toolbar will never show.
@property (nonatomic, readonly) UIView *overlayView;                    ///< A view to be displayed on top of the video player. Will not show if shouldShowToolbar is NO.
@property (nonatomic, copy) NSString *titleForAnalytics;                ///< If set, analytics events will use this property for the "label" parameter
@property (nonatomic) BOOL shouldFireAnalytics;                         ///< Set to NO to disable analytics. YES by default.
@property (nonatomic, readonly) CMTime currentTime;
@property (nonatomic, assign) BOOL shouldContinuePlayingAfterDismissal;
@property (nonatomic, copy) NSString *videoPlayerLayerVideoGravity;   ///< Forwards to the player layer
@property (nonatomic, assign) BOOL shouldChangeVideoGravityOnDoubleTap;
@property (nonatomic, assign) BOOL isAudioEnabled;
@property (nonatomic, assign) BOOL loopWithoutComposition;              ///< Loops by playing the asset again instead of making a composition that repeats

- (void)toggleToolbarHidden;

/**
 
 @return Whether tracking is enabled through VTrackingManager as set with
 a tracking item instance of type VTracking.
 */
@property (nonatomic, readonly) BOOL isTrackingEnabled;

/**
 Enables video tracking through an instance of VTrackingManager using data from
 a valid VTracking instance.
 */
- (void)enableTrackingWithTrackingItem:(VTracking *)tracking;

/**
 Disables tracking and releases reference to any current tracking item.  To re-enable, 
 call enableTrackingWithTrackingItem: and pass in a valid VTracking instance.
 */
- (void)disableTracking;

+ (VCVideoPlayerViewController *)currentPlayer; ///< Returns a reference to a VCVideoPlayerViewController instance that is currently playing

/**
 Set the asset to play and indicate it it should loop or not.
 */
- (void)setItemURL:(NSURL *)itemURL loop:(BOOL)loop;

- (CMTime)playerItemDuration;

/// Use this to animate with the same curve that animates the play controls.
@property (nonatomic, copy) void (^animateWithPlayControls)(BOOL playControlsHidden);

@end
