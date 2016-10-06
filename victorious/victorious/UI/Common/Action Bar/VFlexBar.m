//
//  VFlexBar.m
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFlexBar.h"
#import "VActionBarFixedWidthItem.h"
#import "VActionBarFlexibleWidth.h"

#import "NSArray+VMap.h"

// Layout Helpers
#import "UIView+Autolayout.h"

#import "victorious-Swift.h"

static const CGFloat kDefaultActionItemWidth = 44.0f;

static NSString *kConstraintIdentifier = @"VActionBarConstraints";

@implementation VFlexBar

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // We need to update flex items when our bounds changes
    [self updateFlexibleWidthConstraintsToItems:self.actionItems];
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
    [self updateFlexibleWidthConstraintsToItems:items];
}

- (void)updateFlexibleWidthConstraintsToItems:(NSArray *)items
{
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
        if ([self isFlexibleActionItem:actionItem])
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

        CGSize systemSize = [actionItem systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
        if (systemSize.width != 0.0f)
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
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:[items lastObject]
                                                                        attribute:NSLayoutAttributeRight
                                                                       multiplier:1.0f
                                                                         constant:0.0f];
    trailingLastItem.priority = UILayoutPriorityRequired;

    [self addConstraint:trailingLastItem];
}

- (void)applyLeadingTrailingConstraintsExclusingFirstObject:(NSArray *)items
{
    // Hookup Leading/Trailing Constraints
    NSMutableArray *constraintsToAdd = [[NSMutableArray alloc] init];
    id firstItem = [items firstObject];
    __block id previousItem = firstItem;
    [items enumerateObjectsUsingBlock:^(UIView *actionItem, NSUInteger idx, BOOL *stop)
     {
         // First item leading is already aligned to self
         if (actionItem == firstItem)
         {
             return;
         }
         [constraintsToAdd addObject:[NSLayoutConstraint constraintWithItem:actionItem
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:previousItem
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
         previousItem = actionItem;
     }];
    [self addConstraints:constraintsToAdd];
}

- (CGFloat)remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:(NSArray *)items
                                                              fromWidth:(CGFloat)width
{
    __block CGFloat remainingSpace = width;
    
    [items enumerateObjectsUsingBlock:^(UIView *actionItem, NSUInteger idx, BOOL *stop)
    {
        // Flexible space items are ignored
        if ([self isFlexibleActionItem:actionItem])
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
        
        CGSize layoutSize = [actionItem systemLayoutSizeFittingSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        if (layoutSize.width != 0.0f)
        {
            remainingSpace = remainingSpace - layoutSize.width;
            return;
        }
        
        remainingSpace = remainingSpace - kDefaultActionItemWidth;
    }];
    
    return remainingSpace > 0 ? remainingSpace : 0.0f;
}

- (void)applyFlexibleItemWith:(CGFloat)flexibleItemWidth
       toFlexibleItemsInItems:(NSArray *)items
{
    if (flexibleItemWidth == 0.0f)
    {
        // Zero width flex, do nothing.
        return;
    }
    
    [items enumerateObjectsUsingBlock:^(UIView *actionItem, NSUInteger idx, BOOL *stop)
    {
        if ([self isFlexibleActionItem:actionItem])
        {
            NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(NSLayoutConstraint *constraint, NSDictionary *bindings)
                                            {
                                                if ([constraint.identifier isEqualToString:kConstraintIdentifier])
                                                {
                                                    return YES;
                                                }
                                                return NO;
                                            }];
            NSArray *filteredConstraints = [[actionItem constraints] filteredArrayUsingPredicate:filterPredicate];
            [actionItem removeConstraints:filteredConstraints];
            [actionItem setNeedsUpdateConstraints];
            NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:actionItem
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.0f
                                                                                constant:flexibleItemWidth];
            widthConstraint.identifier = kConstraintIdentifier;
            widthConstraint.priority = UILayoutPriorityDefaultHigh;
            [actionItem addConstraint:widthConstraint];
        }
    }];
}

- (NSInteger)flexibleItemCountFromItems:(NSArray *)items
{
    __block NSInteger numberOfFlexibleItems = 0;
    [items enumerateObjectsUsingBlock:^(UIView *actionItem, NSUInteger idx, BOOL *stop)
     {
         if ([self isFlexibleActionItem:actionItem])
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
    return VFLOOR(flexibleSpaceWidth);
}

- (BOOL)isFlexibleActionItem:(UIView *)actionItem
{
    if ([actionItem conformsToProtocol:@protocol(VActionBarFlexibleWidth)])
    {
        id <VActionBarFlexibleWidth> flexibleWidthConformer = (id <VActionBarFlexibleWidth>)actionItem;
        return [flexibleWidthConformer canApplyFlexibleWidth];
    }
    if ([actionItem isKindOfClass:[ActionBarFlexibleSpaceItem class]])
    {
        return YES;
    }
    return NO;
}

@end
