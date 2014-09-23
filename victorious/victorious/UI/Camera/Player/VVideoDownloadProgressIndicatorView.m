//
//  VVideoDownloadProgressIndicatorView.m
//  victorious
//
//  Created by Josh Hinman on 5/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVideoDownloadProgressIndicatorView.h"

static const CGFloat kCornerWidth = 2.0f;

@implementation VVideoDownloadProgressIndicatorView

- (void)drawRect:(CGRect)rect
{
    if (CMTIME_IS_INVALID(self.duration) || CMTIME_IS_INDEFINITE(self.duration))
    {
        return;
    }
    
    CGFloat cornerWidth = MIN(kCornerWidth, CGRectGetHeight(self.bounds) * 0.5f);
    
    for (NSValue *timeRange in self.loadedTimeRanges)
    {
        if ([timeRange isKindOfClass:[NSValue class]])
        {
            CMTimeRange range = [timeRange CMTimeRangeValue];
            if (CMTIMERANGE_IS_VALID(range) && !CMTIMERANGE_IS_INDEFINITE(range) && range.duration.value > 0)
            {
                CMTime end = CMTimeRangeGetEnd(range);
                Float64 duration = CMTimeGetSeconds(self.duration);
                CGFloat startX = CMTimeGetSeconds(range.start) / duration * CGRectGetWidth(self.bounds);
                CGFloat endX = CMTimeGetSeconds(end) / duration * CGRectGetWidth(self.bounds);
                CGFloat width = MAX(endX - startX, kCornerWidth * 2.0f);
                
                CGPathRef rect = CGPathCreateWithRoundedRect(CGRectMake(startX, 0, width, CGRectGetHeight(self.bounds)), cornerWidth, cornerWidth, NULL);
                CGContextAddPath(UIGraphicsGetCurrentContext(), rect);
                [self.color setFill];
                CGContextFillPath(UIGraphicsGetCurrentContext());
                CGPathRelease(rect);
            }
        }
    }
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}

- (void)setLoadedTimeRanges:(NSArray *)loadedTimeRanges
{
    _loadedTimeRanges = loadedTimeRanges;
    [self setNeedsDisplay];
}

- (void)setDuration:(CMTime)duration
{
    _duration = duration;
    [self setNeedsDisplay];
}

@end
