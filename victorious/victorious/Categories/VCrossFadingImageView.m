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

//Defining a simple container to contain an imageView
@interface VImageViewContainer : UIView

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation VImageViewContainer

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
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.imageView];
    [self v_addFitToParentConstraintsToSubview:self.imageView];
}

@end

@interface VCrossFadingImageView ()

@property (nonatomic, strong) NSMutableArray *imageViewContainers;
@property (nonatomic, readwrite) NSArray *imageURLs;

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

- (void)setupWithImageURLs:(NSArray *)imageURLs tintColor:(UIColor *)tintColor andPlaceholderImage:(UIImage *)placeholderImage
{
    if ( [self.imageURLs isEqualToArray:imageURLs] )
    {
        //Nothing to update, return to avoid unnecessary reloading of images
        return;
    }
    
    self.imageURLs = imageURLs;
    for ( VImageViewContainer *imageViewContainer in self.imageViewContainers )
    {
        [imageViewContainer removeFromSuperview];
    }
    [self.imageViewContainers removeAllObjects];
    
    for (NSURL *imageURL in imageURLs)
    {
        VImageViewContainer *imageViewContainer = [[VImageViewContainer alloc] initWithFrame:self.bounds];
        imageViewContainer.alpha = 0.0f;
        [imageViewContainer.imageView setBlurredImageWithURL:imageURL placeholderImage:placeholderImage tintColor:tintColor];
        [self addSubview:imageViewContainer];
        [self v_addFitToParentConstraintsToSubview:imageViewContainer];
        [self.imageViewContainers addObject:imageViewContainer];
    }
    
    [self updateVisibleImageViewsForOffset:self.offset];
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
        CGFloat targetAlpha = fabsf(offset - (CGFloat)[self.imageViewContainers indexOfObject:imageViewContainer]);
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

@end
