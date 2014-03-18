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

- (id)initWithFrame:(CGRect)frame videoUrl:(AVURLAsset *)videoUrl
{    
    self = [super initWithFrame:frame];
    if (self) {
        
        _frameWidth = frame.size.width;
        
        int thumbWidth = ceil(frame.size.width*0.05);
        
        _backgroundView = [[UIControl alloc] initWithFrame:CGRectMake(thumbWidth-BG_VIEW_BORDERS_SIZE, 0, frame.size.width-(thumbWidth*2)+BG_VIEW_BORDERS_SIZE*2, frame.size.height)];
        _backgroundView.layer.borderColor = [UIColor grayColor].CGColor;
        _backgroundView.layer.borderWidth = BG_VIEW_BORDERS_SIZE;
        [self addSubview:_backgroundView];
        
        _videoAsset = videoUrl;
        
        _topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, SLIDER_BORDERS_SIZE)];
        _topBorder.backgroundColor = [UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 1];
        [self addSubview:_topBorder];
        
        
        _bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-SLIDER_BORDERS_SIZE, frame.size.width, SLIDER_BORDERS_SIZE)];
        _bottomBorder.backgroundColor = [UIColor colorWithRed: 0.992 green: 0.902 blue: 0.004 alpha: 1];
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

-(void)setPopoverBubbleSize: (CGFloat) width height:(CGFloat)height
{
    CGRect currentFrame = self.popoverBubble.frame;
    currentFrame.size.width = width;
    currentFrame.size.height = height;
    currentFrame.origin.y = -height;
    self.popoverBubble.frame = currentFrame;
    
    currentFrame.origin.x = 0;
    currentFrame.origin.y = 0;
    self.bubbleText.frame = currentFrame;
    
}

-(void)setMaxGap:(NSInteger)maxGap
{
    self.leftPosition = 0;
    self.rightPosition = self.frameWidth*maxGap/self.durationSeconds;
    self.maxGap = maxGap;
}

-(void)setMinGap:(NSInteger)minGap
{
    self.leftPosition = 0;
    self.rightPosition = self.frameWidth*minGap/self.durationSeconds;
    self.minGap = minGap;
}

#pragma mark - Gestures

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gesture translationInView:self];
        
        self.leftPosition += translation.x;
        if (self.leftPosition < 0)
        {
            self.leftPosition = 0;
        }
        
        if (
            (self.rightPosition-self.leftPosition <= self.leftThumb.frame.size.width+self.rightThumb.frame.size.width) ||
            ((self.maxGap > 0) && (self.rightPosition-self.leftPosition > self.maxGap)) ||
            ((self.minGap > 0) && (self.rightPosition-self.leftPosition < self.minGap))
            )
        {
            self.leftPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        [self setNeedsLayout];
        if ([self.delegate respondsToSelector:@selector(videoRange:didChangeLeftPosition:rightPosition:)])
        {
            [self.delegate videoRange:self didChangeLeftPosition:self.leftPosition rightPosition:self.rightPosition];
        }
    }
    
    self.popoverBubble.alpha = 1;
    [self setTimeLabel];
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self hideBubble:self.popoverBubble];
    }
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gesture translationInView:self];
        self.rightPosition += translation.x;
        if (self.rightPosition < 0)
        {
            self.rightPosition = 0;
        }
        
        if (self.rightPosition > self.frameWidth)
        {
            self.rightPosition = self.frameWidth;
        }
        
        if (self.rightPosition-self.leftPosition <= 0)
        {
            self.rightPosition -= translation.x;
        }
        
        if ((self.rightPosition-self.leftPosition <= self.leftThumb.frame.size.width+self.rightThumb.frame.size.width) ||
            ((self.maxGap > 0) && (self.rightPosition-self.leftPosition > self.maxGap)) ||
            ((self.minGap > 0) && (self.rightPosition-self.leftPosition < self.minGap)))
        {
            self.rightPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        [self setNeedsLayout];
        if ([self.delegate respondsToSelector:@selector(videoRange:didChangeLeftPosition:rightPosition:)])
        {
            [self.delegate videoRange:self didChangeLeftPosition:self.leftPosition rightPosition:self.rightPosition];
        }
    }
    
    self.popoverBubble.alpha = 1.0;
    [self setTimeLabel];
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self hideBubble:self.popoverBubble];
    }
}

- (void)handleCenterPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gesture translationInView:self];
        
        self.leftPosition += translation.x;
        self.rightPosition += translation.x;
        
        if (self.rightPosition > self.frameWidth || self.leftPosition < 0)
        {
            self.leftPosition -= translation.x;
            self.rightPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        [self setNeedsLayout];
        if ([self.delegate respondsToSelector:@selector(videoRange:didChangeLeftPosition:rightPosition:)])
        {
            [self.delegate videoRange:self didChangeLeftPosition:self.leftPosition rightPosition:self.rightPosition];
        }
    }
    
    self.popoverBubble.alpha = 1;
    [self setTimeLabel];
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self hideBubble:self.popoverBubble];
    }
}

- (void)layoutSubviews
{
    CGFloat inset = self.leftThumb.frame.size.width / 2;
    self.leftThumb.center = CGPointMake(self.leftPosition+inset, self.leftThumb.frame.size.height/2);
    self.rightThumb.center = CGPointMake(self.rightPosition-inset, self.rightThumb.frame.size.height/2);
    self.topBorder.frame = CGRectMake(self.leftThumb.frame.origin.x + self.leftThumb.frame.size.width, 0, self.rightThumb.frame.origin.x - self.leftThumb.frame.origin.x - self.leftThumb.frame.size.width/2, SLIDER_BORDERS_SIZE);
    self.bottomBorder.frame = CGRectMake(self.leftThumb.frame.origin.x + self.leftThumb.frame.size.width, self.backgroundView.frame.size.height-SLIDER_BORDERS_SIZE, self.rightThumb.frame.origin.x - self.leftThumb.frame.origin.x - self.leftThumb.frame.size.width/2, SLIDER_BORDERS_SIZE);
    self.centerView.frame = CGRectMake(self.leftThumb.frame.origin.x + self.leftThumb.frame.size.width, self.centerView.frame.origin.y, self.rightThumb.frame.origin.x - self.leftThumb.frame.origin.x - self.leftThumb.frame.size.width, self.centerView.frame.size.height);
    
    CGRect frame = self.popoverBubble.frame;
    frame.origin.x = self.centerView.frame.origin.x+self.centerView.frame.size.width/2-frame.size.width/2;
    self.popoverBubble.frame = frame;
}

#pragma mark - Video

-(void)getMovieFrames
{
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.videoAsset];
    
    if ([self isRetina])
        self.imageGenerator.maximumSize = CGSizeMake(self.backgroundView.frame.size.width*2, self.backgroundView.frame.size.height*2);
    else
        self.imageGenerator.maximumSize = CGSizeMake(self.backgroundView.frame.size.width, self.backgroundView.frame.size.height);
    
    int picWidth = 49;
    
    // First image
    NSError *error;
    CMTime actualTime;
    CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:&error];
    if (halfWayImage != NULL)
    {
        UIImage *videoScreen;
        if ([self isRetina])
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
        else
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
        
        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
        [self.backgroundView addSubview:tmp];
        picWidth = tmp.frame.size.width;
        CGImageRelease(halfWayImage);
    }
    
    self.durationSeconds = CMTimeGetSeconds(self.videoAsset.duration);
    int picsCnt = ceil(self.backgroundView.frame.size.width / picWidth);
    NSMutableArray *allTimes = [[NSMutableArray alloc] init];
    int time4Pic = 0;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        // Bug iOS7 - generateCGImagesAsynchronouslyForTimes
        for (int i=1, ii=1; i<picsCnt; i++)
        {
            time4Pic = i*picWidth;
            CMTime timeFrame = CMTimeMakeWithSeconds(self.durationSeconds*time4Pic/self.backgroundView.frame.size.width, 600);

            [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
            
            CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:timeFrame actualTime:&actualTime error:&error];
            UIImage *videoScreen;
            if ([self isRetina])
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
            else
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
            
            UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
            int all = (ii+1)*tmp.frame.size.width;
            
            CGRect currentFrame = tmp.frame;
            currentFrame.origin.x = ii*currentFrame.size.width;
            if (all > self.backgroundView.frame.size.width)
            {
                int delta = all - self.backgroundView.frame.size.width;
                currentFrame.size.width -= delta;
            }
            
            tmp.frame = currentFrame;
            ii++;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.backgroundView addSubview:tmp];
            });
            
            CGImageRelease(halfWayImage);
        }

        return;
    }
    
    for (int i=1; i<picsCnt; i++)
    {
        time4Pic = i*picWidth;
        CMTime timeFrame = CMTimeMakeWithSeconds(self.durationSeconds*time4Pic/self.backgroundView.frame.size.width, 600);
        [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
    }
    
    NSArray *times = allTimes;
    
    __block int i = 1;
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
                                              {
                                                  if (result == AVAssetImageGeneratorSucceeded)
                                                  {
                                                      UIImage *videoScreen;
                                                      if ([self isRetina])
                                                          videoScreen = [[UIImage alloc] initWithCGImage:image scale:2.0 orientation:UIImageOrientationUp];
                                                      else
                                                          videoScreen = [[UIImage alloc] initWithCGImage:image];
                                                      
                                                      UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
                                                      int all = (i+1)*tmp.frame.size.width;
                                                      
                                                      CGRect currentFrame = tmp.frame;
                                                      currentFrame.origin.x = i*currentFrame.size.width;
                                                      if (all > self.backgroundView.frame.size.width)
                                                      {
                                                          int delta = all - self.backgroundView.frame.size.width;
                                                          currentFrame.size.width -= delta;
                                                      }
                                                      tmp.frame = currentFrame;
                                                      i++;
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [self.backgroundView addSubview:tmp];
                                                      });
                                                  }
                                                  
                                                  if (result == AVAssetImageGeneratorFailed)
                                                      NSLog(@"Failed with error: %@", [error localizedDescription]);

                                                  if (result == AVAssetImageGeneratorCancelled)
                                                      NSLog(@"Canceled");
                                              }];
}

#pragma mark - Properties

- (CGFloat)leftPosition
{
    return self.leftPosition * self.durationSeconds / self.frameWidth;
}

- (CGFloat)rightPosition
{
    return self.rightPosition * self.durationSeconds / self.frameWidth;
}

#pragma mark - Bubble

- (void)hideBubble:(UIView *)popover
{
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void)
                     {
                         self.popoverBubble.alpha = 0;
                     }
                     completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(videoRange:didGestureStateEndedLeftPosition:rightPosition:)])
    {
        [self.delegate videoRange:self didGestureStateEndedLeftPosition:self.leftPosition rightPosition:self.rightPosition];
    }
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

-(BOOL)isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0));
}

@end
