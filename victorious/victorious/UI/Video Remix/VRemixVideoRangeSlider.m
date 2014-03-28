//
//  VRemixVideoRangeSlider.m
//

#import "VRemixVideoRangeSlider.h"
#import "VRemixSliderLeft.h"
#import "VRemixSliderRight.h"
#import "VRemixResizableBubble.h"

@interface VRemixVideoRangeSlider ()
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) AVURLAsset* videoAsset;
@property (nonatomic, strong) VRemixSliderLeft *leftThumb;
@property (nonatomic, strong) VRemixSliderRight *rightThumb;
@property (nonatomic, strong) VRemixResizableBubble *popoverBubble;
@property (nonatomic) CGFloat frameWidth;
@property (nonatomic) Float64 durationSeconds;
@end

#define SLIDER_BORDERS_SIZE 6.0f
#define BG_VIEW_BORDERS_SIZE 3.0f

@implementation VRemixVideoRangeSlider

- (id)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoAssetURL
{    
    self = [super initWithFrame:frame];
    if (self)
    {
        _frameWidth = frame.size.width;

        int thumbWidth = ceil(frame.size.width*0.05);

        _backgroundView = [[UIControl alloc] initWithFrame:CGRectMake(thumbWidth-BG_VIEW_BORDERS_SIZE, 0, frame.size.width-(thumbWidth*2)+BG_VIEW_BORDERS_SIZE*2, frame.size.height)];
        _backgroundView.layer.borderColor = [UIColor grayColor].CGColor;
        _backgroundView.layer.borderWidth = BG_VIEW_BORDERS_SIZE;
        [self addSubview:_backgroundView];

        _videoAsset = [AVURLAsset assetWithURL:videoAssetURL];

        _topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, SLIDER_BORDERS_SIZE)];
        _topBorder.backgroundColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
        [self addSubview:_topBorder];


        _bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-SLIDER_BORDERS_SIZE, frame.size.width, SLIDER_BORDERS_SIZE)];
        _bottomBorder.backgroundColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
        [self addSubview:_bottomBorder];


        _leftThumb = [[VRemixSliderLeft alloc] initWithFrame:CGRectMake(0, 0, thumbWidth, frame.size.height)];
        _leftThumb.contentMode = UIViewContentModeLeft;
        _leftThumb.userInteractionEnabled = YES;
        _leftThumb.clipsToBounds = YES;
        _leftThumb.backgroundColor = [UIColor clearColor];
        _leftThumb.layer.borderWidth = 0;
        [self addSubview:_leftThumb];


        UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
        [_leftThumb addGestureRecognizer:leftPan];


        _rightThumb = [[VRemixSliderRight alloc] initWithFrame:CGRectMake(0, 0, thumbWidth, frame.size.height)];

        _rightThumb.contentMode = UIViewContentModeRight;
        _rightThumb.userInteractionEnabled = YES;
        _rightThumb.clipsToBounds = YES;
        _rightThumb.backgroundColor = [UIColor clearColor];
        [self addSubview:_rightThumb];

        UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
        [_rightThumb addGestureRecognizer:rightPan];

        _rightPosition = frame.size.width;
        _leftPosition = 0;

        _centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _centerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_centerView];

        UIPanGestureRecognizer *centerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCenterPan:)];
        [_centerView addGestureRecognizer:centerPan];


        _popoverBubble = [[VRemixResizableBubble alloc] initWithFrame:CGRectMake(0, -50, 100, 50)];
        _popoverBubble.alpha = 0;
        _popoverBubble.backgroundColor = [UIColor clearColor];
        [self addSubview:_popoverBubble];


        _bubbleText = [[UILabel alloc] initWithFrame:_popoverBubble.frame];
        _bubbleText.font = [UIFont boldSystemFontOfSize:20];
        _bubbleText.backgroundColor = [UIColor clearColor];
        _bubbleText.textColor = [UIColor blackColor];
        _bubbleText.textAlignment = NSTextAlignmentCenter;
        
        [_popoverBubble addSubview:_bubbleText];
        
        [self getMovieFrames];
    }
    
    return self;
}

-(void)setPopoverBubbleWidth:(CGFloat)width height:(CGFloat)height
{
    CGRect currentFrame = _popoverBubble.frame;
    currentFrame.size.width = width;
    currentFrame.size.height = height;
    currentFrame.origin.y = -height;
    _popoverBubble.frame = currentFrame;

    currentFrame.origin.x = 0;
    currentFrame.origin.y = 0;
    _bubbleText.frame = currentFrame;
}

-(void)setMaxGap:(NSInteger)maxGap
{
    _leftPosition = 0;
    _rightPosition = _frameWidth * maxGap / _durationSeconds;
    _maxGap = maxGap;
}

-(void)setMinGap:(NSInteger)minGap
{
    _leftPosition = 0;
    _rightPosition = _frameWidth * minGap / _durationSeconds;
    _minGap = minGap;
}

#pragma mark - Gestures

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gesture translationInView:self];

        _leftPosition += translation.x;
        if (_leftPosition < 0)
        {
            _leftPosition = 0;
        }

        if (
            (_rightPosition-_leftPosition <= _leftThumb.frame.size.width+_rightThumb.frame.size.width) ||
            ((self.maxGap > 0) && (self.rightPosition-self.leftPosition > self.maxGap)) ||
            ((self.minGap > 0) && (self.rightPosition-self.leftPosition < self.minGap))
            )
        {
            _leftPosition -= translation.x;
        }

        [gesture setTranslation:CGPointZero inView:self];
        [self setNeedsLayout];
        if ([_delegate respondsToSelector:@selector(videoRange:didChangeLeftPosition:rightPosition:)])
            [_delegate videoRange:self didChangeLeftPosition:self.leftPosition rightPosition:self.rightPosition];
    }

    _popoverBubble.alpha = 1;

    [self setTimeLabel];

    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self hideBubble:_popoverBubble];
    }
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gesture translationInView:self];
        _rightPosition += translation.x;
        if (_rightPosition < 0)
        {
            _rightPosition = 0;
        }

        if (_rightPosition > _frameWidth)
        {
            _rightPosition = _frameWidth;
        }

        if (_rightPosition-_leftPosition <= 0)
        {
            _rightPosition -= translation.x;
        }

        if ((_rightPosition-_leftPosition <= _leftThumb.frame.size.width+_rightThumb.frame.size.width) ||
            ((self.maxGap > 0) && (self.rightPosition-self.leftPosition > self.maxGap)) ||
            ((self.minGap > 0) && (self.rightPosition-self.leftPosition < self.minGap)))
        {
            _rightPosition -= translation.x;
        }


        [gesture setTranslation:CGPointZero inView:self];
        [self setNeedsLayout];
        if ([_delegate respondsToSelector:@selector(videoRange:didChangeLeftPosition:rightPosition:)])
            [_delegate videoRange:self didChangeLeftPosition:self.leftPosition rightPosition:self.rightPosition];
    }

    _popoverBubble.alpha = 1;

    [self setTimeLabel];
    
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self hideBubble:_popoverBubble];
    }
}

- (void)handleCenterPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gesture translationInView:self];

        _leftPosition += translation.x;
        _rightPosition += translation.x;

        if (_rightPosition > _frameWidth || _leftPosition < 0)
        {
            _leftPosition -= translation.x;
            _rightPosition -= translation.x;
        }

        [gesture setTranslation:CGPointZero inView:self];
        [self setNeedsLayout];
        if ([_delegate respondsToSelector:@selector(videoRange:didChangeLeftPosition:rightPosition:)])
            [_delegate videoRange:self didChangeLeftPosition:self.leftPosition rightPosition:self.rightPosition];
    }

    _popoverBubble.alpha = 1;

    [self setTimeLabel];

    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self hideBubble:_popoverBubble];
    }
}

- (void)layoutSubviews
{
    CGFloat inset = _leftThumb.frame.size.width / 2;

    _leftThumb.center = CGPointMake(_leftPosition+inset, _leftThumb.frame.size.height/2);
    _rightThumb.center = CGPointMake(_rightPosition-inset, _rightThumb.frame.size.height/2);
    _topBorder.frame = CGRectMake(_leftThumb.frame.origin.x + _leftThumb.frame.size.width, 0, _rightThumb.frame.origin.x - _leftThumb.frame.origin.x - _leftThumb.frame.size.width/2, SLIDER_BORDERS_SIZE);
    _bottomBorder.frame = CGRectMake(_leftThumb.frame.origin.x + _leftThumb.frame.size.width, _backgroundView.frame.size.height-SLIDER_BORDERS_SIZE, _rightThumb.frame.origin.x - _leftThumb.frame.origin.x - _leftThumb.frame.size.width/2, SLIDER_BORDERS_SIZE);
    _centerView.frame = CGRectMake(_leftThumb.frame.origin.x + _leftThumb.frame.size.width, _centerView.frame.origin.y, _rightThumb.frame.origin.x - _leftThumb.frame.origin.x - _leftThumb.frame.size.width, _centerView.frame.size.height);

    CGRect frame = _popoverBubble.frame;
    frame.origin.x = _centerView.frame.origin.x+_centerView.frame.size.width/2-frame.size.width/2;
    _popoverBubble.frame = frame;
}

#pragma mark - Video

-(void)getMovieFrames
{
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.videoAsset];
    self.imageGenerator.maximumSize = CGSizeMake(84, 84);

    int picWidth = 42;

    // First image
//    CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:nil error:nil];
//    if (halfWayImage != NULL)
//    {
//        UIImage *videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
//        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
//        tmp.frame = CGRectMake(0, 0, 42, 42);
//        tmp.contentMode = UIViewContentModeScaleAspectFill;
//        [_backgroundView addSubview:tmp];
//        picWidth = tmp.frame.size.width;
//        CGImageRelease(halfWayImage);
//    }

    _durationSeconds = CMTimeGetSeconds([self.videoAsset duration]);
    int picsCnt = ceil(_backgroundView.frame.size.width / picWidth);
    NSMutableArray *allTimes = [[NSMutableArray alloc] init];
    int time4Pic = 0;

    for (int i=0; i<picsCnt; i++)
    {
        time4Pic = i*picWidth;
        CMTime timeFrame = CMTimeMakeWithSeconds(_durationSeconds*time4Pic/_backgroundView.frame.size.width, 600);
        [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
    }

    NSArray *times = allTimes;
    __block int i = 0;
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
                                                {
                                                  if (result == AVAssetImageGeneratorSucceeded)
                                                  {
                                                      UIImage *videoScreen = [[UIImage alloc] initWithCGImage:image];
                                                      UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
                                                      tmp.frame = CGRectMake(0, 0, 42, 42);
                                                      tmp.contentMode = UIViewContentModeScaleAspectFill;

                                                      int all = (i+1)*tmp.frame.size.width;

                                                      CGRect currentFrame = tmp.frame;
                                                      currentFrame.origin.x = i*currentFrame.size.width;
                                                      if (all > _backgroundView.frame.size.width)
                                                      {
                                                          int delta = all - _backgroundView.frame.size.width;
                                                          currentFrame.size.width -= delta;
                                                      }
                                                      tmp.frame = currentFrame;
                                                      i++;

                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [_backgroundView addSubview:tmp];
                                                      });
                                                  }

                                                  if (result == AVAssetImageGeneratorFailed)
                                                  {
                                                      NSLog(@"Failed with error: %@", [error localizedDescription]);
                                                  }
                                                  if (result == AVAssetImageGeneratorCancelled)
                                                  {
                                                      NSLog(@"Canceled");
                                                  }
                                              }];
}

#pragma mark - Properties

- (CGFloat)leftPosition
{
    return _leftPosition * _durationSeconds / _frameWidth;
}


- (CGFloat)rightPosition
{
    return _rightPosition * _durationSeconds / _frameWidth;
}

#pragma mark - Bubble

- (void)hideBubble:(UIView *)popover
{
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void)
                    {
                        _popoverBubble.alpha = 0;
                    }
                     completion:nil];

    if ([_delegate respondsToSelector:@selector(videoRange:didGestureStateEndedLeftPosition:rightPosition:)])
        [_delegate videoRange:self didGestureStateEndedLeftPosition:self.leftPosition rightPosition:self.rightPosition];
}

-(void)setTimeLabel
{
    self.bubbleText.text = [self trimIntervalString];
}

-(NSString *)trimDurationString
{
    int delta = floor(self.rightPosition - self.leftPosition);
    return [NSString stringWithFormat:@"%d", delta];
}

-(NSString *)trimIntervalString
{
    NSString *from = [self timeToStr:self.leftPosition];
    NSString *to = [self timeToStr:self.rightPosition];
    return [NSString stringWithFormat:@"%@ - %@", from, to];
}

#pragma mark - Support

- (NSString *)timeToStr:(CGFloat)time
{
    // time - seconds
    NSInteger min = floor(time / 60);
    NSInteger sec = floor(time - min * 60);
    NSString *minStr = [NSString stringWithFormat:min >= 10 ? @"%i" : @"0%i", min];
    NSString *secStr = [NSString stringWithFormat:sec >= 10 ? @"%i" : @"0%i", sec];
    return [NSString stringWithFormat:@"%@:%@", minStr, secStr];
}

@end
