//
//  VButton.m
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VButton.h"

static const CGFloat kCornderRadius = 3.0f;
static const CGFloat kBorderWidth = 2.0f;
static const CGFloat kSecondaryBorderGray = 0.4f;
static const CGFloat kSecondaryTextGray = 0.14f;

@interface VButton ()

@property (nonatomic, strong) UIColor *previousBackgroundColor;

@end

@implementation VButton

- (void)setStyle:(VButtonStyle)style
{
    _style = style;
    
    switch ( style )
    {
        case VButtonStylePrimary:
            self.layer.borderWidth = 0.0;
            if ( self.previousBackgroundColor != nil )
            {
                self.backgroundColor = self.previousBackgroundColor;
            }
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
            
        case VButtonStyleSecondary:
            self.layer.borderWidth = kBorderWidth;
            [self setTitleColor:[UIColor colorWithWhite:kSecondaryTextGray alpha:1.0] forState:UIControlStateNormal];
            self.layer.borderColor = [UIColor colorWithWhite:kSecondaryBorderGray alpha:1.0].CGColor;
            self.previousBackgroundColor = self.backgroundColor;
            self.backgroundColor = [UIColor clearColor];
            break;
    }
    
    self.layer.cornerRadius = kCornderRadius;
    
    [self setNeedsDisplay];
}

@end
