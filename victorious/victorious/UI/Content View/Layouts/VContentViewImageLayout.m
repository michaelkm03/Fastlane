//
//  VContentViewImageLayout.m
//  victorious
//
//  Created by Michael Sena on 9/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewImageLayout.h"

@interface VContentViewImageLayout ()

@property (nonatomic, assign) CGFloat catchPoint;
@property (nonatomic, assign) CGFloat contentViewXTargetTranslation;
@property (nonatomic, assign) CGFloat contentViewYTargetTranslation;

// Publicly Readonly
@property (nonatomic, assign, readwrite) CGFloat dropDownHeaderMiniumHeight;
@property (nonatomic, assign, readwrite) CGSize sizeForContentView;
@property (nonatomic, assign, readwrite) CGSize sizeForRealTimeComentsView;

@end

static const CGFloat kVContentViewFloatingZIndex = 2.0f;
static const CGFloat kVDropDownHeaderFloatingZIndex = 1.0f;
static const CGFloat kVContentViewFloatingScalingFactor = 0.21f;
static const CGFloat kVContentViewMinimumHeaderHeight = 110.0f;
static const CGFloat kVContentViewFlatingTrailingSpace = 16.0f;

@implementation VContentViewImageLayout

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
    self.catchPoint = 0.0f;
    self.contentViewXTargetTranslation = 0.0f;
    self.contentViewYTargetTranslation = 0.0f;
    self.minimumInteritemSpacing = 0.0f;
    self.minimumLineSpacing = 0.0f;
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
    
    [self calculateSizesAndTranslationsIfNeededWithInitialAttributes:attributes];
    
    __block BOOL hasLayoutAttributesForContentView = NO;
    
    [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *layoutAttributes, NSUInteger idx, BOOL *stop)
     {
         if (self.collectionView.contentOffset.y <= self.catchPoint)
         {
             return;
         }
         
         if ([layoutAttributes.indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
         {
             hasLayoutAttributesForContentView = YES;
             [self layoutAttributesForContentViewPastSecondCatchPointUpdateInitialLayoutAttributes:layoutAttributes];
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

#pragma mark - Public Methods

- (NSArray *)desiredDecelerationLocations
{
    return
    @[
      @{
          VContentViewBaseLayoutDecelerationLocationDesiredContentOffset:[NSValue valueWithCGPoint:CGPointMake(0, 0)],
          VContentViewBaseLayoutDecelerationLocationThresholdBelow:@(0.0f),
          VContentViewBaseLayoutDecelerationLocationThresholdAbove:@(self.sizeForContentView.height * 0.25f)
          },
      @{
          VContentViewBaseLayoutDecelerationLocationDesiredContentOffset:[NSValue valueWithCGPoint:CGPointMake(0, self.sizeForContentView.height - self.dropDownHeaderMiniumHeight)],
          VContentViewBaseLayoutDecelerationLocationThresholdBelow:@(self.sizeForContentView.height * 0.75f),
          VContentViewBaseLayoutDecelerationLocationThresholdAbove:@(0.0f)
          }
      ];
}

#pragma mark - Internal Methods

- (void)calculateSizesAndTranslationsIfNeededWithInitialAttributes:(NSArray *)initialLayoutAttributes
{
    if (CGSizeEqualToSize(self.sizeForContentView, CGSizeZero))
    {
        UICollectionViewLayoutAttributes *layoutAttributesForContentView = [initialLayoutAttributes firstObject];
        self.sizeForContentView = layoutAttributesForContentView.size;
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
