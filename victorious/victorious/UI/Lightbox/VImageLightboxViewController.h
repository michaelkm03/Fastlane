//
//  VImageLightboxViewController.h
//  victorious
//
//  Created by Josh Hinman on 5/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLightboxViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 VLightboxViewController subclass that light boxes an image view.
 */
@interface VImageLightboxViewController : VLightboxViewController

@property (nonatomic, readonly) UIImage *image;

/**
 Creates a new instance of an image lightbox view controller.
 
 @param image The image to display in a lightbox
 */
- (instancetype)initWithImage:(UIImage *_Nullable)image;

@end

NS_ASSUME_NONNULL_END
