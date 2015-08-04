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
#import "UIImage+Round.h"

@interface VDefaultProfileButton ()

@property (nonatomic, strong) NSURL *imageURL;

@end

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
    //Setting vertical and horizontal alignment to fill causes the image set by "setImage"
    //to completely fill the bounds of button
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor darkGrayColor];
}

- (void)setTintColor:(UIColor *)tintColor
{
    super.tintColor = [tintColor colorWithAlphaComponent:0.3f];
    // Re-render placeholder image if necessary
    if (_imageURL == nil || [_imageURL absoluteString].length == 0)
    {
        [self setBackgroundImage:[self placeholderImage] forState:UIControlStateNormal];
    }
}

- (void)setProfileImageURL:(NSURL *)url forState:(UIControlState)controlState
{
    _imageURL = url;
    
    __weak typeof(self) weakSelf = self;
    [[SDWebImageManager sharedManager] downloadImageWithURL:url
                                                    options:SDWebImageRetryFailed
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
     {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         
         if (!image)
         {
             [strongSelf setBackgroundImage:[strongSelf placeholderImage] forState:controlState];
             return;
         }
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^
                        {
                            UIImage *roundedImage = [image roundedImageWithCornerRadius:image.size.height / 2];
                            dispatch_async(dispatch_get_main_queue(), ^
                                           {
                                               [strongSelf setBackgroundImage:roundedImage forState:controlState];
                                           });
                        });
     }];
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

- (void)drawRect:(CGRect)rect
{
    // Draws a white background
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, rect);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillPath(context);
}

@end
