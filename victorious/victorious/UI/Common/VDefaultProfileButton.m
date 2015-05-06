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
#import "VSettingManager.h"

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

- (void)setProfileImageURL:(NSURL *)url forState:(UIControlState)controlState
{
    UIImage *defaultImage = [self placeholderImage];
    
    __weak typeof(self) weakSelf = self;
    [self sd_setImageWithURL:url
                    forState:UIControlStateNormal
            placeholderImage:defaultImage
                     options:SDWebImageRetryFailed
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                       
                       if (!image)
                       {
                           [weakSelf setImage:[weakSelf placeholderImage] forState:UIControlStateNormal];
                           return;
                       }
                       
                       // Redraw image with rounded corners
                       UIGraphicsBeginImageContextWithOptions(weakSelf.bounds.size, NO, [[UIScreen mainScreen] scale]);
                       
                       CGFloat radius = ( CGRectGetHeight(weakSelf.bounds) - weakSelf.imageEdgeInsets.top - weakSelf.imageEdgeInsets.bottom )/2 ;
                       [[UIBezierPath bezierPathWithRoundedRect:weakSelf.bounds cornerRadius:radius] addClip];
                       
                       [image drawInRect:weakSelf.bounds];
                       
                       UIImage *rounded = UIGraphicsGetImageFromCurrentImageContext();
                       [weakSelf setImage:rounded forState:UIControlStateNormal];
                       
                       UIGraphicsEndImageContext();
                   }];
    
    self.imageView.tintColor = self.tintColor;
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
