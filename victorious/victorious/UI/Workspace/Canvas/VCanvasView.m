//
//  VCanvasView.m
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCanvasView.h"
#import "CIImage+VImage.h"
#import <UIImageView+AFNetworking.h>

static const CGFloat kRelatvieScaleFactor = 0.55f;

@interface VCanvasView () <UIScrollViewDelegate, NSCacheDelegate>

@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) UIImage *scaledImage;
@property (nonatomic, strong, readwrite) UIImage *sourceImage;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *canvasScrollView;
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
    _canvasScrollView.userInteractionEnabled = NO;
    _canvasScrollView.delegate = self;
    _canvasScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_canvasScrollView];
    
    _imageView = [[UIImageView alloc] initWithImage:nil];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_canvasScrollView addSubview:_imageView];
    
    _context = [CIContext contextWithOptions:@{}];
    
    _rendertimes = [[NSMutableArray alloc] init];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.hidesWhenStopped = YES;
    _activityIndicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.imageView.image == nil)
    {
        return;
    }
    
    CGRect imageViewFrame;
    
    if (self.sourceImage.size.height > self.sourceImage.size.width)
    {
        CGFloat scaleFactor = self.sourceImage.size.width / CGRectGetWidth(self.bounds);
        imageViewFrame = CGRectMake(CGRectGetMinX(self.bounds),
                                    CGRectGetMinY(self.bounds),
                                    CGRectGetWidth(self.bounds),
                                    self.sourceImage.size.height * (1/scaleFactor));
    }
    else
    {
        CGFloat scaleFactor = self.sourceImage.size.height / CGRectGetHeight(self.bounds);
        imageViewFrame = CGRectMake(CGRectGetMinX(self.bounds),
                                    CGRectGetMinY(self.bounds),
                                    self.sourceImage.size.width * (1/scaleFactor),
                                    CGRectGetHeight(self.bounds));
    }
    
    _imageView.frame = imageViewFrame;
    
    self.canvasScrollView.contentSize = imageViewFrame.size;
    self.activityIndicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
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
        [strongSelf layoutIfNeeded];
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
    
    if (preloadedImage!= nil)
    {
        imageFinishedLoadingBlock(preloadedImage, NO);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [self.imageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         if (image)
         {
             imageFinishedLoadingBlock(image, YES);
         }
     }
                                   failure:nil];
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
    self.imageView.frame = self.canvasScrollView.bounds;
    [self layoutIfNeeded];
}

- (void)setFilter:(VPhotoFilter *)filter
{
    _filter = filter;

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
