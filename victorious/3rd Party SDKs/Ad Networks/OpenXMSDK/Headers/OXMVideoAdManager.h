//
//  OXMVideoAdManager.h
//  OpenX_iOS_SDK
//
//  Created by Lawrence Leach on 3/2/14.
//
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AutoPlayConfig) {
    NoAutoPlay,
    AlwaysAutoPlay,
    WifiOnlyAutoPlay
};


@class OXMAdRequest, AVPlayer, OXMMediaPlaybackView, OXMVideoAdManager;


@protocol OXMVideoAdManagerDelegate <NSObject>
@required

/** This method is invoked when the video ad manager has failed to load.
 @param adManager The ad manager sending the notification
 @param error The error code being returned by video ad manager.
 */
- (void) videoAdManager:(OXMVideoAdManager*)adManager didFailToReceiveAdWithError:(NSError*)error;

/** This method is invoked when the video ad manager has been loaded successfully.
 @param adManager The ad manager sending the notification
 */
- (void) videoAdManagerDidLoad:(OXMVideoAdManager*)adManager;


@optional
// -- PLAYBACK METHODS
/** This method is invoked when a video ad player is complete when used in the infeed scenario
 */
-(void)videoInFeedCompelete;
/** This method is invoked when the video expands to fullscreen (VAST v2.0)
 @param none
 */
- (void) videoAdManagerDidExpand:(OXMVideoAdManager*)adManager;

/** This method is invoked when the video expands to fullscreen (VAST v3.0)
 @param none
 */
- (void) videoAdManagerDidEnterFullScreen:(OXMVideoAdManager*)adManager;

/** This method is invoked when the video exits fullscreen (VAST v2.0)
 @param none
 */
- (void) videoAdManagerDidCollapse:(OXMVideoAdManager*)adManager;

/** This method is invoked when the video exits fullscreen (VAST v3.0)
 @param none
 */
- (void) videoAdManagerDidExitFullScreen:(OXMVideoAdManager*)adManager;

/** This method is invoked when the video finishes playback
 @param none
 */
- (void) videoAdManagerDidFinish:(OXMVideoAdManager*)adManager;

/** This method is invoked when the video closes (VAST v2.0)
 @param none
 */
- (void) videoAdManagerDidClose:(OXMVideoAdManager*)adManager;

/** This method is invoked when the video closes (VAST v3.0)
 @param none
 */
- (void) videoAdManagerDidCloseLinear:(OXMVideoAdManager*)adManager;

/** This method is invoked when the video begins / plays
 @param none
 */
- (void) videoAdManagerDidStart:(OXMVideoAdManager*)adManager;

/** This method is invoked when the video begins / plays
 @param none
 */
- (void) videoAdManagerDidStop:(OXMVideoAdManager*)adManager;

/** This method is invoked when the video is skipped
 @param none
 */
- (void) videoAdManagerDidSkip:(OXMVideoAdManager*)adManager;

/** This method is invoked when the video playhead is rewound
 @param none
 */
- (void) videoAdManagerDidRewind:(OXMVideoAdManager*)adManager;

/** This method is invoked to give the video the ability to report it's progress
 @param NSString the
 */
- (void) videoAdManagerDidHaveProgress:(OXMVideoAdManager*)adManager;


/** This method is invoked when the video playback is paused
 @param none
 */
- (void) videoAdManagerDidPause:(OXMVideoAdManager*)adManager;

/** This method is invoked when the video playback resumes after a pause (Is NOT the same as the start method)
 @param none
 */
- (void) videoAdManagerDidResume:(OXMVideoAdManager*)adManager;

/** This method is invoked when the video audio is muted
 @param none
 */
- (void) videoAdManagerDidMute:(OXMVideoAdManager*)adManager;

/** This method is invoked when the video audio is unmuted
 @param none
 */
- (void) videoAdManagerDidUnmute:(OXMVideoAdManager*)adManager;

@end


/** The OXMVideoAdManager gives you the ability to create a VAST-capable video player object to be used in your project.
 */
@interface OXMVideoAdManager : NSObject

/**
 @param isInFeed BOOL value that controls whether or not the OXMVideoAdManager is being used in-feed
 */
@property (nonatomic) BOOL isInFeed;
/**
 @param muteOnAutoPlay BOOL value that controls whether or not in-feed videos are automatically muted or not - the default is true
 */
@property (nonatomic) BOOL muteOnAutoPlay;

/** AutoPlayConfig
 @param autoPlayConfig enum that controls the auto-play behavior of in-feed video
 */
@property (nonatomic) AutoPlayConfig autoPlayConfig;

/** Auto Rotate Orientation
 @param autoRotateOrientation BOOL value that tells ad manager how to hand orientation
 */
@property (nonatomic, assign) BOOL autoRotateOrientation;

/** Video Player View
 @param videoPlayerView View that contains the Video Player
 */
@property (nonatomic, strong) OXMMediaPlaybackView *videoPlayerView;

/** Video Container
 @param videoContainer View that contains the Content Player
 */
@property (nonatomic, strong) UIView *videoContainer;

/** You may specify how long a user must wait before they are able to skip over the ad.
 @param skipOffSet should be passed in as a string formatted as HH:mm:ss.
 e.g. [self.adController setSkipOffSet:@"00:00:05"] is equal to 5 seconds.
 */
- (void) setSkipOffSet:(NSString*)skipOffSet;


/** Content Playlist
 @param contentPlaylist an array list of video content url's to be played.
 e.g. @[@"http://MY-CONTENT-URL-1",@"http://MY-CONTENT-URL-2",@"http://MY-CONTENT-URL-3"]
 */
@property (nonatomic, strong) NSArray *contentPlaylist;

/** Content Ad Breaks
 @param contentAdBreaks an array list of times where ad breaks should be inserted into content playback.
 e.g. @[@"00:00:30.000",@"00:01:00.000",@"00:01:30.000"]
 */
@property (nonatomic, strong) NSArray *contentAdBreaks;

/** Custom Content Playback View
 @param customContentPlaybackView object used to display content video(s).
 */
@property (nonatomic, strong) UIView *customContentPlaybackView;

/** Custom Content Player
 @param customContentPlayer object used to play content video(s).
 */
@property (nonatomic, strong) id customContentPlayer;


/** Custom Ad Player
 @param customAdPlayer object used to play ad videos.
 */
@property (nonatomic, strong) id customAdPlayer;


/** VAST URL
 @param vastTag Video VAST Tag for ads
 */
@property (nonatomic, strong) NSString *vastTag;

/** isLoaded BOOL
 @param loaded returns a boolean telling you if the ad manager is loaded
 */
@property (nonatomic, readonly, getter=isLoaded) BOOL loaded;

/** fullScreenOnOrientationChange BOOL
 @param fullScreenOnOrientationChange returns a boolean telling you if content should automatically shift orientation upon rotating the device.
 */
@property (nonatomic, assign) BOOL fullScreenOnOrientationChange;

/** fullScreenOnStart BOOL
 @param fullScreenOnStart returns a boolean telling you if content should start in landscape mode
 */
@property (nonatomic, assign) BOOL fullScreenOnStart;

/** Ad Request
 @param ad request object
 ---------
 By accessing the request object you can set optional targeting data which will be sent with the ad requests. This is also how you would disable the location auto-detection feature, which currently is on by default.
 */
@property (nonatomic, readonly) OXMAdRequest *adRequest;

/** Main delegate which will handle methods from _OXMVideoAdManagerDelegate_ protocol. */
@property (nonatomic,weak) id <OXMVideoAdManagerDelegate> delegate;


/** Initialize the Ad Manager With A VAST Ad Tag
 @param vTag string that contains the VAST url
 -----------
 */
-(id) initWithVASTTag:(NSString*)vTag;


/** You call this method when using either a custom MPMoviePlayerController or AVPlayer.
 @param none
 */
-(void)requestAdvertiserInformation:(UIButton*)sender;


/** Start Loading Ad Manager
 @param none
 -----------
 */
-(void) startAdManager;


@end
