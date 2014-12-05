//
//  VCanvasView.m
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCanvasView.h"

@interface VCanvasView ()

@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation VCanvasView

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
    
    _imageView = [[UIImageView alloc] initWithImage:nil];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_imageView];
    
    self.context = [CIContext contextWithOptions:@{}];
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
    self.imageView.image = [filter imageByFilteringImage:self.sourceImage
                                           withCIContext:self.context];
}

#pragma mark - Public Methods

- (void)setCroppedBounds:(CGRect)croppedBounds
{
    self.imageView.frame = CGRectMake(-croppedBounds.origin.x,
                                      -croppedBounds.origin.y,
                                      croppedBounds.size.width,
                                      croppedBounds.size.height);
}

@end
