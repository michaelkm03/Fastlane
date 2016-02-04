//
//  VCrossFadingImageView.m
//  victorious
//
//  Created by Sharif Ahmed on 3/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCrossFadingImageView.h"
#import "UIImageView+Blurring.h"
#import "UIImageView+VLoadingAnimations.h"
#import "UIView+AutoLayout.h"
#import "VImageViewContainer.h"
#import "UIImage+ImageCreation.h"
#import "VStreamItemPreviewView.h"
#import "VStreamItem+Fetcher.h"

static const NSTimeInterval kFadeAnimationDuration = 0.3f;
static const CGFloat kVisibilitySpan = 1.9f;

@interface VCrossFadingImageView ()

@property (nonatomic, strong) NSMutableArray *imageViewContainers;
@property (nonatomic, strong) NSMutableDictionary *loadedStreamItems;

@end

@implementation VCrossFadingImageView

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.imageViewContainers = [[NSMutableArray alloc] init];
    self.loadedStreamItems = [[NSMutableDictionary alloc] init];
    self.visibilitySpan = kVisibilitySpan;
    self.clampsOffset = YES;
}

#pragma mark - View setup

- (void)setupWithNumberOfImageViews:(NSInteger)numberOfImageViews
{
    [self reset];
    
    for (NSInteger i = 0 ; i < numberOfImageViews; i++ )
    {
        VImageViewContainer *imageViewContainer = [[VImageViewContainer alloc] initWithFrame:self.bounds];
        imageViewContainer.alpha = 0.0f;
        [self addSubview:imageViewContainer];
        [self v_addFitToParentConstraintsToSubview:imageViewContainer];
        [self.imageViewContainers addObject:imageViewContainer];
    }
    
    [self refresh];
}

- (void)reset
{
    for ( VImageViewContainer *imageViewContainer in self.imageViewContainers )
    {
        [imageViewContainer removeFromSuperview];
    }
    [self.imageViewContainers removeAllObjects];
}

- (void)updateBlurredImageViewForImage:(UIImage *)image fromPreviewView:(VStreamItemPreviewView *)previewView withTintColor:(UIColor *)tintColor atIndex:(NSInteger)index animated:(BOOL)animated withConcurrentAnimations:(void (^)(void))concurrentAnimations
{
    NSInteger count = (NSInteger)self.imageViewContainers.count;
    if ( index >= count )
    {
        return;
    }
    
    VImageViewContainer *imageViewContainer = ((VImageViewContainer *)self.imageViewContainers[index]);
    VStreamItem *previewStreamItem = previewView.streamItem;
    NSNumber *key = @(index);
    
    //Only need to update the imageViewContainer if it isn't already showing the image
    if ( !([self.loadedStreamItems[key] isEqual:previewStreamItem] && imageViewContainer.imageView.image != nil) )
    {
        self.loadedStreamItems[key] = previewStreamItem;
        NSTimeInterval duration = animated ? kFadeAnimationDuration : 0.0f;
        NSURL *blurredViewURL = [[previewStreamItem previewImageUrl] URLByAppendingPathComponent:@"marqueeView"];
        [imageViewContainer.imageView blurAndAnimateImageToVisible:image cacheURL:blurredViewURL withTintColor:tintColor andDuration:duration withConcurrentAnimations:concurrentAnimations];
    }
}

#pragma mark - Accessors

- (NSInteger)imageViewCount
{
    return self.imageViewContainers.count;
}

#pragma mark - Superclass overrides

- (NSArray *)crossFadingViews
{
    return self.imageViewContainers;
}

@end
