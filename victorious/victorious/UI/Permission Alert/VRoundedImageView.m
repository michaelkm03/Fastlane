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
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setIconImageURL:(NSURL *)url
{
    [self sd_setImageWithURL:url placeholderImage:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // Update corner radius after we've been laid out
    self.layer.cornerRadius = CGRectGetHeight(self.bounds) / 2;
}

@end
