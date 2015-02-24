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
static NSString * const kFilterIndexKey = @"filterIndex";

@interface VCropTool ()

@property (nonatomic, assign) CGSize assetSize;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
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
        _icon = [UIImage imageNamed:@"cropIcon"];
    }
    return self;
}

#pragma mark - Property Accessors

- (void)setAssetSize:(CGSize)assetSize
{
    _cropViewController.assetSize = assetSize;
    
    __weak typeof(self) welf = self;
    _cropViewController.onCropBoundsChange = ^void(UIScrollView *croppingScrollView)
    {
        welf.didCrop = YES;
        [welf.canvasView.canvasScrollView setZoomScale:croppingScrollView.zoomScale];
        [welf.canvasView.canvasScrollView setContentOffset:croppingScrollView.contentOffset];
    };
}

- (CGSize)assetSize
{
    return self.canvasView.assetSize;
}

#pragma mark - VWorkspaceTool

- (CIImage *)imageByApplyingToolToInputImage:(CIImage *)inputImage
{
    CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
    
    // Crop to center if we have never been selected
    CIVector *cropVector = nil;
    if (self.cropViewController.croppingScrollView == nil)
    {
        [cropFilter setValue:inputImage
                      forKey:kCIInputImageKey];
        cropVector = [self cropVectroWithScrollView:self.canvasView.canvasScrollView inputImageExtent:inputImage.extent zoomScale:1.0f];
    }
    else
    {
        CIFilter *lanczosScaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
        [lanczosScaleFilter setValue:inputImage
                              forKey:kCIInputImageKey];
        CGFloat zoomScale = self.cropViewController.croppingScrollView.zoomScale;
        [lanczosScaleFilter setValue:@(zoomScale)
                              forKey:kCIInputScaleKey];
        
        // Crop at new size
        [cropFilter setValue:[lanczosScaleFilter outputImage]
                      forKey:kCIInputImageKey];
        
        cropVector = [self cropVectroWithScrollView:self.cropViewController.croppingScrollView inputImageExtent:inputImage.extent zoomScale:zoomScale];
    }
    
    [cropFilter setValue:cropVector
                  forKey:@"inputRectangle"];
    return [cropFilter outputImage];
}

- (CIVector *)cropVectroWithScrollView:(UIScrollView *)scrollView
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
    return [CIVector vectorWithCGRect:CGRectMake(((contentOffset.x / contentSize.width)* zoomedWidth),
                                                 zoomedHeight - ((contentOffset.y / contentSize.height)* zoomedHeight) ,
                                                 (croppingBounds.size.width / contentSize.width)* zoomedWidth,
                                                 -((croppingBounds.size.height / contentSize.height)* zoomedHeight))];
}

- (NSInteger)renderIndex
{
    return [self.filterIndexNumber integerValue];
}

- (void)setCanvasView:(VCanvasView *)canvasView
{
    _canvasView = canvasView;
    
    if (CGSizeEqualToSize(canvasView.assetSize, CGSizeZero))
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(assetSizeBecameAvailable:)
                                                     name:VCanvasViewAssetSizeBecameAvailableNotification
                                                   object:canvasView];
    }
    else
    {
        self.assetSize = canvasView.assetSize;
    }
}

- (UIViewController *)canvasToolViewController
{
    return _cropViewController;
}

#pragma mark - Private Methods

- (void)assetSizeBecameAvailable:(NSNotification *)notification
{
    self.assetSize = self.canvasView.assetSize;
}

@end
