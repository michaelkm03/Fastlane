//
//  VCropWorkspaceToolViewController.m
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCropToolViewController.h"

@interface VCropToolViewController () <UIScrollViewDelegate>

@property (nonatomic, weak, readwrite) IBOutlet UIScrollView *croppingScrollView;

@property (nonatomic, strong) UIView *proxyView;

@property (nonatomic, assign) BOOL hasLayedOutScrollView;

@property (nonatomic, assign) CGFloat lastRotation;

@end

@implementation VCropToolViewController

+ (instancetype)cropViewController
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace"
                                                                  bundle:nil];
    VCropToolViewController *cropTool = [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];

    return cropTool;
}

#pragma mark - UIViewController
#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.croppingScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.croppingScrollView.minimumZoomScale = 1.0f;
    self.croppingScrollView.maximumZoomScale = 4.0f;
    self.croppingScrollView.bouncesZoom = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.hasLayedOutScrollView)
    {
        return;
    }
    
    CGRect proxyViewFrame;
    
    if (self.assetSize.height > self.assetSize.width)
    {
        CGFloat scaleFactor = self.assetSize.width / CGRectGetWidth(self.croppingScrollView.bounds);
        proxyViewFrame = CGRectMake(CGRectGetMinX(self.croppingScrollView.bounds),
                                    CGRectGetMinY(self.croppingScrollView.bounds),
                                    CGRectGetWidth(self.croppingScrollView.bounds),
                                    self.assetSize.height * (1/scaleFactor));
    }
    else
    {
        CGFloat scaleFactor = self.assetSize.height / CGRectGetHeight(self.croppingScrollView.bounds);
        proxyViewFrame = CGRectMake(CGRectGetMinX(self.croppingScrollView.bounds),
                                    CGRectGetMinY(self.croppingScrollView.bounds),
                                    self.assetSize.width * (1/scaleFactor),
                                    CGRectGetHeight(self.croppingScrollView.bounds));
    }
    
    self.proxyView = [[UIView alloc] initWithFrame:proxyViewFrame];
    [self.croppingScrollView addSubview:self.proxyView];
    self.croppingScrollView.contentSize = proxyViewFrame.size;
    self.hasLayedOutScrollView = YES;
}

- (IBAction)doubleTapCrop:(UITapGestureRecognizer *)sender
{
    CGPoint locationInView = [sender locationInView:self.croppingScrollView];
    CGFloat zoomedWidth = CGRectGetWidth(self.croppingScrollView.bounds) * ( 1 / self.croppingScrollView.maximumZoomScale);
    CGRect zoomedRect = CGRectMake(locationInView.x - (zoomedWidth/2), locationInView.y - (zoomedWidth/2), zoomedWidth, zoomedWidth);
    
    CGPoint centerOfContentView = CGPointMake(CGRectGetMidX(self.croppingScrollView.frame), CGRectGetMidY(self.croppingScrollView.frame));
    CGFloat normalWidth = CGRectGetWidth(self.croppingScrollView.bounds);
    CGRect normalRect = CGRectMake(centerOfContentView.x - (normalWidth / 2), centerOfContentView.y - (normalWidth / 2), normalWidth, normalWidth);
    [self.croppingScrollView zoomToRect:self.croppingScrollView.zoomScale > self.croppingScrollView.minimumZoomScale ? normalRect : zoomedRect
                               animated:YES];
}

#pragma mark - Public Interface

- (void)setAssetSize:(CGSize)assetSize
{
    if (CGSizeEqualToSize(_assetSize, assetSize))
    {
        return;
    }
    
    if (self.proxyView != nil)
    {
        [self.proxyView removeFromSuperview];
        self.proxyView = nil;
    }
    
    _assetSize = assetSize;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.proxyView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.onCropBoundsChange)
    {
        self.onCropBoundsChange(scrollView);
    }
}

@end
