//
//  VCoachmarkView.m
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCoachmarkView.h"
#import "VCoachmark.h"
#import "UIView+AutoLayout.h"
#import "VBackground.h"

static const CGFloat kTooltipArrowHeight = 14;
static const CGFloat kTooltipArrowWidth = 26;

static const CGFloat kHorizontalLabelInset = 20;
static const CGFloat kVerticalLabelInset = 15;

@interface VCoachmarkView ()

@property (nonatomic, strong) UIView *backgroundContainerView;
@property (nonatomic, strong) VCoachmark *coachmark;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, readwrite) VCoachmarkArrowDirection arrowDirection;

@end

@implementation VCoachmarkView

- (instancetype)initWithCoachmark:(VCoachmark *)coachmark
{
    self = [super init];
    if ( self != nil )
    {
        _coachmark = coachmark;
        _captionLabel = [[UILabel alloc] init];
        _captionLabel.textAlignment = NSTextAlignmentCenter;
        _captionLabel.font = coachmark.font;
        _captionLabel.textColor = coachmark.textColor;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIView *background = [self.coachmark.background viewForBackground];
    [self addSubview:background];
    [self v_addFitToParentConstraintsToSubview:background];
    
    [self addSubview:self.captionLabel];
    UIEdgeInsets insets = UIEdgeInsetsMake(kVerticalLabelInset, kHorizontalLabelInset, kVerticalLabelInset, kHorizontalLabelInset);
    if ( self.arrowDirection == VCoachmarkArrowDirectionUp )
    {
        insets.top += kTooltipArrowHeight;
    }
    else if ( self.arrowDirection == VCoachmarkArrowDirectionDown )
    {
        insets.bottom += kTooltipArrowHeight;
    }
    [self v_addFitToParentConstraintsToSubview:self.captionLabel leading:insets.left trailing:insets.right top:insets.top bottom:insets.bottom];
}

+ (instancetype)toastCoachmarkViewWithCoachmark:(VCoachmark *)coachmark
                                    andMaxWidth:(CGFloat)maxWidth
{
    VCoachmarkView *coachmarkView = [[VCoachmarkView alloc] initWithCoachmark:coachmark];
    NSString *text = coachmark.currentScreenText;
    coachmarkView.captionLabel.text = text;
    CGRect frame = [coachmarkView frameForText:text withMaxWidth:maxWidth];
    coachmarkView.frame = frame;
    coachmarkView.arrowDirection = VCoachmarkArrowDirectionInvalid;
    return coachmarkView;
}

+ (instancetype)tooltipCoachmarkViewWithCoachmark:(VCoachmark *)coachmark
                                         maxWidth:(CGFloat)maxWidth
                            arrowHorizontalOffset:(CGFloat)horizontalOffset
                                andArrowDirection:(VCoachmarkArrowDirection)arrowDirection
{
    VCoachmarkView *coachmarkView = [[VCoachmarkView alloc] initWithCoachmark:coachmark];
    NSString *text = coachmark.relatedScreenText;
    coachmarkView.captionLabel.text = text;
    CGRect frame = [coachmarkView frameForText:text withMaxWidth:maxWidth];
    CGFloat boxHeight = CGRectGetHeight(frame);
    frame.size.height += kTooltipArrowHeight;
    coachmarkView.frame = frame;
    coachmarkView.arrowDirection = arrowDirection;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *tooltipPath = [UIBezierPath bezierPath];
    CGFloat width = CGRectGetWidth(frame);
    CGFloat fullHeight = CGRectGetHeight(frame);
    
    //Draw the tooltipPath
    if ( arrowDirection == VCoachmarkArrowDirectionDown )
    {
        //Start at top left corner of box and draw to bottom left corner
        [tooltipPath moveToPoint:CGPointZero];
        [tooltipPath addLineToPoint:CGPointMake(0, boxHeight)];
        
        //Draw from bottom left corner to half the arrow's width of the arrow point
        [tooltipPath addLineToPoint:CGPointMake(horizontalOffset - kTooltipArrowWidth / 2, boxHeight)];
        
        //Draw to top of arrow
        [tooltipPath addLineToPoint:CGPointMake(horizontalOffset, fullHeight)];
        
        //Draw back to box
        [tooltipPath addLineToPoint:CGPointMake(horizontalOffset + kTooltipArrowWidth / 2, boxHeight)];
        
        //Finish drawing the box
        [tooltipPath addLineToPoint:CGPointMake(width, boxHeight)];
        [tooltipPath addLineToPoint:CGPointMake(width, 0)];
        [tooltipPath closePath];
    }
    else if ( arrowDirection == VCoachmarkArrowDirectionUp )
    {
        //Start below height of arrow and draw the left, bottom, and right sides of the box
        [tooltipPath moveToPoint:CGPointMake(0, kTooltipArrowHeight)];
        [tooltipPath addLineToPoint:CGPointMake(0, fullHeight)];
        [tooltipPath addLineToPoint:CGPointMake(width, fullHeight)];
        [tooltipPath addLineToPoint:CGPointMake(width, kTooltipArrowHeight)];

        //Draw from top right corner to half the arrow's width of the arrow point
        [tooltipPath addLineToPoint:CGPointMake(horizontalOffset + kTooltipArrowWidth / 2, kTooltipArrowHeight)];
        
        //Draw to top of arrow
        [tooltipPath addLineToPoint:CGPointMake(horizontalOffset, 0)];
        
        //Draw back to box
        [tooltipPath addLineToPoint:CGPointMake(horizontalOffset - kTooltipArrowWidth / 2, kTooltipArrowHeight)];
        
        //Finish drawing the box
        [tooltipPath closePath];
    }
    maskLayer.fillColor = [[UIColor whiteColor] CGColor];
    maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
    maskLayer.path = [tooltipPath CGPath];
    coachmarkView.layer.mask = maskLayer;
    
    return coachmarkView;
}

- (CGRect)frameForText:(NSString *)text withMaxWidth:(CGFloat)maxWidth
{
    CGRect minimumFrame = [text boundingRectWithSize:CGSizeMake(maxWidth - kHorizontalLabelInset * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : self.coachmark.font } context:nil];
    minimumFrame = CGRectInset(minimumFrame, 0, -kVerticalLabelInset);
    minimumFrame.size.width = maxWidth;
    return minimumFrame;
}

- (BOOL)hasBeenShown
{
    return self.coachmark.hasBeenShown;
}

- (void)setHasBeenShown:(BOOL)hasBeenShown
{
    self.coachmark.hasBeenShown = YES;
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self;
}

@end
