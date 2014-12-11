//
//  VCanvasView.m
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCanvasView.h"

@interface VCanvasView () <UIScrollViewDelegate>

@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *canvasScrollView;

@end

@implementation VCanvasView

#pragma mark - Dealloc

- (void)dealloc
{
    _canvasScrollView.delegate = nil;
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
    
    _canvasScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _canvasScrollView.minimumZoomScale = 1.0f;
    _canvasScrollView.maximumZoomScale = 4.0f;
    _canvasScrollView.userInteractionEnabled = NO;
    _canvasScrollView.delegate = self;
    [self addSubview:_canvasScrollView];
    
    _imageView = [[UIImageView alloc] initWithImage:nil];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_canvasScrollView addSubview:_imageView];
    
    _context = [CIContext contextWithOptions:@{}];
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
}

#pragma mark - Property Accessors

- (void)setSourceImage:(UIImage *)sourceImage
{
    _sourceImage = sourceImage;
    self.imageView.image = sourceImage;
    [self layoutIfNeeded];
}

- (void)setFilter:(VPhotoFilter *)filter
{
    _filter = filter;
    __block UIImage *filteredImage = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        filteredImage = [filter imageByFilteringImage:self.sourceImage
                                        withCIContext:self.context];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (_filter.name == filter.name)
            {
                self.imageView.image = filteredImage;
            }
        });
    });

}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
