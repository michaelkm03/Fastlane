//
//  VCVideoPlayerView
//

#import <UIKit/UIKit.h>

@import AVFoundation;

@class VCVideoPlayerView;

@protocol VCVideoPlayerDelegate <NSObject>

@optional

- (void)videoPlayer:(VCVideoPlayerView *)videoPlayer didPlayToTime:(CMTime)time;
- (void)videoPlayerReadyToPlay:(VCVideoPlayerView *)videoPlayer;
- (void)videoPlayerWillStartPlaying:(VCVideoPlayerView *)videoPlayer;
- (void)videoPlayerWillStopPlaying:(VCVideoPlayerView *)videoPlayer;

@end

/**
 A UIView subclass for displaying video content
 */
@interface VCVideoPlayerView : UIView

@property (nonatomic, strong)   NSURL                     *itemURL; ///< The URL of the video to play
@property (nonatomic, weak)     id<VCVideoPlayerDelegate>  delegate;
@property (nonatomic)           BOOL                       shouldLoop; ///< If YES, video will loop around at the end
@property (nonatomic, readonly) AVPlayer                  *player; ///< The AVPlayer instance being managed
@property (nonatomic, assign)   Float64                    startSeconds; ///< Playback will begin at this point
@property (nonatomic, assign)   Float64                    endSeconds; ///< Playback will end (or loop) at this point. Set to 0 to play to end.
@property (nonatomic, readonly) CGSize                     naturalSize;
@property (nonatomic, readonly, getter = isPlaying) BOOL   playing; ///< YES if a video is playing
@property (nonatomic)           BOOL                       shouldShowToolbar; ///< If NO, toolbar will never show.

+ (VCVideoPlayerView *)currentPlayer; ///< Returns a reference to a VCVideoPlayerView instance that is currently playing

/**
 Add the same item "loopCount" times in order to have a smooth loop. 
 The loop system provided by Apple has an unvoidable hiccup. Using 
 this method will avoid the hiccup.
 */
- (void)setItemURL:(NSURL *)itemURL withLoopCount:(NSUInteger)loopCount;

- (CMTime)playerItemDuration;

@end
