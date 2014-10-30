//
//  OXMMediaPlaybackView.h
//  OpenX_iOS_SDK
//
//  Created by Lawrence Leach on 4/2/14.
//
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

@class AVPlayer, OXMMediaPlaybackView;

@protocol OXMMediaPlayerDelegate <NSObject>
@optional
-(void)playerViewExpandButtonTouched:(OXMMediaPlaybackView*)view;
-(void)playerFinishedPlayback:(OXMMediaPlaybackView*)view;
- (void) videoDidFailLoad:(NSError*)error;
- (void) playbackDidMute;
- (void) playbackDidUnmute;
- (void) playbackDidPause;
- (void) playbackDidSeekBackward;
- (void) playbackDidSeekForward;
- (void) playbackDidResume;
- (void) playbackDidFinish;
- (void) playbackDidClose;
- (void) playbackWasShared;
- (void) playbackDidFullScreen;
- (void) playbackDidStart;
- (void) playbackDidFirstQuartile;
- (void) playbackDidMidPoint;
- (void) playbackDidThirdQuartile;
- (void) playbackWasTouched;
- (void) playbackTimeDidChange:(CMTime)newTime timeLeft:(CMTime)timeLeft normalizedTime:(CGFloat)normalizedTime;

@end



@interface OXMMediaPlaybackView : UIView
@property (nonatomic,assign) id<OXMMediaPlayerDelegate> playerDelegate;
@property (nonatomic) BOOL autoRotateOnOrientationChange;
@property (nonatomic, weak) AVPlayer* player;

@property (nonatomic, readonly, getter=isMuted) BOOL muted;
@property (nonatomic, readonly, getter=isLoaded) BOOL loaded;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;

@property (nonatomic, strong) NSArray *adBreaks;

- (void)setVideoFillMode:(NSString *)fillMode;
- (void)mute;
- (void)unmute;
- (void)play;
- (void)pause;
- (void)playAt:(CGFloat)playTime;

@end
