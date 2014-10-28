//
//  VFollowUserControl.m
//  victorious
//
//  Created by Michael Sena on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowUserControl.h"

@interface VFollowUserControl ()

@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation VFollowUserControl

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)prepareForInterfaceBuilder
{
    [self sharedInit];
}

- (void)sharedInit
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:nil]];
    imageView.frame = self.bounds;
    imageView.image = self.followImage;
    
    [self addSubview:imageView];
    _imageView = imageView;
}

- (void)setFollowImage:(UIImage *)followImage
{
    _followImage = followImage;

#if TARGET_INTERFACE_BUILDER
    [self setNeedsDisplay];
#endif
}

- (void)setUnFollowImage:(UIImage *)unFollowImage
{
    _unFollowImage = unFollowImage;
    
#if TARGET_INTERFACE_BUILDER
    [self setNeedsDisplay];
#endif
}

@end
