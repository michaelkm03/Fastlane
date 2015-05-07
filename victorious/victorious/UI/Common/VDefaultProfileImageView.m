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
#import "UIImage+Round.h"

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
    
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor darkGrayColor];
    self.borderWidth = 0;
    self.borderColor = [UIColor whiteColor];
}

- (void)setProfileImageURL:(NSURL *)url
{
    __weak typeof(self) weakSelf = self;
    [[SDWebImageManager sharedManager] downloadImageWithURL:url
                                                    options:SDWebImageRetryFailed
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      if (!image)
                                                      {
                                                          [weakSelf setImage:[weakSelf placeholderImage]];
                                                          return;
                                                      }
                                                      
                                                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                                                          UIImage *roundedImage = [image roundedImageWithCornerRadius:image.size.height / 2
                                                                                                          borderWidth:weakSelf.borderWidth
                                                                                                          borderColor:weakSelf.borderColor];
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [weakSelf setImage:roundedImage];
                                                          });
                                                      });
                                                  }];
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

- (void)drawRect:(CGRect)rect
{
    // Draws a white background
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, rect);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillPath(context);
}

@end
