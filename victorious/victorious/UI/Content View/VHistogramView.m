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
    _tickSpacing = 2.0f;
}

#pragma mark - UIView overrides

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.slices enumerateObjectsUsingBlock:^(UIView *slice, BOOL *stop)
    {
        [slice removeFromSuperview];
    }];
    
    for (NSInteger sliceIndex = 0; sliceIndex < [self totalSlices]; sliceIndex++)
    {
        UIView *sliceForIndex = [[UIView alloc] initWithFrame:CGRectMake((self.tickWidth + self.tickSpacing)* sliceIndex + self.tickSpacing, 0, self.tickWidth, CGRectGetHeight(self.bounds))];
        
        sliceForIndex.backgroundColor = [[[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor] colorWithAlphaComponent:0.5];
        
        [self addSubview:sliceForIndex];
    }
}

#pragma mark - Property Accessors

- (NSInteger)totalSlices
{
    CGFloat spacePerTick = self.tickSpacing + self.tickWidth;
    
    CGFloat tickSpace = CGRectGetWidth(self.bounds) - (2*self.tickSpacing);
    
    return (NSInteger)FLOOR(tickSpace / spacePerTick);
}

@end
