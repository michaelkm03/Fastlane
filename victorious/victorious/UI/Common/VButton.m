//
//  VButton.m
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VButton.h"
#import "UIColor+Brightness.h"

static const CGFloat kCornderRadius             = 3.0f;
static const CGFloat kBorderWidth               = 1.5f;
static const CGFloat kPrimaryHighlightModAmount = 0.1f;
static const CGFloat kSecondaryHighlightAlpha   = 0.1f;
static const CGFloat kSecondaryGray             = 0.2f;
static const CGFloat kStartScale                = 0.97f;

@interface VButton ()

@property (nonatomic, readonly) UIColor *secondaryColor;

@end

@implementation VButton

- (void)setStyle:(VButtonStyle)style
{
    _style = style;
    
    switch ( style )
    {
        case VButtonStylePrimary:
            self.layer.borderWidth = 0.0;
            self.layer.borderColor = [UIColor clearColor].CGColor;
            self.backgroundColor = self.primaryColor;
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
            
        case VButtonStyleSecondary:
            self.layer.borderWidth = kBorderWidth;
            [self setTitleColor:self.secondaryColor forState:UIControlStateNormal];
            self.layer.borderColor = self.secondaryColor.CGColor;
            self.backgroundColor = [UIColor clearColor];
            break;
    }
    
    self.layer.cornerRadius = kCornderRadius;
    
    self.transform = CGAffineTransformMakeScale( kStartScale, kStartScale );
    
    [self setNeedsDisplay];
}

- (UIColor *)secondaryColor
{
    return [UIColor colorWithWhite:kSecondaryGray alpha:1.0];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    if ( self.style == VButtonStylePrimary )
    {
        self.primaryColor = backgroundColor;
    }
}

- (void)privateSetBackgroundColor:(UIColor *)color
{
    [super setBackgroundColor:color];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [UIView animateWithDuration:highlighted ? 0.3f : 0.5f
                          delay:0.0f
         usingSpringWithDamping:0.8f
          initialSpringVelocity:0.8f
                        options:kNilOptions animations:^
     {
         [self applyAnimatedHighlight:highlighted];
     } completion:nil];
    
}

- (void)applyAnimatedHighlight:(BOOL)highlighted
{
    switch ( self.style )
    {
        case VButtonStylePrimary:
        {
            UIColor *modded = [self.primaryColor lightenBy:kPrimaryHighlightModAmount];
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
        self.transform = CGAffineTransformIdentity;
    }
    else
    {
        self.transform = CGAffineTransformMakeScale( kStartScale, kStartScale );
    }
}

@end
