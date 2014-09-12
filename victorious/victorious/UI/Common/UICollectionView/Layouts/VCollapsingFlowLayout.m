//
//  VCollapsingFlowLayout.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCollapsingFlowLayout.h"

typedef NS_ENUM(NSInteger, VContentViewState)
{
    VContentViewStateBelowCatchPoint,
    VContentViewStateGreaterThanOrEqualToCatchPoint
};

@interface VCollapsingFlowLayout ()

@property (nonatomic, assign) CGFloat catchPoint;
@property (nonatomic, assign) CGFloat contentViewXTargetTranslation;
@property (nonatomic, assign) CGFloat contentViewYTargetTranslation;

// Publicly Readonly
@property (nonatomic, assign, readwrite) CGFloat dropDownHeaderMiniumHeight;
@property (nonatomic, assign, readwrite) CGSize sizeForContentView;
@property (nonatomic, assign, readwrite) CGSize sizeForRealTimeComentsView;

@end

static const CGFloat kVContentViewFloatingZIndex = 1000.0f;
static const CGFloat kVDropDownHeaderFloatingZIndex = 999.0f;
static const CGFloat kVContentViewFloatingScalingFactor = 0.21f;
static const CGFloat kVContentViewMinimumHeaderHeight = 110.0f;
static const CGFloat kVContentViewFlatingTrailingSpace = 16.0f;
static const CGFloat kVConentViewFloatingTopSpace = 40.0f;

@implementation VCollapsingFlowLayout

- (id)init
{
    self = [super init];
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
    self.sizeForContentView = CGSizeZero;
    self.sizeForRealTimeComentsView = CGSizeZero;
    self.catchPoint = 0.0f;
    self.contentViewXTargetTranslation = 0.0f;
    self.contentViewYTargetTranslation = 0.0f;
    self.dropDownHeaderMiniumHeight = kVContentViewMinimumHeaderHeight;
}

#pragma mark - UICollectionViewFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    [self updateInternalStateWithInitalLayoutAttributes:attributes];
    
    __block BOOL hasLayoutAttributesForContentView = NO;
    
    [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *layoutAttributes, NSUInteger idx, BOOL *stop)
    {

        switch ([self currentState])
        {
            case VContentViewStateBelowCatchPoint:
                if ([layoutAttributes.indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
                {
                    hasLayoutAttributesForContentView = YES;
                    layoutAttributes.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                        self.collectionView.contentOffset.y,
                                                        self.sizeForContentView.width,
                                                        self.sizeForContentView.height);
                }
                else if ([layoutAttributes.indexPath compare:[self realTimeCommentsIndexPath]] == NSOrderedSame)
                {
                    layoutAttributes.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                        self.collectionView.contentOffset.y + self.sizeForContentView.height,
                                                        self.sizeForRealTimeComentsView.width,
                                                        self.sizeForRealTimeComentsView.height);
                }
                break;
            case VContentViewStateGreaterThanOrEqualToCatchPoint:
            {
                if ([layoutAttributes.indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
                {
                    hasLayoutAttributesForContentView = YES;
                    [self layoutAttributesForContentViewPastSecondCatchPointUpdateInitialLayoutAttributes:layoutAttributes];
                }
                else if ([layoutAttributes.indexPath compare:[self realTimeCommentsIndexPath]] == NSOrderedSame)
                {
                    layoutAttributes.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                        self.collectionView.contentOffset.y + self.sizeForContentView.height,
                                                        self.sizeForRealTimeComentsView.width,
                                                        self.sizeForRealTimeComentsView.height);
                }
                break;
            }
                
        }
    }];
    
    if (self.collectionView.contentOffset.y > self.catchPoint)
    {
        
        UICollectionViewLayoutAttributes *dropDownHeaderLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                                          withIndexPath:[self contentViewIndexPath]];
        dropDownHeaderLayoutAttributes.frame = CGRectMake(CGRectGetMinX(self.collectionView.frame),
                                                          self.collectionView.contentOffset.y,
                                                          CGRectGetWidth(self.collectionView.frame),
                                                          self.dropDownHeaderMiniumHeight);
        dropDownHeaderLayoutAttributes.zIndex = kVDropDownHeaderFloatingZIndex;
        [attributes addObject:dropDownHeaderLayoutAttributes];
    }
    
    if (!hasLayoutAttributesForContentView)
    {
        [attributes addObject:[self layoutAttributesForContentViewPastSecondCatchPointUpdateInitialLayoutAttributes:nil]];
    }
    
    return attributes;
}

#pragma mark - Convenience

- (VContentViewState)currentState
{
    if (self.collectionView.contentOffset.y < self.catchPoint)
    {
        return VContentViewStateBelowCatchPoint;
    }
    else
    {
        return VContentViewStateGreaterThanOrEqualToCatchPoint;
    }
}

- (void)updateInternalStateWithInitalLayoutAttributes:(NSArray *)initialLayoutAttributes
{
    if (CGSizeEqualToSize(self.sizeForContentView,CGSizeZero))
    {
        UICollectionViewLayoutAttributes *layoutAttributesForContentView = [initialLayoutAttributes firstObject];
        self.sizeForContentView = layoutAttributesForContentView.size;
    }
    
    if (CGSizeEqualToSize(self.sizeForRealTimeComentsView, CGSizeZero))
    {
        UICollectionViewLayoutAttributes *layoutAttributesForRealTimeComments = [initialLayoutAttributes objectAtIndex:1];
        self.sizeForRealTimeComentsView = layoutAttributesForRealTimeComments.size;
        self.catchPoint = CGRectGetHeight(layoutAttributesForRealTimeComments.frame);
    }
    
    // Calculate translation from top right
    if (self.contentViewXTargetTranslation == 0.0f)
    {
        CGFloat minimizedWidth = self.sizeForContentView.width * kVContentViewFloatingScalingFactor;
        self.contentViewXTargetTranslation = (self.sizeForContentView.width * 0.5f) - (minimizedWidth * 0.5f) - kVContentViewFlatingTrailingSpace;
    }
    if (self.contentViewYTargetTranslation == 0.0f)
    {
        self.contentViewYTargetTranslation = (-self.sizeForContentView.height * 0.5f) + (self.dropDownHeaderMiniumHeight * 0.5f);
    }
}

- (NSIndexPath *)contentViewIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

- (NSIndexPath *)realTimeCommentsIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:1];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForContentViewPastSecondCatchPointUpdateInitialLayoutAttributes:(UICollectionViewLayoutAttributes *)initialLayoutAttributes
{
    UICollectionViewLayoutAttributes *layoutAttributes = initialLayoutAttributes ?: [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[self contentViewIndexPath]];
    
    layoutAttributes.zIndex = kVContentViewFloatingZIndex;
    layoutAttributes.center = CGPointMake(self.sizeForContentView.width * 0.5f, self.sizeForContentView.width * 0.5f);
    layoutAttributes.size = self.sizeForContentView;
    CGFloat deltaCatchPointToTop = self.collectionView.contentOffset.y - self.catchPoint;
    CGFloat percentCompleted = (deltaCatchPointToTop / (self.sizeForContentView.height - self.dropDownHeaderMiniumHeight));

    layoutAttributes.frame = CGRectMake(0,
                                        self.collectionView.contentOffset.y,
                                        self.sizeForContentView.width,
                                        self.sizeForContentView.height);

    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(fmaxf((1-percentCompleted), kVContentViewFloatingScalingFactor),
                                                                  fmaxf((1-percentCompleted), kVContentViewFloatingScalingFactor));

    CGFloat xTranslation = fminf(self.contentViewXTargetTranslation, self.contentViewXTargetTranslation * percentCompleted);
    CGFloat yTranslation = fmaxf(self.contentViewYTargetTranslation, self.contentViewYTargetTranslation * percentCompleted);

    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(xTranslation,
                                                                              yTranslation);
    CGAffineTransform combinedTransform = CGAffineTransformConcat(scaleTransform, translationTransform);

    layoutAttributes.transform = combinedTransform;
    
    return layoutAttributes;
}

@end
