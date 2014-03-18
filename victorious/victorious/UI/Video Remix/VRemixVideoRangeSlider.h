//
//  VRemixVideoRangeSlider.h
//

@import AVFoundation;

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

- (id)initWithFrame:(CGRect)frame videoUrl:(AVURLAsset *)videoUrl;
- (void)setPopoverBubbleWidth:(CGFloat)width height:(CGFloat)height;

@end


@protocol VRemixVideoRangeSliderDelegate <NSObject>
@optional

- (void)videoRange:(VRemixVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;
- (void)videoRange:(VRemixVideoRangeSlider *)videoRange didGestureStateEndedLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;

@end




