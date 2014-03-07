//
//  SCVideoPlayerView
//

#import <UIKit/UIKit.h>
#import "SCPlayer.h"

@class SCVideoPlayerView;

@interface SCVideoPlayerView : UIView<SCVideoPlayerDelegate>

@property (strong, nonatomic, readonly) SCPlayer * player;
@property (strong, nonatomic, readonly) AVPlayerLayer * playerLayer;
@property (strong, nonatomic, readwrite) UIView * loadingView;

@end
