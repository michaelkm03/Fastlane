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
                
                break;
            case VContentViewStateGreaterThanOrEqualToSecondCatchPoint:
                
                break;
        }
        
//        if (self.collectionView.contentOffset.y < self.catchPoint)
//        {
//            if ([layoutAttributes.indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
//            {
//                [self layoutAttributesForContentViewState:VContentViewStateFullSize
//                              withInitialLayoutAttributes:layoutAttributes];
//                hasLayoutAttributesForContentView = YES;
//            }
//            else if ([layoutAttributes.indexPath compare:[self realTimeCommentsIndexPath]] == NSOrderedSame)
//            {
//                layoutAttributes.frame = CGRectMake(CGRectGetMinX(layoutAttributes.frame),
//                                                    self.collectionView.contentOffset.y + self.sizeForContentView.height,
//                                                    self.sizeForRealTimeComentsView.width,
//                                                    self.sizeForRealTimeComentsView.height);
//            }
//        }
//        else
//        {
//            if ([layoutAttributes.indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
//            {
//                [self layoutAttributesForContentViewState:VContentViewStateShrinking
//                              withInitialLayoutAttributes:layoutAttributes];
//                hasLayoutAttributesForContentView = YES;
//            }
//            else if ([layoutAttributes.indexPath compare:[self realTimeCommentsIndexPath]] == NSOrderedSame)
//            {
//                {
//                    layoutAttributes.frame = CGRectMake(CGRectGetMinX(layoutAttributes.frame),
//                                                        self.collectionView.contentOffset.y + self.sizeForContentView.height,
//                                                        self.sizeForRealTimeComentsView.width,
//                                                        self.sizeForRealTimeComentsView.height);
//                }
//            }
//        }
    }];
    
//    if (self.collectionView.contentOffset.y > self.catchPoint)
//    {
//        
//        UICollectionViewLayoutAttributes *dropDownHeaderLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
//                                                                                                                                          withIndexPath:[self contentViewIndexPath]];
////        CGFloat deltaCatchPointToTop = self.collectionView.contentOffset.y - self.catchPoint;
////        CGFloat percentCompleted = (deltaCatchPointToTop / CGRectGetWidth(self.collectionView.bounds));
//        dropDownHeaderLayoutAttributes.frame = CGRectMake(CGRectGetMinX(self.collectionView.frame),
//                                                          self.collectionView.contentOffset.y,
//                                                          CGRectGetWidth(self.collectionView.frame),
//                                                          // Swap these implementations for header resizing
////                                                          fmaxf(self.catchPoint, (1 - percentCompleted) * (1 + CGRectGetHeight(layoutAttributesForContentView.frame)))
//                                                          self.dropDownHeaderMiniumHeight);
//        dropDownHeaderLayoutAttributes.zIndex = kVDropDownHeaderFloatingZIndex;
//        [attributes addObject:dropDownHeaderLayoutAttributes];
//    }
    
//    if (!hasLayoutAttributesForContentView)
//    {
//        [attributes addObject:[self layoutAttributesForContentViewState:VContentViewStateFloating
//                                            withInitialLayoutAttributes:nil]];
//    }
//    
    return attributes;
}

//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
//    {
//        return [self layoutAttributesForContentViewState:VContentViewStateFloating
//                             withInitialLayoutAttributes:nil];
//    }
//    return [super layoutAttributesForItemAtIndexPath:indexPath];
//}

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
    if (CGSizeEqualToSize(self.sizeForContentView,CGSizeZero))
    {
        UICollectionViewLayoutAttributes *layoutAttributesForContentView = [initialLayoutAttributes firstObject];
        self.sizeForContentView = layoutAttributesForContentView.size;
    }
    
    if (CGSizeEqualToSize(self.sizeForRealTimeComentsView, CGSizeZero))
    {
        UICollectionViewLayoutAttributes *layoutAttributesForRealTimeComments = [initialLayoutAttributes objectAtIndex:1];
        self.sizeForRealTimeComentsView = layoutAttributesForRealTimeComments.size;
        self.firstCatchPoint = CGRectGetHeight(layoutAttributesForRealTimeComments.frame);
        self.secondCatchPoint = CGRectGetHeight(layoutAttributesForRealTimeComments.frame) + CGRectGetHeight()
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

//- (UICollectionViewLayoutAttributes *)layoutAttributesForContentViewState:(VContentViewState)contentViewState
//                                              withInitialLayoutAttributes:(UICollectionViewLayoutAttributes *)initialLayoutAttributes
//{
//    UICollectionViewLayoutAttributes *layoutAttributes = initialLayoutAttributes;
//    
//    if (!initialLayoutAttributes)
//    {
//        NSIndexPath *contentViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//        layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:contentViewIndexPath];
//        layoutAttributes.center = CGPointMake(self.sizeForContentView.width/2, self.sizeForContentView.width/2);
//        layoutAttributes.size = self.sizeForContentView;
//    }
//    
//    layoutAttributes.zIndex = kVContentViewFloatingZIndex;
//    
//    switch (contentViewState) {
//        case VContentViewStateFullSize:
//            layoutAttributes.frame = CGRectMake(0,
//                                                self.collectionView.contentOffset.y,
//                                                self.sizeForContentView.width,
//                                                self.sizeForContentView.height);
//            break;
//        case VContentViewStateShrinking:
//        case VContentViewStateFloating:
//        {
//            CGFloat deltaCatchPointToTop = self.collectionView.contentOffset.y - self.catchPoint;
//            CGFloat percentCompleted = (deltaCatchPointToTop / (self.sizeForContentView.height - self.dropDownHeaderMiniumHeight));
//            
//            layoutAttributes.frame = CGRectMake(0,
//                                                self.collectionView.contentOffset.y,
//                                                self.sizeForContentView.width,
//                                                self.sizeForContentView.height);
//            
//            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(fmaxf((1-percentCompleted), kVContentViewFloatingScalingFactor),
//                                                                          fmaxf((1-percentCompleted), kVContentViewFloatingScalingFactor));
//            
//            CGFloat xTranslation = fminf(self.contentViewMaxXTranslation, self.contentViewMaxXTranslation * percentCompleted);
//            CGFloat yTranslation = fmaxf(self.contentViewMaxYTranslation, self.contentViewMaxYTranslation * percentCompleted);
//            
//            CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(xTranslation,
//                                                                                      yTranslation);
//            CGAffineTransform combinedTransform = CGAffineTransformConcat(scaleTransform, translationTransform);
//            
//            layoutAttributes.transform = combinedTransform;
//        }
//            break;
//    }
//    return layoutAttributes;
//}
//
@end
