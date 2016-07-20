//
//  VCanvasView.m
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCanvasView.h"
#import "CIImage+VImage.h"
#import "UIScrollView+VCenterContent.h"
#import "VPhotoFilter.h"
#import "Victorious-swift.h"

@import SDWebImage;

NSString * const VCanvasViewAssetSizeBecameAvailableNotification = @"VCanvasViewAssetSizeBecameAvailableNotification";

static const CGFloat kRelatvieScaleFactor = 0.55f;

@interface VCanvasView () <UIScrollViewDelegate, NSCacheDelegate>

@property (nonatomic, strong) VFilteredImageView *filteredImageView;

@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) UIImage *scaledImage;
@property (nonatomic, strong, readwrite) UIImage *sourceImage;
@property (nonatomic, strong) UIScrollView *canvasScrollView;
@property (nonatomic, assign, readwrite) BOOL didZoomFromDoubleTap;
@property (nonatomic, assign, readwrite) BOOL didCropZoom;
@property (nonatomic, assign, readwrite) BOOL didCropPan;
@property (nonatomic, strong) NSCache *renderedImageCache;
@property (nonatomic, strong) dispatch_queue_t renderingQueue;
@property (nonatomic, strong) NSMutableArray *rendertimes;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign, getter = hasLayedOutCanvasScrollView) BOOL layedoutCanvasScrollView;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;

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
    _canvasScrollView.bouncesZoom = YES;
    _canvasScrollView.alwaysBounceVertical = YES;
    _canvasScrollView.alwaysBounceHorizontal = YES;
    _canvasScrollView.delegate = self;
    _canvasScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _canvasScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_canvasScrollView];
    
    _filteredImageView = [[VFilteredImageView alloc] initWithFrame:self.bounds];
    _filteredImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_canvasScrollView addSubview:_filteredImageView];
    
    _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapCanvas:)];
    _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [_canvasScrollView addGestureRecognizer:_doubleTapGestureRecognizer];
    
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
        self.filteredImageView.frame = self.canvasScrollView.bounds;
        return;
    }
    
    if (self.hasLayedOutCanvasScrollView)
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
    
    self.filteredImageView.frame = imageViewFrame;
    self.canvasScrollView.contentSize = imageViewFrame.size;
    [self.canvasScrollView v_centerZoomedContentAnimated:NO];
    self.layedoutCanvasScrollView = YES;
}

#pragma mark - Property Accessors

- (void)setSourceURL:(NSURL *)URL
  withPreloadedImage:(UIImage *)preloadedImage
{
    
    __weak typeof(self) welf = self;
    void (^imageFinishedLoadingBlock)(UIImage *sourceImage, BOOL animate) = ^void(UIImage *sourceImage, BOOL animate)
    {
        __strong typeof(welf) strongSelf = welf;
        strongSelf.sourceImage = sourceImage;
        [strongSelf layoutSubviews];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VCanvasViewAssetSizeBecameAvailableNotification
                                                            object:strongSelf];
        [strongSelf.activityIndicator stopAnimating];
        if (!animate)
        {
            return;
        }
        
        strongSelf.filteredImageView.alpha = 0.0f;
        [UIView animateWithDuration:1.75f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.0f
                            options:kNilOptions
                         animations:^
         {
             strongSelf.filteredImageView.alpha = 1.0f;
         }
                         completion:nil];
    };
    
    if (preloadedImage != nil)
    {
        imageFinishedLoadingBlock(preloadedImage, NO);
        return;
    }
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:URL
                                                          options:kNilOptions
                                                         progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
     {
         __strong typeof(welf) strongSelf = welf;
         if (image)
         {
             strongSelf.filteredImageView.inputImage = image;
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
    
    self.filteredImageView.inputImage = sourceImage;
    
    self.activityIndicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self layoutIfNeeded];
}

- (void)setFilter:(VPhotoFilter *)filter
{
    _filter = filter;
    self.filteredImageView.filter = filter;
}

- (CGSize)assetSize
{
    return self.filteredImageView.inputImage.size;
}

- (UIImage *)asset
{
    return self.filteredImageView.inputImage;
}

#pragma mark - Target/Action

- (void)doubleTapCanvas:(UITapGestureRecognizer *)sender
{
    CGPoint locationInView = [sender locationInView:self.filteredImageView];

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
    }
    
    self.didZoomFromDoubleTap = YES;
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCropWorkspaceWithDoubleTap];
}

#pragma mark - Private Mehtods

- (UIImage *)scaledImageForCurrentFrameAndMaxZoomLevel
{
    CGFloat scale = 1.0f;
    CGRect sourceExtent = CGRectMake(0, 0, self.sourceImage.size.width, self.sourceImage.size.height);
    if (CGRectGetWidth(sourceExtent) > CGRectGetWidth(self.bounds) * self.canvasScrollView.maximumZoomScale * kRelatvieScaleFactor)
    {
        scale = (CGRectGetWidth(self.bounds) * self.canvasScrollView.maximumZoomScale * kRelatvieScaleFactor)  / CGRectGetWidth(sourceExtent);
    }
    else if (CGRectGetHeight(sourceExtent) > CGRectGetHeight(self.bounds) * self.canvasScrollView.maximumZoomScale * kRelatvieScaleFactor)
    {
        scale = (CGRectGetHeight(self.bounds) * self.canvasScrollView.maximumZoomScale * kRelatvieScaleFactor) / CGRectGetHeight(sourceExtent);
    }
    
    CGSize scaledSize = CGSizeApplyAffineTransform( self.sourceImage.size, CGAffineTransformMakeScale(scale, scale) );
    
    UIGraphicsBeginImageContextWithOptions(scaledSize, YES, [[UIScreen mainScreen] scale]);
    [self.sourceImage drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return output;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.filteredImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if ( !self.didZoomFromDoubleTap && !self.didCropZoom )
    {
        self.didCropZoom = YES;
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCropWorkspaceWithZoom];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( !scrollView.isZooming && !self.didCropPan )
    {
        self.didCropPan = YES;
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCropWorkspaceWithPan];
    }
}

#pragma mark - Setters

- (void)setAllowsZoom:(BOOL)allowsZoom
{
    _allowsZoom = allowsZoom;
    self.doubleTapGestureRecognizer.enabled = allowsZoom;
    self.canvasScrollView.maximumZoomScale = allowsZoom ? 4.0 : 1.0;
    self.canvasScrollView.bouncesZoom = allowsZoom;
}

@end
