//
//  VButton.m
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VButton.h"
#import "UIColor+VBrightness.h"
#import "UIView+AutoLayout.h"

static const CGFloat kCornderRadius                 = 3.0f;
static const CGFloat kBorderWidth                   = 1.5f;
static const CGFloat kPrimaryHighlightModAmount     = 0.2f;
static const CGFloat kDefaultSecondaryGray          = 0.2f;
static const CGFloat kStartScale                    = 1.0f;
static const CGFloat kEndScale                      = 0.98f;
static const CGFloat kActivityIndicatorShowDuration = 0.4f;

static const CGFloat kDisabledAlpha                 = 0.75f;
static const CGFloat kMinimumTitleLabelScaleFactor  = 0.5f;

static const UIEdgeInsets kLabelEdgeInsets = { 0, 10, 0, 10 };

@interface VButton ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *widthConstraint;

@end

@implementation VButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (void)createActivityIndicator
{
    if ( self.activityIndicator == nil )
    {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        if ( self.activityIndicatorTintColor != nil )
        {
            self.activityIndicator.color = self.activityIndicatorTintColor;
        }
        [self addSubview:_activityIndicator];
        [self v_addCenterToParentContraintsToSubview:_activityIndicator];
        [self.activityIndicator startAnimating];
        self.activityIndicator.alpha = 0.0f;
    }
    [self updateAppearance];
}

- (void)showActivityIndicator
{
    [self createActivityIndicator];
    
    [self setTitleColor:[self.titleLabel.textColor colorWithAlphaComponent:0.0f] forState:UIControlStateNormal];
    [[self imageView] setAlpha:0.0f];
    [UIView animateWithDuration:kActivityIndicatorShowDuration animations:^
     {
         self.activityIndicator.alpha = 1.0f;
     }
                     completion:nil];
}

- (void)setActivityIndicatorTintColor:(UIColor *)activityIndicatorTintColor
{
    _activityIndicatorTintColor = activityIndicatorTintColor;
    self.activityIndicator.color = activityIndicatorTintColor;
}

- (void)hideActivityIndicator
{
    if ( !self.activityIndicator.isAnimating )
    {
        //Not currently animating, no reason to perform the animations below
        return;
    }
    
    [self createActivityIndicator];
    
    self.activityIndicator.alpha = 0.0f;
    [UIView animateWithDuration:kActivityIndicatorShowDuration animations:^
     {
         [self setTitleColor:[self.titleLabel.textColor colorWithAlphaComponent:1.0f] forState:UIControlStateNormal];
         [[self imageView] setAlpha:1.0f];
     }
                     completion:nil];
}

- (void)commonInit
{
    self.primaryColor = [UIColor grayColor];
    self.secondaryColor = [[self class] defaultSecondaryColor];
    self.layer.cornerRadius = kCornderRadius;
    [self updateAppearance];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self updateAppearance];
}

+ (UIColor *)defaultSecondaryColor
{
    return [UIColor colorWithWhite:kDefaultSecondaryGray alpha:1.0];
}

- (void)setStyle:(VButtonStyle)style
{
    _style = style;
    [self updateAppearance];
}

- (void)updateAppearance
{
    switch ( self.style )
    {
        case VButtonStylePrimary:
            self.layer.borderWidth = 0.0f;
            self.layer.borderColor = [UIColor clearColor].CGColor;
            self.backgroundColor = self.primaryColor;
            self.activityIndicator.color = self.titleLabel.textColor;
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
            
        case VButtonStyleSecondary:
            self.layer.borderWidth = kBorderWidth;
            [self setTitleColor:self.secondaryColor forState:UIControlStateNormal];
            self.layer.borderColor = self.secondaryColor.CGColor;
            self.activityIndicator.color = self.titleLabel.textColor;
            self.backgroundColor = [UIColor clearColor];
            break;
            
        default:
            break;
    }
    
    self.alpha = self.enabled ? 1.0f : kDisabledAlpha;
    
    self.titleLabel.minimumScaleFactor = kMinimumTitleLabelScaleFactor;
    
    self.transform = CGAffineTransformMakeScale( kStartScale, kStartScale );
    
    [self setNeedsDisplay];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    [self updateAppearance];
}

- (void)setPrimaryColor:(UIColor *)primaryColor
{
    _primaryColor = primaryColor;
    [self updateAppearance];
}

- (void)setSecondaryColor:(UIColor *)secondaryColor
{
    _secondaryColor = secondaryColor;
    [self updateAppearance];
}

- (void)privateSetBackgroundColor:(UIColor *)color
{
    [super setBackgroundColor:color];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [UIView animateWithDuration:highlighted ? 0.1f : 0.3f
                          delay:0.0f
         usingSpringWithDamping:0.8f
          initialSpringVelocity:0.8f
                        options:kNilOptions animations:^
     {
         [self applyAnimatedHighlight:highlighted];
     }
                     completion:nil];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:UIControlStateNormal];
    
    if ( self.activityIndicator != nil )
    {
        [self hideActivityIndicator];
    }
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [self.titleLabel.text sizeWithAttributes:@{ NSFontAttributeName : self.titleLabel.font ?: @"" }];
    size.width += kLabelEdgeInsets.left + kLabelEdgeInsets.right;
    size.height += kLabelEdgeInsets.top + kLabelEdgeInsets.bottom;
    return size;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    [self updateAppearance];
}

- (CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}

- (void)applyAnimatedHighlight:(BOOL)highlighted
{
    switch ( self.style )
    {
        case VButtonStylePrimary:
        {
            UIColor *modded = [self.primaryColor v_colorDarkenedBy:kPrimaryHighlightModAmount];
            UIColor *color = highlighted ? modded : self.primaryColor;
            [self privateSetBackgroundColor:color];
            break;
        }
        case VButtonStyleSecondary:
        {
            UIColor *color = highlighted ? self.primaryColor : self.secondaryColor;
            self.layer.borderColor = color.CGColor;
            [self setTitleColor:color forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    
    if ( highlighted )
    {
        self.transform = CGAffineTransformMakeScale( kEndScale, kEndScale );
    }
    else
    {
        self.transform = CGAffineTransformMakeScale( kStartScale, kStartScale );
    }
}

@end
