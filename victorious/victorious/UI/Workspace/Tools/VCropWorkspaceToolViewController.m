//
//  VCropWorkspaceToolViewController.m
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCropWorkspaceToolViewController.h"

@interface VCropWorkspaceToolViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *croppingScrollView;

@property (nonatomic, strong) UIView *proxyView;

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
    
    self.croppingScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
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
}

#pragma mark - Public Interface

- (void)setAssetSize:(CGSize)assetSize
{
    if (CGSizeEqualToSize(_assetSize, assetSize))
    {
        return;
    }
    
    if (_proxyView != nil)
    {
        [_proxyView removeFromSuperview];
        _proxyView = nil;
    }
    
    _assetSize = assetSize;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"Visible bounds of image: %@", NSStringFromCGRect(scrollView.bounds));
    if (self.onCropBoundsChange)
    {
        self.onCropBoundsChange(scrollView.bounds);
    }
}

@end
