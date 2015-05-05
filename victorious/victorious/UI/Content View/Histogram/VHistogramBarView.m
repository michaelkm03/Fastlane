//
//  VHistogramView.m
//  victorious
//
//  Created by Michael Sena on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHistogramBarView.h"
#import "VThemeManager.h"

static const CGFloat kMinimumTickHeight = 3.0f;
static const CGFloat kMaximumTickHeight = 19.0f;
static const CGFloat kDefaultWidth = 2.0f;
static const CGFloat kDefaultSpacing = 1.5f;
static const CGFloat kDarkeningAlpha = 0.3f;
static const CGFloat kColorAlpha = 0.6f;

@interface VHistogramBarView ()

@property (nonatomic, strong) NSMutableArray *coloredSlices;
@property (nonatomic, strong) NSMutableArray *sliceViews;

@end

@implementation VHistogramBarView

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
    _tickWidth = kDefaultWidth;
    _tickSpacing = kDefaultSpacing;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.coloredSlices = [[NSMutableArray alloc] init];
    self.sliceViews = [[NSMutableArray alloc] init];
    
    _progress = 0.0f;
}

#pragma mark - Property Accessors

- (void)setProgress:(CGFloat)progress
{
    _progress = fminf(fmaxf(progress, 0.0f), 1.0f);
    
    [self.coloredSlices enumerateObjectsUsingBlock:^(CALayer *coloredLayer, NSUInteger idx, BOOL *stop)
    {
        CGFloat layerProgress = CGRectGetMidX(coloredLayer.superlayer.frame) / CGRectGetWidth(self.bounds);
        coloredLayer.opacity = (layerProgress > self.progress) ? 0.0f : 1.0f;
    }];
}

- (void)setDataSource:(id<VHistogramBarViewDataSource>)dataSource
{
    _dataSource = dataSource;
    [self reloadData];
}

- (NSInteger)totalSlices
{
    CGFloat spacePerTick = self.tickSpacing + self.tickWidth;
    
    CGFloat tickSpace = CGRectGetWidth(self.bounds) - self.tickSpacing;
    
    return (NSInteger)VFLOOR(tickSpace / spacePerTick);
}

#pragma mark - Public Methods

- (void)reloadData
{
    [self.coloredSlices enumerateObjectsUsingBlock:^(CALayer *dimmedLayer, NSUInteger idx, BOOL *stop)
    {
        [dimmedLayer removeFromSuperlayer];
    }];
    [self.coloredSlices removeAllObjects];
    
    [self.sliceViews enumerateObjectsUsingBlock:^(UIView *sliceView, NSUInteger idx, BOOL *stop)
    {
        [sliceView removeFromSuperview];
    }];
    [self.sliceViews removeAllObjects];

    
    for (NSInteger sliceIndex = 0; sliceIndex < [self totalSlices]; sliceIndex++)
    {
        CGFloat heightForSlice = [self.dataSource histogramPercentageHeight:self
                                                                forBarIndex:sliceIndex
                                                                  totalBars:[self totalSlices]];
        
        heightForSlice = fminf(fmaxf(heightForSlice * CGRectGetHeight(self.bounds), kMinimumTickHeight), kMaximumTickHeight);
        
        UIView *sliceForIndex = [[UIView alloc] initWithFrame:CGRectMake((self.tickWidth + self.tickSpacing)* sliceIndex + self.tickSpacing, 0, self.tickWidth, CGRectGetHeight(self.bounds))];
        [self.sliceViews addObject:sliceForIndex];
        
        sliceForIndex.layer.affineTransform = CGAffineTransformMakeScale(1, -1);
        
        CALayer *darkenedSlice = [CALayer layer];
        darkenedSlice.frame = CGRectMake(0, 0, CGRectGetWidth(sliceForIndex.bounds), ++heightForSlice);
        darkenedSlice.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:kDarkeningAlpha].CGColor;
        [sliceForIndex.layer addSublayer:darkenedSlice];
        
        CALayer *coloredSlice = [CALayer layer];
        coloredSlice.frame = darkenedSlice.frame;
        coloredSlice.backgroundColor = [[[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor] colorWithAlphaComponent:kColorAlpha].CGColor;
        [sliceForIndex.layer addSublayer:coloredSlice];
        [self.coloredSlices addObject:coloredSlice];
        
        CGFloat sliceProgress = CGRectGetMidX(sliceForIndex.frame) / CGRectGetWidth(self.bounds);
        coloredSlice.opacity = (sliceProgress > self.progress) ? 0.0f : 1.0f;
        [self addSubview:sliceForIndex];
    }
}

@end
