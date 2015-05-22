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

static const CGFloat kTooltipArrowHeight = 14.0f;
static const CGFloat kTooltipArrowWidth = 26.0f;

static const CGFloat kHorizontalLabelInset = 20.0f;
static const CGFloat kVerticalLabelInset = 15.0f;

static const CGFloat kShadowOpacity = 0.35f;
static const CGFloat kShadowRadius = 1.0f;
static const CGSize kShadowOffset = { 0.0f, 1.0f };

@interface VCoachmarkView ()

@property (nonatomic, strong) UIView *backgroundView;
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
        _captionLabel.numberOfLines = 0;
        _backgroundView = [_coachmark.background viewForBackground];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self addSubview:self.backgroundView];
    [self v_addFitToParentConstraintsToSubview:self.backgroundView];
    
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
    
    //Add a shadow to the coachmark
    self.layer.shadowRadius = kShadowRadius;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = kShadowOpacity;
    self.layer.shadowOffset = kShadowOffset;
}

+ (instancetype)toastCoachmarkViewWithCoachmark:(VCoachmark *)coachmark
                                       andWidth:(CGFloat)width
{
    NSParameterAssert(coachmark != nil);
    
    VCoachmarkView *coachmarkView = [[VCoachmarkView alloc] initWithCoachmark:coachmark];
    NSString *text = coachmark.currentScreenText;
    coachmarkView.captionLabel.text = text;
    CGRect frame = [coachmarkView frameForText:text withWidth:width];
    coachmarkView.frame = frame;
    coachmarkView.arrowDirection = VCoachmarkArrowDirectionInvalid;
    return coachmarkView;
}

+ (instancetype)tooltipCoachmarkViewWithCoachmark:(VCoachmark *)coachmark
                                            width:(CGFloat)width
                            arrowHorizontalOffset:(CGFloat)horizontalOffset
                                andArrowDirection:(VCoachmarkArrowDirection)arrowDirection
{
    NSParameterAssert(coachmark != nil);
    NSParameterAssert(arrowDirection != VCoachmarkArrowDirectionInvalid);
   
    VCoachmarkView *coachmarkView = [[VCoachmarkView alloc] initWithCoachmark:coachmark];
    NSString *text = coachmark.relatedScreenText;
    coachmarkView.captionLabel.text = text;
    CGRect frame = [coachmarkView frameForText:text withWidth:width];
    CGFloat boxHeight = CGRectGetHeight(frame);
    frame.size.height += kTooltipArrowHeight;
    coachmarkView.frame = frame;
    coachmarkView.arrowDirection = arrowDirection;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    CGFloat fullHeight = CGRectGetHeight(frame);
    UIBezierPath *tooltipPath = [self tooltipPathWithArrowDirection:arrowDirection
                                                          boxHeight:boxHeight
                                                        totalHeight:fullHeight
                                              arrowHorizontalOffset:horizontalOffset
                                                           andWidth:width];
    maskLayer.fillColor = [[UIColor whiteColor] CGColor];
    maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
    maskLayer.path = [tooltipPath CGPath];
    coachmarkView.backgroundView.layer.mask = maskLayer;
    
    return coachmarkView;
}

+ (UIBezierPath *)tooltipPathWithArrowDirection:(VCoachmarkArrowDirection)arrowDirection
                                      boxHeight:(CGFloat)boxHeight
                                    totalHeight:(CGFloat)totalHeight
                          arrowHorizontalOffset:(CGFloat)horizontalOffset
                                       andWidth:(CGFloat)width
{
    UIBezierPath *tooltipPath = [UIBezierPath bezierPath];
    if ( arrowDirection == VCoachmarkArrowDirectionDown )
    {
        //Start at top left corner of box and draw to bottom left corner
        [tooltipPath moveToPoint:CGPointZero];
        [tooltipPath addLineToPoint:CGPointMake(0, boxHeight)];
        
        //Draw from bottom left corner to half the arrow's width of the arrow point
        [tooltipPath addLineToPoint:CGPointMake(horizontalOffset - kTooltipArrowWidth / 2, boxHeight)];
        
        //Draw to top of arrow
        [tooltipPath addLineToPoint:CGPointMake(horizontalOffset, totalHeight)];
        
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
        [tooltipPath addLineToPoint:CGPointMake(0, totalHeight)];
        [tooltipPath addLineToPoint:CGPointMake(width, totalHeight)];
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
    return tooltipPath;
}

- (CGRect)frameForText:(NSString *)text withWidth:(CGFloat)width
{
    CGRect minimumFrame = [text boundingRectWithSize:CGSizeMake(width - kHorizontalLabelInset * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : self.coachmark.font } context:nil];
    minimumFrame = CGRectInset(minimumFrame, 0, -kVerticalLabelInset);
    minimumFrame.size.width = width;
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

@end
