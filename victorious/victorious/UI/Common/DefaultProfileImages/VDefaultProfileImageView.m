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
#import "UIImage+VTint.h"

@interface VDefaultProfileImageView ()

@property (nonatomic, strong) NSURL *imageURL;

@end

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
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
    self.clipsToBounds = YES;
        
    self.backgroundColor = [UIColor whiteColor];
    self.tintColor = [UIColor whiteColor];
}

- (void)setTintColor:(UIColor *)tintColor
{
    super.tintColor = [tintColor colorWithAlphaComponent:0.3f];
    // Re-render placeholder image if necessary
    if (_imageURL == nil || [_imageURL absoluteString].length == 0)
    {
        self.image = [self placeholderImage];
    }
}

- (void)setProfileImageURL:(NSURL *)url
{
    _imageURL = url;
    [self sd_setImageWithURL:url placeholderImage:self.image ?: [self placeholderImage]];
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
    UIImage *tintedImage = [image v_tintedTemplateImageWithColor:[self tintColor]];
    [cache storeImage:tintedImage forKey:tintKey];
    
    return tintedImage;
}

@end
