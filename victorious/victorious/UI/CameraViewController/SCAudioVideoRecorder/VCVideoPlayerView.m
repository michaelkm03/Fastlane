//
//  VCVideoPlayerView
//

#import "VCVideoPlayerView.h"


////////////////////////////////////////////////////////////
// PRIVATE DEFINITION
/////////////////////

@interface VCVideoPlayerView() {
	UIView * _loadingView;
}

@property (strong, nonatomic, readwrite) VCPlayer * player;
@property (strong, nonatomic, readwrite) AVPlayerLayer * playerLayer;

@end

////////////////////////////////////////////////////////////
// IMPLEMENTATION
/////////////////////

@implementation VCVideoPlayerView

@synthesize player;
@synthesize playerLayer;

- (id) init {
	self = [super init];
	
	if (self) {
		_loadingView = nil;
		[self commonInit];
	}
	
	return self;
}

- (void) dealloc {
	[self.player cleanUp];
	self.playerLayer.player = nil;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		[self commonInit];
	}
	
	return self;
}

- (void) commonInit {
	self.player = [VCPlayer player];
	self.player.delegate = self;
	self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
	self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.layer addSublayer:self.playerLayer];
	
	UIView * theLoadingView = [[UIView alloc] init];
	theLoadingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
	
	UIActivityIndicatorView * theIndicatorView = [[UIActivityIndicatorView alloc] init];
	[theIndicatorView startAnimating];
	theIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	
	[theLoadingView addSubview:theIndicatorView];
	
	self.loadingView = theLoadingView;
	self.loadingView.hidden = YES;
	self.clipsToBounds = YES;
}

- (void) videoPlayer:(VCPlayer *)videoPlayer didStartLoadingAtItemTime:(CMTime)itemTime {
//	self.loadingView.hidden = NO;
}

- (void) videoPlayer:(VCPlayer *)videoPlayer didEndLoadingAtItemTime:(CMTime)itemTime {
//	self.loadingView.hidden = YES;
}

- (void) videoPlayer:(VCPlayer *)videoPlayer didPlay:(Float32)secondsElapsed {
	
}

- (void) videoPlayer:(VCPlayer *)videoPlayer didChangeItem:(AVPlayerItem *)item {
//	self.loadingView.hidden = item == nil;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	self.playerLayer.frame = self.bounds;
	self.loadingView.frame = self.bounds;
}

- (void) setLoadingView:(UIView *)loadingView {
	if (_loadingView != nil) {
		[_loadingView removeFromSuperview];
	}
	
	_loadingView = loadingView;
	
	if (_loadingView != nil) {
		[self addSubview:_loadingView];
	}
}

@end
