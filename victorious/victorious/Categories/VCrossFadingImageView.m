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
#import <objc/runtime.h>

static const NSTimeInterval kFadeAnimationDuration = 0.3f;
static const char kAssociatedObjectKey;

@interface VCrossFadingImageView ()

@property (nonatomic, strong) NSMutableArray *imageViewContainers;

@end

@implementation VCrossFadingImageView

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
    self.offset = 0.0f;
}

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
    
    [self updateVisibleImageViewsForOffset:self.offset];
}

- (NSInteger)imageViewCount
{
    return self.imageViewContainers.count;
}

- (void)reset
{
    for ( VImageViewContainer *imageViewContainer in self.imageViewContainers )
    {
        [imageViewContainer removeFromSuperview];
    }
    [self.imageViewContainers removeAllObjects];
}

- (void)updateVisibleImageViewsForOffset:(CGFloat)offset
{
    NSArray *currentlyVisibleImageViewContainers = [self visibleImageViewsForOffset:offset];
    if ( currentlyVisibleImageViewContainers == nil )
    {
        //There are no imageViews to update, just get out
        return;
    }
    
    for ( VImageViewContainer *imageViewContainer in self.imageViewContainers )
    {
        CGFloat targetAlpha = ABS(offset - (CGFloat)[self.imageViewContainers indexOfObject:imageViewContainer]);
        //Check to see if the imageView we're inspecting is completely hidden given the current offset amount
        if ( targetAlpha > 1.0 )
        {
            targetAlpha = 0.0f;
        }
        else
        {
            targetAlpha = 1.0 - targetAlpha;
        }
        imageViewContainer.alpha = targetAlpha;
    }

}

- (void)setOffset:(CGFloat)offset
{
    NSArray *currentlyVisibleImageViewContainers = [self visibleImageViewsForOffset:offset];
    if ( currentlyVisibleImageViewContainers == nil )
    {
        //There are no imageViews to update, just get out
        return;
    }
    
    CGFloat maxOffset = (CGFloat)( self.imageViewContainers.count - 1 );
    if ( offset < 0.0f )
    {
        offset = 0.0f;
    }
    else if ( offset >= maxOffset )
    {
        offset = maxOffset;
    }
    
    _offset = offset;
    
    [self updateVisibleImageViewsForOffset:offset];
}

- (NSArray *)visibleImageViewsForOffset:(CGFloat)offset
{
    if ( self.imageViewContainers.count == 0 )
    {
        return nil;
    }
    
    NSInteger lowIndex = floorf(offset);
    NSInteger highIndex = ceilf(offset);
    NSMutableArray *visibleImageViewContainers = [[NSMutableArray alloc] init];
    
    if ( lowIndex >= 0 && lowIndex < (NSInteger)self.imageViewContainers.count )
    {
        [visibleImageViewContainers addObject:self.imageViewContainers[lowIndex]];
    }
    else if ( lowIndex < 0 )
    {
        return @[[self.imageViewContainers firstObject]];
    }
    else if ( lowIndex >= (NSInteger)self.imageViewContainers.count )
    {
        return @[[self.imageViewContainers lastObject]];
    }
    
    if ( lowIndex != highIndex && highIndex > 0 && highIndex < (NSInteger)self.imageViewContainers.count )
    {
        [visibleImageViewContainers addObject:self.imageViewContainers[highIndex]];
    }
    
    return [NSArray arrayWithArray:visibleImageViewContainers];
}

- (void)updateBlurredImageViewForImage:(UIImage *)image fromURL:(NSURL *)url withTintColor:(UIColor *)tintColor atIndex:(NSInteger)index animated:(BOOL)animated
{
    NSInteger count = (NSInteger)self.imageViewContainers.count;
    if ( index >= count )
    {
        return;
    }
    
    VImageViewContainer *imageViewContainer = ((VImageViewContainer *)self.imageViewContainers[index]);
    NSURL *loadedURL = objc_getAssociatedObject(imageViewContainer, &kAssociatedObjectKey);
    //Only need to update the imageViewContainer if it isn't already showing the image
    if ( ![loadedURL isEqual:url] )
    {
        //Check if image load failed; if so, don't associate it with the url so it retries the next time this method is called
        if ( !( url != nil && image == nil ) )
        {
            objc_setAssociatedObject(imageViewContainer, &kAssociatedObjectKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        NSTimeInterval duration = animated ? kFadeAnimationDuration : 0.0f;
        [imageViewContainer.imageView blurAndAnimateImageToVisible:image withTintColor:tintColor andDuration:duration];
    }
}

@end
