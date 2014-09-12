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
    VContentViewStateBelowFirstCatchPoint,
    VContentViewStateGreaterThanOrEqualToFirstCatchPointAndLessThanSecondCatchPoint,
    VContentViewStateGreaterThanOrEqualToSecondCatchPoint
};

@interface VCollapsingFlowLayout ()

@property (nonatomic, assign) CGFloat firstCatchPoint;
@property (nonatomic, assign) CGFloat secondCatchPoint;
@property (nonatomic, assign) CGFloat contentViewMaxXTranslation;
@property (nonatomic, assign) CGFloat contentViewMaxYTranslation;

// Publicly Readonly
@property (nonatomic, assign, readwrite) CGFloat dropDownHeaderMiniumHeight;
@property (nonatomic, assign, readwrite) CGSize sizeForContentView;
@property (nonatomic, assign, readwrite) CGSize sizeForRealTimeComentsView;
@property (nonatomic, assign, readwrite) CGSize sizeForTitleView;

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
    self.sizeForTitleView = CGSizeZero;
    self.firstCatchPoint = 0.0f;
    self.secondCatchPoint = 0.0f;
    self.contentViewMaxXTranslation = 0.0f;
    self.contentViewMaxYTranslation = 0.0f;
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
            case VContentViewStateBelowFirstCatchPoint:
                if ([layoutAttributes.indexPath compare:[self titleIndexPath]] == NSOrderedSame)
                {
                    layoutAttributes.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                        self.collectionView.contentOffset.y,
                                                        self.sizeForTitleView.width,
                                                        self.sizeForTitleView.height);
                }
                else if ([layoutAttributes.indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
                {
                    hasLayoutAttributesForContentView = YES;
                    layoutAttributes.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                        self.collectionView.contentOffset.y + self.sizeForTitleView.height,
                                                        self.sizeForContentView.width,
                                                        self.sizeForContentView.height);
                }
                else if ([layoutAttributes.indexPath compare:[self realTimeCommentsIndexPath]] == NSOrderedSame)
                {
                    layoutAttributes.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                        self.collectionView.contentOffset.y + self.sizeForTitleView.height + self.sizeForContentView.height,
                                                        self.sizeForRealTimeComentsView.width,
                                                        self.sizeForRealTimeComentsView.height);
                }
                break;
            case VContentViewStateGreaterThanOrEqualToFirstCatchPointAndLessThanSecondCatchPoint:
            {
                CGFloat deltaToFirstCatchPoint = self.collectionView.contentOffset.y - self.firstCatchPoint;
            
                if ([layoutAttributes.indexPath compare:[self titleIndexPath]] == NSOrderedSame)
                {
                    layoutAttributes.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                        self.collectionView.contentOffset.y - deltaToFirstCatchPoint,
                                                        self.sizeForTitleView.width,
                                                        self.sizeForTitleView.height);
                }
                else if ([layoutAttributes.indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
                {
                    hasLayoutAttributesForContentView = YES;
                    layoutAttributes.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                        self.collectionView.contentOffset.y + self.sizeForTitleView.height - deltaToFirstCatchPoint,
                                                        self.sizeForContentView.width,
                                                        self.sizeForContentView.height);
                }
                else if ([layoutAttributes.indexPath compare:[self realTimeCommentsIndexPath]] == NSOrderedSame)
                {
                    layoutAttributes.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                        self.collectionView.contentOffset.y + self.sizeForTitleView.height + self.sizeForContentView.height,
                                                        self.sizeForRealTimeComentsView.width,
                                                        self.sizeForRealTimeComentsView.height);
                }
                break;
            }
            case VContentViewStateGreaterThanOrEqualToSecondCatchPoint:
            {
                CGFloat deltaToSecondCatchPoint = self.collectionView.contentOffset.y - self.secondCatchPoint;
                
                if ([layoutAttributes.indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
                {
                    hasLayoutAttributesForContentView = YES;
                    [self layoutAttributesForContentViewPastSecondCatchPointUpdateInitialLayoutAttributes:layoutAttributes];
                }
                else if ([layoutAttributes.indexPath compare:[self realTimeCommentsIndexPath]] == NSOrderedSame)
                {
                    layoutAttributes.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                        self.collectionView.contentOffset.y + self.sizeForTitleView.height + self.sizeForContentView.height,
                                                        self.sizeForRealTimeComentsView.width,
                                                        self.sizeForRealTimeComentsView.height);
                }
                break;
            }
                
        }
    }];
    
    if (self.collectionView.contentOffset.y > self.secondCatchPoint)
    {
        
        UICollectionViewLayoutAttributes *dropDownHeaderLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                                          withIndexPath:[self contentViewIndexPath]];
//        CGFloat deltaCatchPointToTop = self.collectionView.contentOffset.y - self.secondCatchPoint;
//        CGFloat percentCompleted = (deltaCatchPointToTop / self.secondCatchPoint);
        dropDownHeaderLayoutAttributes.frame = CGRectMake(CGRectGetMinX(self.collectionView.frame),
                                                          self.collectionView.contentOffset.y,
                                                          CGRectGetWidth(self.collectionView.frame),
                                                          // Swap these implementations for header resizing
//                                                          fmaxf(self.secondCatchPoint, (1 - percentCompleted) * (1 + self.sizeForContentView.height)));
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
    if (self.collectionView.contentOffset.y < self.firstCatchPoint)
    {
        return VContentViewStateBelowFirstCatchPoint;
    }
    else if ((self.collectionView.contentOffset.y >= self.firstCatchPoint) && (self.collectionView.contentOffset.y < self.secondCatchPoint))
    {
        return VContentViewStateGreaterThanOrEqualToFirstCatchPointAndLessThanSecondCatchPoint;
    }
    else
    {
        return VContentViewStateGreaterThanOrEqualToSecondCatchPoint;
    }
}

- (void)updateInternalStateWithInitalLayoutAttributes:(NSArray *)initialLayoutAttributes
{
    if (CGSizeEqualToSize(self.sizeForTitleView, CGSizeZero))
    {
        UICollectionViewLayoutAttributes *layoutAttributesForCaptionView = [initialLayoutAttributes firstObject];
        self.sizeForTitleView = layoutAttributesForCaptionView.size;
    }
    
    if (CGSizeEqualToSize(self.sizeForContentView,CGSizeZero))
    {
        UICollectionViewLayoutAttributes *layoutAttributesForContentView = [initialLayoutAttributes objectAtIndex:1];
        self.sizeForContentView = layoutAttributesForContentView.size;
    }
    
    if (CGSizeEqualToSize(self.sizeForRealTimeComentsView, CGSizeZero))
    {
        UICollectionViewLayoutAttributes *layoutAttributesForRealTimeComments = [initialLayoutAttributes objectAtIndex:2];
        self.sizeForRealTimeComentsView = layoutAttributesForRealTimeComments.size;
        self.firstCatchPoint = CGRectGetHeight(layoutAttributesForRealTimeComments.frame);
        self.secondCatchPoint = CGRectGetHeight(layoutAttributesForRealTimeComments.frame) + self.sizeForTitleView.height;
    }
    
    // Calculate translation from top right
    if (self.contentViewMaxXTranslation == 0.0f)
    {
        CGFloat minimizedWidth = self.sizeForContentView.width * kVContentViewFloatingScalingFactor;
        self.contentViewMaxXTranslation = (self.sizeForContentView.width * 0.5f) - (minimizedWidth * 0.5f) - kVContentViewFlatingTrailingSpace;
    }
    if (self.contentViewMaxYTranslation == 0.0f)
    {
        CGFloat minimizedHeight = self.sizeForContentView.height * kVContentViewFloatingScalingFactor;
        self.contentViewMaxYTranslation = (-self.sizeForContentView.height * 0.5f) + (minimizedHeight * 0.5f) + kVConentViewFloatingTopSpace;
    }
}

- (NSIndexPath *)titleIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

- (NSIndexPath *)contentViewIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:1];
}

- (NSIndexPath *)realTimeCommentsIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:2];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForContentViewPastSecondCatchPointUpdateInitialLayoutAttributes:(UICollectionViewLayoutAttributes *)initialLayoutAttributes
{
    UICollectionViewLayoutAttributes *layoutAttributes = initialLayoutAttributes ?: [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[self contentViewIndexPath]];
    
    layoutAttributes.zIndex = kVContentViewFloatingZIndex;
    layoutAttributes.center = CGPointMake(self.sizeForContentView.width/2, self.sizeForContentView.width/2);
    layoutAttributes.size = self.sizeForContentView;
    CGFloat deltaCatchPointToTop = self.collectionView.contentOffset.y - self.secondCatchPoint;
    CGFloat percentCompleted = (deltaCatchPointToTop / (self.sizeForContentView.height - self.dropDownHeaderMiniumHeight));

    layoutAttributes.frame = CGRectMake(0,
                                        self.collectionView.contentOffset.y,
                                        self.sizeForContentView.width,
                                        self.sizeForContentView.height);

    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(fmaxf((1-percentCompleted), kVContentViewFloatingScalingFactor),
                                                                  fmaxf((1-percentCompleted), kVContentViewFloatingScalingFactor));

    CGFloat xTranslation = fminf(self.contentViewMaxXTranslation, self.contentViewMaxXTranslation * percentCompleted);
    CGFloat yTranslation = fmaxf(self.contentViewMaxYTranslation, self.contentViewMaxYTranslation * percentCompleted);

    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(xTranslation,
                                                                              yTranslation);
    CGAffineTransform combinedTransform = CGAffineTransformConcat(scaleTransform, translationTransform);

    layoutAttributes.transform = combinedTransform;
    
    return layoutAttributes;
}

@end
