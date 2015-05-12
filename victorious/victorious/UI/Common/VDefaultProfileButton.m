//
//  VDefaultProfileButton.m
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDefaultProfileButton.h"

#import <SDWebImage/UIButton+WebCache.h>
#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+VTint.h"

@implementation VDefaultProfileButton

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
    [self setImage:[self placeholderImage] forState:UIControlStateNormal];
    
    //Setting vertical and horizontal alignment to fill causes the image set by "setImage"
    //to completely fill the bounds of button
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    
    self.backgroundColor = [UIColor whiteColor];
    self.tintColor = [UIColor darkGrayColor];
    
    self.clipsToBounds = YES;
}

- (void)setTintColor:(UIColor *)tintColor
{
    super.tintColor = [tintColor colorWithAlphaComponent:0.3f];
}

- (void)updateCornerRadius
{
    CGFloat radius = ( CGRectGetHeight(self.bounds) - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom )/2 ;
    self.layer.cornerRadius = radius;
}

- (void)setProfileImageURL:(NSURL *)url forState:(UIControlState)controlState
{
    UIImage *defaultImage = [self placeholderImage];

    [self sd_setImageWithURL:url
                    forState:UIControlStateNormal
            placeholderImage:defaultImage
                     options:SDWebImageRetryFailed
                   completed:nil];
    
    self.imageView.tintColor = self.tintColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateCornerRadius];
}

- (UIImage *)placeholderImage
{
    UIImage *image = [UIImage imageNamed:@"profile_thumb"];
    if (CGRectGetHeight(self.bounds) > image.size.height)
    {
        image = [UIImage imageNamed:@"profile_full"];
    }
    
    // Create unique key from tint color
    NSString *tintKey = [self.tintColor description];
    
    // Check cache for already tinted image
    SDImageCache *cache = [[SDWebImageManager sharedManager] imageCache];
    UIImage *cachedImage = [cache imageFromMemoryCacheForKey:tintKey];
    if (cachedImage != nil)
    {
        return cachedImage;
    }
    
    // Tint image and store in cache
    UIImage *tintedImage = [image v_tintedTemplateImageWithColor:self.tintColor];
    [cache storeImage:tintedImage forKey:tintKey];
    
    return tintedImage;
}

@end
