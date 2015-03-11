//
//  VButton.m
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VButton.h"
#import "UIColor+VBrightness.h"

static const CGFloat kCornderRadius                 = 3.0f;
static const CGFloat kBorderWidth                   = 1.5f;
static const CGFloat kPrimaryHighlightModAmount     = 0.2f;
static const CGFloat kDefaultSecondaryGray          = 0.2f;
static const CGFloat kStartScale                    = 1.0f;
static const CGFloat kEndScale                      = 0.98f;
static const CGFloat kActivityIndicatorShowDuration = 0.4f;

@interface VButton ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation VButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
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
        self.activityIndicator.center = CGPointMake(CGRectGetWidth(self.frame) / 2.0, CGRectGetHeight(self.frame) / 2.0);
        [self addSubview:_activityIndicator];
        [self.activityIndicator startAnimating];
        self.activityIndicator.alpha = 0.0f;
    }
    [self updateAppearance];
}

- (void)showActivityIndicator
{
    [self createActivityIndicator];
    
    [self setTitleColor:[self.titleLabel.textColor colorWithAlphaComponent:0.0f] forState:UIControlStateNormal];
    [UIView animateWithDuration:kActivityIndicatorShowDuration animations:^
     {
         self.activityIndicator.alpha = 1.0f;
     }
                     completion:nil];
}

- (void)hideActivityIndicator
{
    [self createActivityIndicator];
    
    self.activityIndicator.alpha = 0.0f;
    [UIView animateWithDuration:kActivityIndicatorShowDuration animations:^
     {
         [self setTitleColor:[self.titleLabel.textColor colorWithAlphaComponent:1.0f] forState:UIControlStateNormal];
     }
                     completion:nil];
}

- (void)commonInit
{
    self.primaryColor = [UIColor grayColor];
    self.secondaryColor = [[self class] defaultSecondaryColor];
    _cornerRadius = kCornderRadius;
    [self updateAppearance];
}

- (void)awakeFromNib
{
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
    }
    
    self.layer.cornerRadius = self.cornerRadius;
    
    self.transform = CGAffineTransformMakeScale( kStartScale, kStartScale );
    
    [self setNeedsDisplay];
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

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    [self updateAppearance];
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
