//
//  VRemixVideoRangeSlider.h
//

@import AVFoundation;

@class VCVideoPlayerViewController;

@protocol VRemixVideoRangeSliderDelegate;

@interface VRemixVideoRangeSlider : UIView
@property (nonatomic, weak) id<VRemixVideoRangeSliderDelegate> delegate;
@property (nonatomic) CGFloat leftPosition;
@property (nonatomic) CGFloat rightPosition;
@property (nonatomic, strong) UILabel *bubbleText;
@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;
@property (nonatomic, assign) NSInteger maxGap;
@property (nonatomic, assign) NSInteger minGap;

@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayerViewController;

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl;
- (void)setPopoverBubbleWidth:(CGFloat)width height:(CGFloat)height;

- (void)cancel;

@end


@protocol VRemixVideoRangeSliderDelegate <NSObject>
@optional

- (void)videoRange:(VRemixVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;
- (void)videoRange:(VRemixVideoRangeSlider *)videoRange didGestureStateEndedLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;

@end




