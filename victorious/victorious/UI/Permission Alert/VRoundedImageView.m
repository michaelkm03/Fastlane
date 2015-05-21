//
//  VRoundedImageView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "VRoundedImageView.h"

@implementation VRoundedImageView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
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

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.image = [self placeholderImage];
}

- (void)setIconImageURL:(NSURL *)url
{
    [self sd_setImageWithURL:url placeholderImage:[self placeholderImage]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // Update corner radius after we've been laid out
    self.layer.cornerRadius = CGRectGetHeight(self.bounds) / 2;
}

- (UIImage *)placeholderImage
{
    UIImage *image = [UIImage imageNamed:@"profile_thumb"];
    if (CGRectGetHeight(self.bounds) > image.size.height)
    {
        image = [UIImage imageNamed:@"profile_full"];
    }
    
    return image;
}

@end
