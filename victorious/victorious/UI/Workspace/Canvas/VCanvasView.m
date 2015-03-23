//
//  VCanvasView.m
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCanvasView.h"
#import "CIImage+VImage.h"
#import <UIImageView+WebCache.h>
#import "UIScrollView+VCenterContent.h"
#import "VPhotoFilter.h"

NSString * const VCanvasViewAssetSizeBecameAvailableNotification = @"VCanvasViewAssetSizeBecameAvailableNotification";

static const CGFloat kRelatvieScaleFactor = 0.55f;

@interface VCanvasView () <UIScrollViewDelegate, NSCacheDelegate>

@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) UIImage *scaledImage;
@property (nonatomic, strong, readwrite) UIImage *sourceImage;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *canvasScrollView;
@property (nonatomic, assign) BOOL didZoomFromDoubleTap;
@property (nonatomic, strong) NSCache *renderedImageCache;
@property (nonatomic, strong) dispatch_queue_t renderingQueue;
@property (nonatomic, strong) NSMutableArray *rendertimes;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation VCanvasView

#pragma mark - Dealloc

- (void)dealloc
{
    _canvasScrollView.delegate = nil;
    _renderedImageCache.delegate = nil;
}

#pragma mark - Initializers

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.clipsToBounds = YES;
    
    _renderingQueue = dispatch_queue_create("com.victorious.canvasRenderingQueue", DISPATCH_QUEUE_SERIAL);
    _renderedImageCache = [[NSCache alloc] init];
    _renderedImageCache.delegate = self;
    
    _canvasScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _canvasScrollView.minimumZoomScale = 1.0f;
    _canvasScrollView.maximumZoomScale = 4.0f;
    _canvasScrollView.delegate = self;
    _canvasScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _canvasScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_canvasScrollView];
    
    _imageView = [[UIImageView alloc] initWithImage:nil];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_canvasScrollView addSubview:_imageView];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapCanvas:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [_canvasScrollView addGestureRecognizer:doubleTapGestureRecognizer];
    
    _context = [CIContext contextWithOptions:@{}];
    
    _rendertimes = [[NSMutableArray alloc] init];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.hidesWhenStopped = YES;
    _activityIndicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_activityIndicator];
    
    //Add constraints to keep the actitivity indicator in the center of the canvas
    NSDictionary *views = @{ @"activityIndicator":_activityIndicator };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[activityIndicator]|"
                                                                options:0
                                                                metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[activityIndicator]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    
    [_activityIndicator startAnimating];
}

#pragma mark - UIVIew

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.sourceImage == nil)
    {
        return;
    }
    
    CGRect imageViewFrame;
    CGFloat scaleFactor;
    if (self.sourceImage.size.height > self.sourceImage.size.width)
    {
        scaleFactor = self.sourceImage.size.width / CGRectGetWidth(self.canvasScrollView.frame);
        imageViewFrame = CGRectMake(CGRectGetMinX(self.bounds),
                                    CGRectGetMinY(self.bounds),
                                    CGRectGetWidth(self.bounds),
                                    self.sourceImage.size.height * (1/scaleFactor));
    }
    else
    {
        scaleFactor = self.sourceImage.size.height / CGRectGetWidth(self.canvasScrollView.frame);
        imageViewFrame = CGRectMake(CGRectGetMinX(self.bounds),
                                    CGRectGetMinY(self.bounds),
                                    self.sourceImage.size.width * (1/scaleFactor),
                                    CGRectGetHeight(self.bounds));
    }
    
    self.imageView.frame = imageViewFrame;
    self.canvasScrollView.contentSize = imageViewFrame.size;
    [self.canvasScrollView v_centerZoomedContentAnimated:NO];
}

#pragma mark - Property Accessors

- (void)setSourceURL:(NSURL *)URL
  withPreloadedImage:(UIImage *)preloadedImage
{
    __weak typeof(self) welf = self;
    void (^imageFinishedLoadingBlock)(UIImage *sourceImage, BOOL animate) = ^void(UIImage *sourceImage, BOOL animate)
    {
        __strong typeof(self) strongSelf = welf;
        strongSelf.sourceImage = sourceImage;
        [strongSelf layoutSubviews];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VCanvasViewAssetSizeBecameAvailableNotification
                                                            object:strongSelf];
        [strongSelf.activityIndicator stopAnimating];
        if (!animate)
        {
            return;
        }
        
        strongSelf.imageView.alpha = 0.0f;
        [UIView animateWithDuration:1.75f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.0f
                            options:kNilOptions
                         animations:^
         {
             strongSelf.imageView.alpha = 1.0f;
         }
                         completion:nil];
    };
    
    if (preloadedImage != nil)
    {
        imageFinishedLoadingBlock(preloadedImage, NO);
        return;
    }
    
    [self.imageView sd_setImageWithURL:URL
                      placeholderImage:nil
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        if (image)
        {
            imageFinishedLoadingBlock(image, YES);
        }
    }];
}

- (void)setSourceURL:(NSURL *)URL
{
    [self setSourceURL:URL
    withPreloadedImage:nil];
}

- (void)setSourceImage:(UIImage *)sourceImage
{
    _sourceImage = sourceImage;

    CGImageRef scaledImageRef = [self.context createCGImage:[self scaledImageForCurrentFrameAndMaxZoomLevel]
                                                   fromRect:[[self scaledImageForCurrentFrameAndMaxZoomLevel] extent]];
    _scaledImage = [UIImage imageWithCGImage:scaledImageRef
                                       scale:sourceImage.scale
                                 orientation:sourceImage.imageOrientation];
    CGImageRelease(scaledImageRef);
    
    self.imageView.image = _scaledImage;
    
    VLog(@"canvasFrame: %@, content size: %@, min zoom scale: %@", NSStringFromCGRect(self.canvasScrollView.frame), NSStringFromCGSize(self.canvasScrollView.contentSize), @(self.canvasScrollView.zoomScale));
    self.activityIndicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self layoutIfNeeded];
}

- (void)setFilter:(VPhotoFilter *)filter
{
    _filter = filter;
    
    if (self.scaledImage == nil)
    {
        return;
    }

    if ([self.renderedImageCache objectForKey:filter.description] != nil)
    {
        self.imageView.image = [self.renderedImageCache objectForKey:filter.description];
        return;
    }
    
    __block UIImage *filteredImage = nil;
    
    dispatch_async(self.renderingQueue, ^
    {
        // Render
        filteredImage = [filter imageByFilteringImage:self.scaledImage
                                        withCIContext:self.context];
        
        // Cache
        [self.renderedImageCache setObject:filteredImage
                                    forKey:filter.description];
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           if (_filter.name == filter.name)
                           {
                               self.imageView.image = filteredImage;
                           }
                       });
    });
}

- (CGSize)assetSize
{
    return self.imageView.image.size;
}

- (UIImage *)asset
{
    return self.imageView.image;
}

#pragma mark - Target/Action

- (void)doubleTapCanvas:(UITapGestureRecognizer *)sender
{
    CGPoint locationInView = [sender locationInView:self.imageView];

    if (self.canvasScrollView.zoomScale > self.canvasScrollView.minimumZoomScale)
    {
        [self.canvasScrollView v_centerZoomedContentAnimated:YES];
    }
    else
    {
        CGFloat zoomedWidth = CGRectGetWidth(self.canvasScrollView.bounds) / self.canvasScrollView.maximumZoomScale;
        [self.canvasScrollView zoomToRect:CGRectMake(locationInView.x - (zoomedWidth/2),
                                                     locationInView.y - (zoomedWidth/2),
                                                     zoomedWidth,
                                                     zoomedWidth)
                                 animated:YES];
//        CGFloat zoomedWidth = (contentSizeWidth / self.canvasScrollView.maximumZoomScale);
//        [self.canvasScrollView zoomToRect:CGRectMake(locationInView.x - (zoomedWidth/2),
//                                                     locationInView.y - (zoomedWidth/2),
//                                                     contentSizeWidth / zoomedWidth,
//                                                     contentSizeWidth / zoomedWidth)
//                                 animated:YES];
    }
    
    self.didZoomFromDoubleTap = YES;
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCropWorkspaceWithDoubleTap];
}

#pragma mark - Private Mehtods


- (CIImage *)scaledImageForCurrentFrameAndMaxZoomLevel
{
    CIImage *scaledImage = [CIImage v_imageWithUImage:_sourceImage];
    
    CGFloat scaleFactor = 1.0f;
    CGRect sourceExtent = [scaledImage extent];
    if (CGRectGetWidth(sourceExtent) > CGRectGetWidth(self.bounds) * self.canvasScrollView.maximumZoomScale * kRelatvieScaleFactor)
    {
        scaleFactor = (CGRectGetWidth(self.bounds) * self.canvasScrollView.maximumZoomScale * kRelatvieScaleFactor)  / CGRectGetWidth(sourceExtent);
    }
    else if (CGRectGetHeight(sourceExtent) > CGRectGetHeight(self.bounds) * self.canvasScrollView.maximumZoomScale * kRelatvieScaleFactor)
    {
        scaleFactor = (CGRectGetHeight(self.bounds) * self.canvasScrollView.maximumZoomScale * kRelatvieScaleFactor) / CGRectGetHeight(sourceExtent);
    }
    
    CIFilter *lanczosScaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [lanczosScaleFilter setValue:scaledImage
                          forKey:kCIInputImageKey];
    [lanczosScaleFilter setValue:@(scaleFactor)
                          forKey:kCIInputScaleKey];
    return [lanczosScaleFilter outputImage];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
