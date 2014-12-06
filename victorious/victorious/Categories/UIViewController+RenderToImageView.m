//
//  UIViewController+UIImageView.m
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIViewController+RenderToImageView.h"

@implementation UIViewController (UIImageView)

- (UIImageView *)rederedAsImageView
{
    UIGraphicsBeginImageContextWithOptions( self.view.frame.size, YES, 0 );
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:renderedImage];
    imageView.frame = self.view.frame;
    return imageView;
}

@end
