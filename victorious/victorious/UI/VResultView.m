//
//  VResultView.m
//  victorious
//
//  Created by Will Long on 3/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VResultView.h"

#import "UIView+VFrameManipulation.h"

@interface VResultView ()
@property (nonatomic) CGFloat progress;
@property (strong, nonatomic) UIView* endView;
@property (strong, nonatomic) UIView* progressView;
@property (strong, nonatomic) UIImageView* arrowTip;
@end

@implementation VResultView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame orientation:YES progress:0];
}

- (id)initWithFrame:(CGRect)frame orientation:(BOOL)isVertical
{
    return [self initWithFrame:frame orientation:isVertical progress:0];
}

- (id)initWithFrame:(CGRect)frame orientation:(BOOL)isVertical progress:(CGFloat)progress
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.isVertical = YES;
        [self setProgress:progress animated:NO];
    }
    return self;
}

- (UIView*)endView
{
    if (!_endView)
    {
        if (self.isVertical)
        {
            _endView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height * .8,
                                                                    self.frame.size.width, self.frame.size.height * .2)];
        }
        else
        {
            _endView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width * .2, self.frame.size.height)];
        }
        [self addSubview:_endView];
    }
    return _endView;
}


- (UIView*)progressView
{
    if (!_progressView)
    {
        if (self.isVertical)
        {
            _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height * .8,
                                                                         self.frame.size.width, 0)];
        }
        else
        {
            _progressView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width * .2, 0, 0, self.frame.size.height)];
        }
        [self addSubview:_progressView];
    }
    return _progressView;
}


- (UIView*)arrowTip
{
    if (!_arrowTip)
    {
        if (self.isVertical)
        {
            _arrowTip = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height * .6,
                                                                          self.frame.size.width,
                                                                          self.frame.size.height * .2)];
        }
        else
        {
            _arrowTip = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width * .2, 0,
                                                                          self.frame.size.width * .2, self.frame.size.height)];
        }
        [self addSubview:_arrowTip];
    }
    
    _arrowTip.contentMode = UIViewContentModeScaleToFill;
//    _arrowTip.image = [UIImage imageNamed:@"ProgressArrow"];
    
    return _arrowTip;
}

- (void)setIsVertical:(BOOL)isVertical
{
    _isVertical = isVertical;
    
    [self.endView removeFromSuperview];
    self.endView = nil;
    
    [self.progressView removeFromSuperview];
    self.progressView = nil;
    
    [self.arrowTip removeFromSuperview];
    self.progressView = nil;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    self.endView.backgroundColor = color;
    self.progressView.backgroundColor = color;
    self.arrowTip.backgroundColor = color;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:.5f animations:
        ^{
            self.progress = progress;
        }];
    }
    else
    {
        self.progress = progress;
    }
}

-(void)setProgress:(CGFloat)progress
{
    _progress = progress;
    CGFloat maxProgress = self.isVertical ? self.frame.size.height * .6 : self.frame.size.width * .6;
    CGFloat currentProgress = maxProgress * progress;
    if (self.isVertical)
    {
        self.progressView.frame = CGRectMake(0, (self.frame.size.height * .8) - currentProgress,
                                             self.frame.size.width, currentProgress);
        [self.arrowTip setYOrigin: self.progressView.frame.origin.y - self.arrowTip.frame.size.height];
    }
    else
    {
        self.progressView.frame = CGRectMake(self.frame.size.width * .2, 0, currentProgress, self.frame.size.height);
        [self.arrowTip setXOrigin:self.progressView.frame.origin.x + self.progressView.frame.size.width];
    }
}

@end
