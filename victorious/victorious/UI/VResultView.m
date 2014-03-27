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
@property (strong, nonatomic) UIImageView* resultArrow;
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

- (void)setIsVertical:(BOOL)isVertical
{
    _isVertical = isVertical;
    
    [self.resultArrow removeFromSuperview];
    self.resultArrow = nil;
}

- (UIView*)resultArrow
{
    if (!_resultArrow)
    {
        UIImage* arrowImage;
        if (self.isVertical)
        {
            arrowImage =[UIImage imageNamed:@"ResultArrowVertical"];
            UIEdgeInsets edgeInsets;
            edgeInsets.left = 0.0f;
            edgeInsets.top = 10.0f;
            edgeInsets.right = 0.0f;
            edgeInsets.bottom = 10.0f;
            arrowImage = [arrowImage resizableImageWithCapInsets:edgeInsets];
        }
        else
        {
            arrowImage =[UIImage imageNamed:@"ResultArrowVertical"];
            UIEdgeInsets edgeInsets;
            edgeInsets.left = 10.0f;
            edgeInsets.top = 0.0f;
            edgeInsets.right = 10.0f;
            edgeInsets.bottom = 0.0f;
            arrowImage = [arrowImage resizableImageWithCapInsets:edgeInsets];
        }
        
        _resultArrow = [[UIImageView alloc] initWithImage:[arrowImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [self addSubview:_resultArrow];
        
        _resultArrow.contentMode = UIViewContentModeScaleToFill;
        
        [self setProgress:0 animated:NO];
    }
    
    return _resultArrow;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    self.resultArrow.tintColor = color;
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
    //Sanity check that it is within 0 and 1
    progress = MIN(progress, 1);
    progress = MAX(progress, 0);
    _progress = progress;
    
    CGFloat maxProgress = self.isVertical ? self.frame.size.height * .8 : self.frame.size.width * .8;
    CGFloat minProgress = self.isVertical ? self.frame.size.height * .2 : self.frame.size.width * .2;
    CGFloat currentProgress = maxProgress * progress;
    
    if (self.isVertical)
    {
        self.resultArrow.frame = CGRectMake(0, self.frame.size.height - minProgress - currentProgress,
                                             self.frame.size.width, minProgress + currentProgress);
    }
    else
    {
        self.resultArrow.frame = CGRectMake(0, self.frame.size.height,
                                             minProgress + currentProgress, self.frame.size.height);
    }
}

@end
