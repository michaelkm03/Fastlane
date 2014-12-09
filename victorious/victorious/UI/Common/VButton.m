//
//  VButton.m
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VButton.h"
#import "UIColor+Brightness.h"

static const CGFloat kCornderRadius         = 3.0f;
static const CGFloat kBorderWidth           = 1.5f;
static const CGFloat kSecondaryGray         = 0.2f;

@interface VButton ()

@property (nonatomic, strong) UIColor *primaryColor;
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
    switch ( self.style )
    {
        case VButtonStylePrimary:
            [self privateSetBackgroundColor:highlighted ? [self.primaryColor darkenBy:0.1f] : self.primaryColor];
            break;
            
        case VButtonStyleSecondary:
            [self privateSetBackgroundColor:highlighted ? [self.secondaryColor colorWithAlphaComponent:0.07f] : [UIColor clearColor]];
            break;
    }
}

@end
