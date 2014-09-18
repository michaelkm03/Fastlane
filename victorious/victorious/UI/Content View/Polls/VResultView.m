//
//  VResultView.m
//  victorious
//
//  Created by Will Long on 3/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VResultView.h"

#import "VThemeManager.h"

@interface VResultView ()

@property (nonatomic) CGFloat progress;
@property (strong, nonatomic) UIImageView *resultArrow;
@property (strong, nonatomic) UILabel *resultLabel;

@end

@implementation VResultView

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame orientation:YES progress:0];
}

- (instancetype)initWithFrame:(CGRect)frame orientation:(BOOL)isVertical
{
    return [self initWithFrame:frame orientation:isVertical progress:0];
}

- (instancetype)initWithFrame:(CGRect)frame orientation:(BOOL)isVertical progress:(CGFloat)progress
{
    self = [super initWithFrame:frame];
    if (self)
    {
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
    
    [self.resultLabel removeFromSuperview];
    self.resultLabel = nil;
}

- (UIView *)resultArrow
{
    if (!_resultArrow)
    {
        UIImage *arrowImage;
        if (self.isVertical)
        {
            arrowImage = [UIImage imageNamed:@"ResultArrowVertical"];
            UIEdgeInsets edgeInsets;
            edgeInsets.left = 01.0f;
            edgeInsets.top = 10.0f;
            edgeInsets.right = 01.0f;
            edgeInsets.bottom = 10.0f;
            arrowImage = [arrowImage resizableImageWithCapInsets:edgeInsets];
        }
        else
        {
            arrowImage = [UIImage imageNamed:@"ResultArrowVertical"];
            UIEdgeInsets edgeInsets;
            edgeInsets.left = 10.0f;
            edgeInsets.top = 01.0f;
            edgeInsets.right = 10.0f;
            edgeInsets.bottom = 01.0f;
            arrowImage = [arrowImage resizableImageWithCapInsets:edgeInsets];
        }
        
        _resultArrow = [[UIImageView alloc] initWithImage:[arrowImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [self addSubview:_resultArrow];
        
        
        [self setProgress:0 animated:NO];
    }
    
    return _resultArrow;
}

- (UILabel *)resultLabel
{
    if (!_resultLabel)
    {
        _resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                                 self.frame.size.width,
                                                                 self.frame.size.height *.1f)];
        
        _resultLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
        _resultLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        _resultLabel.textAlignment = NSTextAlignmentCenter;
        _resultLabel.minimumScaleFactor = .5f;
        _resultLabel.adjustsFontSizeToFitWidth = YES;
        _resultLabel.minimumScaleFactor = .75f;
        
        [self insertSubview:_resultLabel aboveSubview:self.resultArrow];
    }
    
    return _resultLabel;
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

- (void)setProgress:(CGFloat)progress
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
        
        CGRect frame = _resultLabel.frame;
        frame.origin.y = self.resultArrow.frame.origin.y + self.resultArrow.image.capInsets.top;
        _resultLabel.frame = frame;
        
    }
    else
    {
        self.resultArrow.frame = CGRectMake(0, self.frame.size.height,
                                             minProgress + currentProgress, self.frame.size.height);
    }
    
    static NSNumberFormatter *percentFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        percentFormatter = [[NSNumberFormatter alloc] init];
        [percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    });
    
    self.resultLabel.text = [percentFormatter stringFromNumber:@(progress)];
}

@end
