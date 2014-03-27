//
//  VCVideoPlayerView
//

#import <UIKit/UIKit.h>
#import "VCPlayer.h"

@class VCVideoPlayerView;

@interface VCVideoPlayerView : UIView<VCVideoPlayerDelegate>

@property (strong, nonatomic, readonly) VCPlayer * player;
@property (strong, nonatomic, readonly) AVPlayerLayer * playerLayer;
@property (strong, nonatomic, readwrite) UIView * loadingView;

@end
