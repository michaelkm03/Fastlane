//
//  VScrollingTextView.m
//  victorious
//
//  Created by Vincent Ho on 2/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import "VScrollingTextView.h"
#import "VLinearGradientView.h"

static CGFloat const kScrollBoundary = 20.0f;

@interface VScrollingTextView()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL scrollDown;
@property (nonatomic, strong) VLinearGradientView *gradient;
@property (nonatomic) CGFloat scrollSpeed;
@end

@implementation VScrollingTextView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
    }
    return self;
}

- (void)stopScroll
{
    [self.timer invalidate];
}

/// Speed is number of pixel points per second
- (void)startScrollWithScrollSpeed:(CGFloat)speed
{
    self.scrollSpeed = speed;
    [self startScroll];
}

- (void)startScroll
{
    if (self.timer)
    {
        [self.timer invalidate];
    }
    if (self.contentSize.height > self.maxThreshold)
    {
        self.timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(autoscrollTimerFired) userInfo:nil repeats:YES];
        self.scrollDown = YES;
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)autoscrollTimerFired
{
    CGFloat yOffset = self.contentOffset.y;
    if (self.scrollDown)
    {
        yOffset += self.scrollSpeed;
        CGFloat maxOffset = self.contentSize.height - self.bounds.size.height + kScrollBoundary;
        if (yOffset > maxOffset)
        {
            yOffset = maxOffset;
            self.scrollDown = NO;
        }
    }
    else
    {
        yOffset -= 5*self.scrollSpeed;
        if (yOffset < -kScrollBoundary)
        {
            yOffset = -kScrollBoundary;
            self.scrollDown = YES;
        }
    }
    
    [self setContentOffset:CGPointMake(0, yOffset) animated:YES];
    
}

#pragma mark - UITextViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startScroll];
}

#pragma mark - Dealloc

- (void)dealloc
{
    [self.timer invalidate];
}

#pragma mark - Setters

- (void)setQuestion:(NSAttributedString *)question
{
    _question = question;
    self.attributedText = question;
}

@end
