//
//  VRemixVideoRangeSlider.h
//

@import AVFoundation;

@class VCVideoPlayerViewController, VRemixVideoRangeSlider;

@protocol VRemixVideoRangeSliderDelegate <NSObject>
@optional

- (void)videoRange:(VRemixVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;
- (void)videoRange:(VRemixVideoRangeSlider *)videoRange didGestureStateEndedLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;

@end

@interface VRemixVideoRangeSlider : UIView

@property (nonatomic, weak) id<VRemixVideoRangeSliderDelegate> delegate;
@property (nonatomic) CGFloat leftPosition;
@property (nonatomic) CGFloat rightPosition;
@property (nonatomic, strong) UILabel *bubbleText;
@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;
@property (nonatomic, assign) NSInteger maxGap;
@property (nonatomic, assign) NSInteger minGap;
@property (nonatomic, strong, readonly) AVAsset *videoAsset; ///< The video asset being scrubbed

- (instancetype)initWithFrame:(CGRect)frame videoAsset:(AVAsset *)asset;
- (void)updateScrubberPositionWithTime:(CMTime)time; ///< Positions the scrubber according to the given video timestamp
- (void)setPopoverBubbleWidth:(CGFloat)width height:(CGFloat)height;
- (void)cancel; ///< Cancels thumbnail generation

@end
