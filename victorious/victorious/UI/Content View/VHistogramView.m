//
//  VHistogramView.m
//  victorious
//
//  Created by Michael Sena on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHistogramView.h"

#import "VThemeManager.h"

#ifdef __LP64__
#define FLOOR(a) floor(a)
#else
#define FLOOR(a) floorf(a)
#endif

@interface VHistogramView ()

@property (nonatomic, strong) NSMutableSet *slices;

@property (nonatomic, strong) CAShapeLayer *progressMask;

@end

@implementation VHistogramView

#pragma mark - Initializers

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _tickWidth = 2.0f;
    _tickSpacing = 1.5f;
    
    self.backgroundColor = [UIColor clearColor];
    
    CAShapeLayer *progressMask = [CAShapeLayer layer];
    progressMask.frame = CGRectMake(0, 0, 0, CGRectGetHeight(self.bounds));
    progressMask.backgroundColor = [UIColor blackColor].CGColor;
    self.progressMask = progressMask;
    [self.layer addSublayer:progressMask];
}

#pragma mark - Property Accessors

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    self.progressMask.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds) * _progress, CGRectGetHeight(self.bounds));
}

- (NSInteger)totalSlices
{
    CGFloat spacePerTick = self.tickSpacing + self.tickWidth;
    
    CGFloat tickSpace = CGRectGetWidth(self.bounds) - self.tickSpacing;
    
    return (NSInteger)FLOOR(tickSpace / spacePerTick);
}

#pragma mark - Public Methods

- (void)reloadData
{
    [self.slices enumerateObjectsUsingBlock:^(UIView *slice, BOOL *stop)
     {
         [slice removeFromSuperview];
     }];
    
    for (NSInteger sliceIndex = 0; sliceIndex < [self totalSlices]; sliceIndex++)
    {
        CGFloat heightForSlice = [self.dataSource histogram:self
                                        heightForSliceIndex:sliceIndex
                                                totalSlices:[self totalSlices]];
        heightForSlice = (heightForSlice > 0) ? heightForSlice : 0.5f;
        
        UIView *sliceForIndex = [[UIView alloc] initWithFrame:CGRectMake((self.tickWidth + self.tickSpacing)* sliceIndex + self.tickSpacing, 0, self.tickWidth, CGRectGetHeight(self.bounds))];
        
        sliceForIndex.layer.affineTransform = CGAffineTransformMakeScale(1, -1);
        
        CALayer *darkenedSlice = [CALayer layer];
        darkenedSlice.frame = CGRectMake(0, 0, CGRectGetWidth(sliceForIndex.bounds), ++heightForSlice);
        darkenedSlice.backgroundColor = [UIColor lightGrayColor].CGColor;
        [sliceForIndex.layer addSublayer:darkenedSlice];
        
        CALayer *coloredSlice = [CALayer layer];
        coloredSlice.frame = darkenedSlice.frame;
        coloredSlice.backgroundColor = [UIColor blueColor].CGColor;
        [sliceForIndex.layer addSublayer:coloredSlice];
        coloredSlice.mask = self.progressMask;
        
        [self addSubview:sliceForIndex];
    }
}

@end
