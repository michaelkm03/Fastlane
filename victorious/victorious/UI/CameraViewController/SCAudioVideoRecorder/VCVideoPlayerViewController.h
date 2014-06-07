//
//  VCVideoPlayerViewController.h
//

#import <UIKit/UIKit.h>

@import AVFoundation;

@class VCVideoPlayerViewController;

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

@end

/**
 A UIView subclass for displaying video content
 */
@interface VCVideoPlayerViewController : UIViewController

@property (nonatomic, strong)   NSURL                     *itemURL; ///< The URL of the video to play
@property (nonatomic, readonly) NSUInteger                 loopCount; ///< The number of loops requested via a call to setItemURL:withLoopCount:
@property (nonatomic, weak)     id<VCVideoPlayerDelegate>  delegate;
@property (nonatomic)           BOOL                       shouldLoop; ///< If YES, video will loop around at the end
@property (nonatomic, readonly) AVPlayer                  *player; ///< The AVPlayer instance being managed.
@property (nonatomic, assign)   Float64                    startSeconds; ///< Playback will begin at this point
@property (nonatomic, assign)   Float64                    endSeconds; ///< Playback will end (or loop) at this point. Set to 0 to play to end.
@property (nonatomic, readonly) CGSize                     naturalSize;
@property (nonatomic, readonly, getter = isPlaying) BOOL   playing; ///< YES if a video is playing
@property (nonatomic)           BOOL                       shouldShowToolbar; ///< If NO, toolbar will never show.
@property (nonatomic, readonly) UIView                    *overlayView; ///< A view to be displayed on top of the video player. Will not show if shouldShowToolbar is NO.
@property (nonatomic, copy)     NSString                  *titleForAnalytics; ///< If set, analytics events will use this property for the "label" parameter
@property (nonatomic)           BOOL                       shouldFireAnalytics; ///< Set to NO to disable analytics. YES by default.

+ (VCVideoPlayerViewController *)currentPlayer; ///< Returns a reference to a VCVideoPlayerViewController instance that is currently playing

/**
 Add the same item "loopCount" times in order to have a smooth loop. 
 The loop system provided by Apple has an unvoidable hiccup. Using 
 this method will avoid the hiccup.
 */
- (void)setItemURL:(NSURL *)itemURL withLoopCount:(NSUInteger)loopCount;

- (CMTime)playerItemDuration;

@end
