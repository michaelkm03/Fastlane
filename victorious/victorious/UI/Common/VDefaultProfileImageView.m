//
//  VDefaultProfileImageView.m
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDefaultProfileImageView.h"

// Categories
#import <SDWebImage/UIImageView+WebCache.h>

@implementation VDefaultProfileImageView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.image = [self placeholderImage];
    
    self.backgroundColor = [UIColor whiteColor];
    self.tintColor = [UIColor darkGrayColor];
    
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
    self.clipsToBounds = YES;
}

- (void)setProfileImageURL:(NSURL *)url
{
    return;
    
    [self sd_setImageWithURL:url placeholderImage:[self placeholderImage]];
}

- (void)setTintColor:(UIColor *)tintColor
{
    super.tintColor = [tintColor colorWithAlphaComponent:0.3f];
}

- (UIImage *)placeholderImage
{
    UIImage *image = [UIImage imageNamed:@"profile_thumb"];
    if (CGRectGetHeight(self.bounds) > image.size.height)
    {
        image = [UIImage imageNamed:@"profile_full"];
    }
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
