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
static NSString * const kToolInterfaceKey = @"toolInterface";
static NSString * const kFilterIndexKey = @"filterIndex";

@interface VCropWorkspaceTool ()

@property (nonatomic, assign) CGSize assetSize;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSNumber *filterIndexNumber;
@property (nonatomic, strong, readwrite) VCropWorkspaceToolViewController *cropViewController;

@end

@implementation VCropWorkspaceTool

@synthesize canvasView = _canvasView;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        _filterIndexNumber = [dependencyManager numberForKey:kFilterIndexKey];
        _cropViewController = (VCropWorkspaceToolViewController *)[dependencyManager viewControllerForKey:kToolInterfaceKey];
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
    // Apply scale
//    CIFilter *transformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
//    // Scale
//    CGFloat zoomScale = self.cropViewController.croppingScrollView.zoomScale;
//    CGAffineTransform transform = CGAffineTransformMakeScale( zoomScale, zoomScale);
//    [transformFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)]
//                       forKey:@"inputTransform"];
//    
//    [transformFilter setValue:inputImage forKey:kCIInputImageKey];
    
    // Apply crop
    CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
    CIVector *cropVector = [CIVector vectorWithCGRect:CGRectMake(((self.cropViewController.croppingScrollView.contentOffset.x / self.cropViewController.croppingScrollView.contentSize.width)* [inputImage extent].size.width),
                                                                 [inputImage extent].size.height - ((self.cropViewController.croppingScrollView.contentOffset.y / self.cropViewController.croppingScrollView.contentSize.height)* [inputImage extent].size.height),
                                                                 ((self.cropViewController.croppingScrollView.bounds.size.width / self.cropViewController.croppingScrollView.contentSize.width)* [inputImage extent].size.width),
                                                                 -((self.cropViewController.croppingScrollView.bounds.size.height / self.cropViewController.croppingScrollView.contentSize.height)* [inputImage extent].size.height))];
    
    [cropFilter setValue:inputImage forKey:kCIInputImageKey];
    [cropFilter setValue:cropVector forKey:@"inputRectangle"];
    
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
