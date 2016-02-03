//
//  VInsetMarqueeController.m
//  victorious
//
//  Created by Sharif Ahmed on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInsetMarqueeController.h"
#import "VInsetMarqueeCollectionViewCell.h"
#import "VInsetMarqueeStreamItemCell.h"
#import "VStreamItem+Fetcher.h"

static NSUInteger const kAnimationSteps = 44;
static NSUInteger const kAnimationBounces = 1;
static CGFloat const kAnimationBounceCoefficient = 0.008;

@interface VInsetMarqueeController ()

@property (nonatomic, assign) CGFloat targetXOffset;
@property (nonatomic, assign) CGFloat animationDistance;
@property (nonatomic, assign) NSUInteger animationIndex;
@property (nonatomic, strong) NSArray *animationValues;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation VInsetMarqueeController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if ( self != nil )
    {
        /*
            See http://khanlou.com/2012/01/cakeyframeanimation-make-it-bounce/
         */
        int steps = kAnimationSteps;
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
        double value = 0;
        float e = 2.71;
        NSUInteger bounces = kAnimationBounces * 2 + 1;
        for (int t = 0; t < steps; t++)
        {
            value = pow(e, -kAnimationBounceCoefficient * t * t) * cos(bounces * M_PI_2 * t / kAnimationSteps);
            [values addObject:[NSNumber numberWithFloat:value]];
        }
        _animationValues = values;
    }
    return self;
}

- (void)registerCollectionViewCellWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VInsetMarqueeCollectionViewCell nibForCell] forCellWithReuseIdentifier:[VInsetMarqueeCollectionViewCell suggestedReuseIdentifier]];
}

- (VAbstractMarqueeCollectionViewCell *)marqueeCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    VInsetMarqueeCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VInsetMarqueeCollectionViewCell suggestedReuseIdentifier] forIndexPath:indexPath];
    if ( collectionViewCell.marquee != self )
    {
        collectionViewCell.marquee = self;
        collectionViewCell.dependencyManager = self.dependencyManager;
        [self enableTimer];
    }
    return collectionViewCell;
}

- (void)selectNextTab
{
    NSUInteger currentPage = ( self.collectionView.contentOffset.x / self.pageWidth ) + 1;
    if (currentPage == self.marqueeItems.count)
    {
        currentPage = 0;
    }
    
    [self animateToHorizontalOffset:currentPage * self.pageWidth];
}

- (void)animateToHorizontalOffset:(CGFloat)offset
{
    self.targetXOffset = offset;
    self.animationDistance = self.targetXOffset - self.collectionView.contentOffset.x;
    self.animationIndex = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAnimation)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updateAnimation
{
    CGPoint offset = self.collectionView.contentOffset;
    if ( self.animationIndex >= kAnimationSteps)
    {
        offset.x = self.targetXOffset;
        [self endAnimation];
    }
    else
    {
        CGFloat multiplier = [self.animationValues[self.animationIndex] floatValue];
        offset.x = self.targetXOffset - multiplier * self.animationDistance;
    }
    self.animationIndex++;
    self.collectionView.contentOffset = offset;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self endAnimation];
}

- (void)endAnimation
{
    if ( self.displayLink != nil )
    {
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink = nil;
    }
}

- (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return [VInsetMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:bounds];
}

+ (Class)marqueeStreamItemCellClass
{
    return [VInsetMarqueeStreamItemCell class];
}

@end
