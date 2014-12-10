//
//  VCropWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCropWorkspaceTool.h"

#import "VCanvasView.h"

#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspaceTool.h"

#import "VCropWorkspaceToolViewController.h"

static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";
static NSString * const kFilterIndexKey = @"filterIndex";

@interface VCropWorkspaceTool ()

@property (nonatomic, assign) CGSize assetSize;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSNumber *filterIndexNumber;
@property (nonatomic, strong, readwrite) VCropWorkspaceToolViewController *cropViewController;
@property (nonatomic, strong) VCanvasView *canvasView;

@end

@implementation VCropWorkspaceTool

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        _filterIndexNumber = [dependencyManager numberForKey:kFilterIndexKey];
        _cropViewController = [VCropWorkspaceToolViewController cropViewController];
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
        [welf.canvasView.canvasScrollView setZoomScale:croppingScrollView.zoomScale];
        [welf.canvasView.canvasScrollView setContentOffset:croppingScrollView.contentOffset];
    };
}

- (CGSize)assetSize
{
    return _cropViewController.assetSize;
}

- (void (^)(UIScrollView *croppingScrollVIew))onCropBoundsChange
{
    return _cropViewController.onCropBoundsChange;
}

#pragma mark - VWorkspaceTool

- (CIImage *)imageByApplyingToolToInputImage:(CIImage *)inputImage
{
    // Scale image up
    CIFilter *lanczosScaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [lanczosScaleFilter setValue:inputImage
                          forKey:kCIInputImageKey];
    CGFloat zoomScale = self.cropViewController.croppingScrollView.zoomScale;
    [lanczosScaleFilter setValue:@(zoomScale)
                          forKey:@"inputScale"];
    
    // Crop at new size
    CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
    [cropFilter setValue:[lanczosScaleFilter outputImage]
                  forKey:kCIInputImageKey];
    
    CGFloat zoomedWidth = [inputImage extent].size.width * zoomScale;
    CGFloat zoomedHeight = [inputImage extent].size.height * zoomScale;
    CGPoint contentOffset = self.cropViewController.croppingScrollView.contentOffset;
    CGSize contentSize = self.cropViewController.croppingScrollView.contentSize;
    CGRect croppingBounds = self.cropViewController.croppingScrollView.bounds;
    CIVector *cropVector = [CIVector vectorWithCGRect:CGRectMake(((contentOffset.x / contentSize.width)* zoomedWidth),
                                                                 zoomedHeight - ((contentOffset.y / contentSize.height)* zoomedHeight) ,
                                                                 (croppingBounds.size.width / contentSize.width)* zoomedWidth,
                                                                 -((croppingBounds.size.height / contentSize.height)* zoomedHeight))];
    [cropFilter setValue:cropVector
                  forKey:@"inputRectangle"];
    
    return [cropFilter outputImage];
}

- (NSInteger)renderIndex
{
    return [self.filterIndexNumber integerValue];
}

- (void)setOnCropBoundsChange:(void (^)(UIScrollView *croppingScrollVIew))onCropBoundsChange
{
    _cropViewController.onCropBoundsChange = onCropBoundsChange;
}

- (void)setCanvasView:(VCanvasView *)canvasView
{
    _canvasView = canvasView;
    self.assetSize = canvasView.sourceImage.size;
}


- (UIViewController *)canvasToolViewController
{
    return _cropViewController;
}

- (NSString *)title
{
    return _title;
}

- (UIImage *)icon
{
    return _icon;
}

@end
