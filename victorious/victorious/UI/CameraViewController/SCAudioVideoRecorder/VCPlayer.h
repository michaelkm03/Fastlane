//
//  VCPlayer
//

@import AVFoundation;

@class VCPlayer;

@protocol VCVideoPlayerDelegate <NSObject>

@optional

- (void) videoPlayer:(VCPlayer*)videoPlayer didPlay:(Float32)secondsElapsed;
- (void) videoPlayer:(VCPlayer *)videoPlayer didStartLoadingAtItemTime:(CMTime)itemTime;
- (void) videoPlayer:(VCPlayer *)videoPlayer didEndLoadingAtItemTime:(CMTime)itemTime;
- (void) videoPlayer:(VCPlayer *)videoPlayer didChangeItem:(AVPlayerItem*)item;

@end

@interface VCPlayer : AVPlayer

+ (VCPlayer*) player;
+ (void) pauseCurrentPlayer;
+ (VCPlayer*) currentPlayer;

- (void) cleanUp;

- (void) setItemByStringPath:(NSString*)stringPath;
- (void) setItemByUrl:(NSURL*)url;
- (void) setItemByAsset:(AVAsset*)asset;
- (void) setItem:(AVPlayerItem*)item;

// These methods allow the player to add the same item "loopCount" time
// in order to have a smooth loop. The loop system provided by Apple
// has an unvoidable hiccup. Using these methods will avoid the hiccup for "loopCount" time

- (void) setSmoothLoopItemByStringPath:(NSString*)stringPath smoothLoopCount:(NSUInteger)loopCount;
- (void) setSmoothLoopItemByUrl:(NSURL*)url smoothLoopCount:(NSUInteger)loopCount;
- (void) setSmoothLoopItemByAsset:(AVAsset*)asset smoothLoopCount:(NSUInteger)loopCount;

- (CMTime) playableDuration;
- (BOOL) isPlaying;
- (BOOL) isLoading;

@property (weak, nonatomic, readwrite) id<VCVideoPlayerDelegate> delegate;
@property (assign, nonatomic, readwrite) CMTime minimumBufferedTimeBeforePlaying;
@property (assign, nonatomic, readwrite) BOOL shouldLoop;

@property (nonatomic, assign)   CGFloat     startSeconds;
@property (nonatomic, assign)   CGFloat     endSeconds;

@end
