//
//  VActionBar.m
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VActionBar.h"
#import "UIView+Autolayout.h"

#if CGFLOAT_IS_DOUBLE
#define roundCGFloat(x) round(x)
#define floorCGFloat(x) floor(x)
#define ceilCGFloat(x) ceil(x)
#else
#define roundCGFloat(x) roundf(x)
#define floorCGFloat(x) floor(x)
#define ceilCGFloat(x) ceil(x)
#endif

static const CGFloat kDefaultActionItemWidth = 44.0f;

#pragma mark - VActionBar Implementation

@interface VActionBar ()

@end

@implementation VActionBar

#pragma mark - Flexible/Fixed Item Factories

+ (VActionBarFlexibleSpaceItem *)flexibleSpaceItem
{
    VActionBarFlexibleSpaceItem *flexibleSpaceItem = [[VActionBarFlexibleSpaceItem alloc] initWithFrame:CGRectZero];
    flexibleSpaceItem.translatesAutoresizingMaskIntoConstraints = NO;
    return flexibleSpaceItem;
}

+ (VActionBarFixedWidthItem *)fixedWidthItemWithWidth:(CGFloat)width
{
    VActionBarFixedWidthItem *fixedWidthItem = [[VActionBarFixedWidthItem alloc] initWithFrame:CGRectZero];
    fixedWidthItem.width = width;
    fixedWidthItem.translatesAutoresizingMaskIntoConstraints = NO;
    [fixedWidthItem v_addWidthConstraint:width];
    return fixedWidthItem;
}

#pragma mark - Public Methods

- (void)setActionItems:(NSArray *)actionItems
{
    [actionItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if (![obj isKindOfClass:[UIView class]])
        {
            NSAssert(false, @"All actionItems must be a UIView subclass!");
        }
    }];
    
    [_actionItems enumerateObjectsUsingBlock:^(UIView *existingAcitonItem, NSUInteger idx, BOOL *stop)
     {
         [existingAcitonItem removeFromSuperview];
     }];
    
    _actionItems = [actionItems copy];
    
    [_actionItems enumerateObjectsUsingBlock:^(UIView *actionItem, NSUInteger idx, BOOL *stop)
     {
         [self addSubview:actionItem];
     }];
    
    [self applyHorizontalConstraintsToItems:_actionItems];
    [self applyVerticalConstraintsToItems:_actionItems];
}

#pragma mark - Private Methods

- (void)applyHorizontalConstraintsToItems:(NSArray *)items
{
    [self addLeadingTrailingContraintsForFirstAndLastItems:items];
    [self applyLeadingTrailingConstraintsExclusingFirstObject:items];
    [self addDefaultWidthConstraintsForRequiredItems:items];
    
    CGFloat totalFlexSpace = [self remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:items
                                                                                      fromWidth:CGRectGetWidth(self.bounds)];
    CGFloat flexibleItemWidth = [self flexibleSpaceWidthWithFlexibleItemCount:[self flexibleItemCountFromItems:items]
                                                            widthToDistribute:totalFlexSpace];
    [self applyFlexibleItemWith:flexibleItemWidth
         toFlexibleItemsInItems:items];
}

- (void)applyVerticalConstraintsToItems:(NSArray *)items
{
    [items enumerateObjectsUsingBlock:^(UIView *actionItem, NSUInteger idx, BOOL *stop)
    {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:actionItem
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    }];
}

- (void)addDefaultWidthConstraintsForRequiredItems:(NSArray *)items
{
    [items enumerateObjectsUsingBlock:^(UIView *actionItem, NSUInteger idx, BOOL *stop)
    {
        // Flexible space items are ignored
        if ([actionItem isKindOfClass:[VActionBarFlexibleSpaceItem class]])
        {
            return;
        }
        
        if ([actionItem isKindOfClass:[VActionBarFixedWidthItem class]])
        {
            return;
        }
        
        NSLayoutConstraint *internalWidthConstraint = [actionItem v_internalWidthConstraint];
        if (internalWidthConstraint != nil)
        {
            return;
        }
        
        if (actionItem.intrinsicContentSize.width != UIViewNoIntrinsicMetric)
        {
            return;
        }
        
        [actionItem v_addWidthConstraint:kDefaultActionItemWidth];
    }];
}

- (void)addLeadingTrailingContraintsForFirstAndLastItems:(NSArray *)items
{
    // Add leading for first item
    NSLayoutConstraint *leadingFirstItem = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:[items firstObject]
                                                                        attribute:NSLayoutAttributeLeft
                                                                       multiplier:1.0f
                                                                         constant:0.0f];
    [self addConstraint:leadingFirstItem];
    
    // Add trailing for last item
    NSLayoutConstraint *trailingLastItem = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeRight
                                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                           toItem:[items lastObject]
                                                                        attribute:NSLayoutAttributeRight
                                                                       multiplier:1.0f
                                                                         constant:0.0f];
    trailingLastItem.priority = UILayoutPriorityDefaultLow;
    [self addConstraint:trailingLastItem];
}

- (void)applyLeadingTrailingConstraintsExclusingFirstObject:(NSArray *)items
{
    // Hookup Leading/Trailing Constraints
    [items enumerateObjectsUsingBlock:^(UIView *actionItem, NSUInteger idx, BOOL *stop)
     {
         // First item leading is already aligned to self
         if (actionItem == [items firstObject])
         {
             return;
         }
         [self addConstraint:[NSLayoutConstraint constraintWithItem:actionItem
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:[items objectAtIndex:idx-1]
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0f
                                                           constant:0.0f]];
     }];
}

- (CGFloat)remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:(NSArray *)items
                                                              fromWidth:(CGFloat)width
{
    __block CGFloat remainingSpace = width;
    
    [items enumerateObjectsUsingBlock:^(UIView *actionItem, NSUInteger idx, BOOL *stop)
    {
        // Flexible space items are ignored
        if ([actionItem isKindOfClass:[VActionBarFlexibleSpaceItem class]])
        {
            return;
        }
        
        if ([actionItem isKindOfClass:[VActionBarFixedWidthItem class]])
        {
            VActionBarFixedWidthItem *fixedWidthItem = (VActionBarFixedWidthItem *)actionItem;
            remainingSpace = remainingSpace - fixedWidthItem.width;
            return;
        }
        
        NSLayoutConstraint *internalWidthConstraint = [actionItem v_internalWidthConstraint];
        if (internalWidthConstraint != nil)
        {
            remainingSpace = remainingSpace - internalWidthConstraint.constant;
            return;
        }
        
        if (actionItem.intrinsicContentSize.width != UIViewNoIntrinsicMetric)
        {
            remainingSpace = remainingSpace - actionItem.intrinsicContentSize.width;
            return;
        }
        
        remainingSpace = remainingSpace - kDefaultActionItemWidth;
    }];
    
    return remainingSpace;
}

- (void)applyFlexibleItemWith:(CGFloat)flexibleItemWidth
       toFlexibleItemsInItems:(NSArray *)items
{
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj isKindOfClass:[VActionBarFlexibleSpaceItem class]])
        {
            VActionBarFlexibleSpaceItem *flexibleSpaceItem = (VActionBarFlexibleSpaceItem *)obj;
            [flexibleSpaceItem removeConstraints:[flexibleSpaceItem constraints]];
            [flexibleSpaceItem v_addWidthConstraint:flexibleItemWidth];
        }
    }];
}

- (NSInteger)flexibleItemCountFromItems:(NSArray *)items
{
    __block NSInteger numberOfFlexibleItems = 0;
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[VActionBarFlexibleSpaceItem class]])
         {
             numberOfFlexibleItems++;
         }
     }];
    return numberOfFlexibleItems;
}

- (CGFloat)flexibleSpaceWidthWithFlexibleItemCount:(NSInteger)numberOfFlexibleItems
                                 widthToDistribute:(CGFloat)width
{
    CGFloat flexibleSpaceWidth = (CGFloat)(width / numberOfFlexibleItems);
    return floorCGFloat(flexibleSpaceWidth);
}

@end

#pragma mark - VActionBarFlexibleSpaceItem

@implementation VActionBarFlexibleSpaceItem

@end

#pragma mark - VActionBarFixedWidthItem

@implementation VActionBarFixedWidthItem

@end
