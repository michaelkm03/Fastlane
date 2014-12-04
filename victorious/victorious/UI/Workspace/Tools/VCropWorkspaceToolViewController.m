//
//  VCropWorkspaceToolViewController.m
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCropWorkspaceToolViewController.h"

@interface VCropWorkspaceToolViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImage *imageToCrop;

@property (weak, nonatomic) IBOutlet UIScrollView *croppingScrollView;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation VCropWorkspaceToolViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace"
                                                                  bundle:nil];
    VCropWorkspaceToolViewController *cropTool = [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];

    return cropTool;
}

#pragma mark - UIViewController
#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.croppingScrollView.minimumZoomScale = 1.0f;
    self.croppingScrollView.maximumZoomScale = 4.0f;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setImage:[UIImage imageNamed:@"spaceman.jpg"]];
}

#pragma mark - Public Interface

- (void)setImage:(UIImage *)imageToCrop
{
    if (_imageToCrop != nil)
    {
        _imageToCrop = nil;
        [_imageView removeFromSuperview];
        _imageView = nil;
        self.croppingScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    }
    
    _imageToCrop = imageToCrop;
    
    CGRect imageViewFrame;
    
    if (imageToCrop.size.height > imageToCrop.size.width)
    {
        CGFloat scaleFactor = imageToCrop.size.width / CGRectGetWidth(self.croppingScrollView.bounds);
        imageViewFrame = CGRectMake(CGRectGetMinX(self.croppingScrollView.bounds),
                                    CGRectGetMinY(self.croppingScrollView.bounds),
                                    CGRectGetWidth(self.croppingScrollView.bounds),
                                    imageToCrop.size.height * (1/scaleFactor));
    }
    else
    {
        CGFloat scaleFactor = imageToCrop.size.height / CGRectGetHeight(self.croppingScrollView.bounds);
        imageViewFrame = CGRectMake(CGRectGetMinX(self.croppingScrollView.bounds),
                                    CGRectGetMinY(self.croppingScrollView.bounds),
                                    imageToCrop.size.width * (1/scaleFactor),
                                    CGRectGetHeight(self.croppingScrollView.bounds));
    }
    
    self.imageView = [[UIImageView alloc] initWithImage:imageToCrop];
    self.imageView.frame = imageViewFrame;
    [self.croppingScrollView addSubview:self.imageView];
    self.croppingScrollView.contentSize = self.imageView.bounds.size;
}

- (UIImage *)croppedImage
{
    return _imageToCrop;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
