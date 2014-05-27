//
//  VImageLightboxViewController.m
//  victorious
//
//  Created by Josh Hinman on 5/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSLayoutConstraint+CenterConstraints.h"
#import "VImageLightboxViewController.h"

@interface VImageLightboxViewController ()

@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation VImageLightboxViewController

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.image = image;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    [self.contentSuperview addSubview:imageView];
    [self.contentSuperview addConstraints:[NSLayoutConstraint v_constraintsToScaleAndCenterView:imageView
                                                                                     withinView:self.contentSuperview
                                                                                withAspectRatio:(self.image.size.width /
                                                                                                 self.image.size.height)]];
    self.imageView = imageView;
}

#pragma mark - Properties

- (void)setImage:(UIImage *)image
{
    _image = image;
}

- (UIView *)contentView
{
    return self.imageView;
}

@end
