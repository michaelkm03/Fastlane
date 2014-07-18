//
//  VImagePreviewViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnalyticsRecorder.h"
#import "VImagePreviewViewController.h"
#import "VCameraPublishViewController.h"
#import "VConstants.h"
#import "VThemeManager.h"

@interface VImagePreviewViewController ()

@property (nonatomic, weak) UIImageView *previewImageView;

@end

@implementation VImagePreviewViewController
{
    UIImage *_photo;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *previewImageView = [[UIImageView alloc] initWithImage:self.photo];
    previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.previewImageSuperview addSubview:previewImageView];
    [self.previewImageSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[previewImageView]|"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(previewImageView)]];
    [self.previewImageSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[previewImageView]|"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(previewImageView)]];
    self.previewImageView = previewImageView;
}

- (UIImage *)photo
{
    if (!_photo)
    {
        _photo = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.mediaURL]]; // self.mediaURL *should* be a local file URL.
    }
    return _photo;
}

- (UIImage *)previewImage
{
    return self.photo;
}

@end

