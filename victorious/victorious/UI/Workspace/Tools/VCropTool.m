//
//  VCropTool.m
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCropTool.h"

#import "VCanvasView.h"

#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspaceTool.h"

#import "VCropToolViewController.h"

static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";
static NSString * const kSelectedIconKey = @"selectedIcon";
static NSString * const kFilterIndexKey = @"filterIndex";

@interface VCropTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImage *selectedIcon;
@property (nonatomic, strong) NSNumber *filterIndexNumber;
@property (nonatomic, strong, readwrite) VCropToolViewController *cropViewController;
@property (nonatomic, weak) VCanvasView *canvasView;
@property (nonatomic, assign) BOOL didCrop;

@end

@implementation VCropTool

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VCanvasViewAssetSizeBecameAvailableNotification
                                                  object:_canvasView];
}

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        _filterIndexNumber = [dependencyManager numberForKey:kFilterIndexKey];
        _cropViewController = [VCropToolViewController cropViewController];
        _icon = [dependencyManager imageForKey:kIconKey];
        _selectedIcon = [dependencyManager imageForKey:kSelectedIconKey];
    }
    return self;
}

- (CGSize)assetSize
{
    return self.canvasView.assetSize;
}

#pragma mark - VWorkspaceTool

- (BOOL)canvasScrollViewShoudldBeInteractive
{
    return YES;
}

- (CIImage *)imageByApplyingToolToInputImage:(CIImage *)inputImage
{
    CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
    
    // Crop to center if we have never been selected

    CIVector *cropVector = nil;
    if (self.canvasView.canvasScrollView == nil)
    {
        [cropFilter setValue:inputImage
                      forKey:kCIInputImageKey];
        cropVector = [self cropVectorWithScrollView:self.canvasView.canvasScrollView inputImageExtent:inputImage.extent zoomScale:1.0f];
    }
    else
    {
        CIFilter *lanczosScaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
        [lanczosScaleFilter setValue:inputImage
                              forKey:kCIInputImageKey];
        CGFloat zoomScale = self.canvasView.canvasScrollView.zoomScale;
        [lanczosScaleFilter setValue:@(zoomScale)
                              forKey:kCIInputScaleKey];
        
        // Crop at new size
        [cropFilter setValue:[lanczosScaleFilter outputImage]
                      forKey:kCIInputImageKey];
        
        cropVector = [self cropVectorWithScrollView:self.canvasView.canvasScrollView
                                   inputImageExtent:inputImage.extent
                                          zoomScale:zoomScale];
    }
    [cropFilter setValue:cropVector
                  forKey:@"inputRectangle"];
    
    VLog(@"cropFilter: %@", cropFilter);
    return [cropFilter outputImage];
}

- (CIVector *)cropVectorWithScrollView:(UIScrollView *)scrollView
                      inputImageExtent:(CGRect)extent
                             zoomScale:(CGFloat)zoomScale
{
    CGFloat zoomedWidth = extent.size.width * zoomScale;
    CGFloat zoomedHeight = extent.size.height * zoomScale;
    CGPoint contentOffset = scrollView.contentOffset;
    CGSize contentSize = scrollView.contentSize;
    CGRect croppingBounds = scrollView.bounds;
    if ((contentSize.width == 0) || (contentSize.height == 0))
    {
        return [CIVector vectorWithCGRect:extent];
    }
    CGRect cropRect = CGRectMake(((contentOffset.x / contentSize.width)* zoomedWidth),
                                 zoomedHeight - ((contentOffset.y / contentSize.height)* zoomedHeight) ,
                                 (croppingBounds.size.width / contentSize.width)* zoomedWidth,
                                 -((croppingBounds.size.height / contentSize.height)* zoomedHeight));
    cropRect = CGRectInset(cropRect, 1, 1); // Kind of a hack to prevent white borders 
    return [CIVector vectorWithCGRect:cropRect];
}

- (NSInteger)renderIndex
{
    return [self.filterIndexNumber integerValue];
}

- (UIViewController *)canvasToolViewController
{
    return _cropViewController;
}

@end
