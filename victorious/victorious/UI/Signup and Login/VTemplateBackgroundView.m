//
//  VTemplateBackgroundView.m
//  victorious
//
//  Created by Patrick Lynch on 3/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTemplateBackgroundView.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageEffects.h"

@implementation VTemplateBackgroundView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImage *image = [UIImage imageNamed:@"Default"];
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.image = [image applyBlurWithRadius:25
                                  tintColor:tintColor
                      saturationDeltaFactor:1.8
                                  maskImage:nil];
}

@end
