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
        VLog(@"zoomscale: %@, contentOffset: %@", @(croppingScrollView.zoomScale), NSStringFromCGPoint(croppingScrollView.contentOffset));
    };
}

- (CGSize)assetSize
{
    return self.canvasView.assetSize;
}

#pragma mark - VWorkspaceTool

- (CIImage *)imageByApplyingToolToInputImage:(CIImage *)inputImage
{
    // Bail out if we don't have any operations to do.
    if (self.cropViewController.croppingScrollView == nil)
    {
        return inputImage;
    }
    
    // Scale image up
    CIFilter *lanczosScaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [lanczosScaleFilter setValue:inputImage
                          forKey:kCIInputImageKey];
    CGFloat zoomScale = self.cropViewController.croppingScrollView.zoomScale;
    [lanczosScaleFilter setValue:@(zoomScale)
                          forKey:kCIInputScaleKey];
    
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
