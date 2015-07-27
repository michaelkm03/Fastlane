//
//  VSelectorViewBase.m
//  victorious
//
//  Created by Josh Hinman on 12/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VSelectorViewBase.h"
#import "VNumericalBadgeView.h"
#import "VProvidesNavigationMenuItemBadge.h"
#import "VBadgeResponder.h"

@implementation VSelectorViewBase

#pragma mark VHasManagedDependencies conforming initializer

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithFrame:CGRectZero];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        _foregroundColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    }
    return self;
}

- (CGRect)frameOfButtonAtIndex:(NSUInteger)index
{
    NSAssert(FALSE, @"subclasses of VSelectorViewBase must override frameOfButtonAtIndex");
    
    return CGRectZero;
}


- (void)layoutIfNeeded
{
    [self updateBadging];
}

- (void)updateBadging
{
    NSUInteger idx = 0;
    NSArray *arrayOfBadgeNumbers = self.arrayOfBadgeNumbers;
    for (UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:[VNumericalBadgeView class]])
        {
            NSUInteger badgeNumber = [[arrayOfBadgeNumbers objectAtIndex:idx] integerValue];
            [((VNumericalBadgeView *) subview) setBadgeNumber: badgeNumber];
            idx++;
        }
    }
}

- (NSArray *)arrayOfBadgeNumbers
{
    NSMutableArray *mutableResult = [[NSMutableArray alloc] init];
    for (UIViewController *viewController in self.viewControllers)
    {
        if ([viewController conformsToProtocol:@protocol(VProvidesNavigationMenuItemBadge)])
        {
            id<VProvidesNavigationMenuItemBadge> badgeProvider = (id<VProvidesNavigationMenuItemBadge>)viewController;
            NSInteger badgeNumber = [badgeProvider badgeNumber];
            NSNumber *badgeNumberObject = [NSNumber numberWithInteger:badgeNumber];
            [mutableResult addObject:badgeNumberObject];
        }
    }
    _arrayOfBadgeNumbers = [mutableResult copy];

    return _arrayOfBadgeNumbers;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = viewControllers;
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger index, BOOL *stop) {
  
        if ([viewController conformsToProtocol:@protocol(VProvidesNavigationMenuItemBadge)])
        {
            CGFloat xPos = ((index + 1) * (320.0f / self.viewControllers.count )) - 20.0f;
            VNumericalBadgeView *badgeView = [[VNumericalBadgeView alloc] initWithFrame:CGRectMake(xPos, 0, 20, 20)];
            badgeView.font = [self.dependencyManager fontForKey:VDependencyManagerHeading2FontKey];
            badgeView.layer.zPosition = 1000;
            
            id<VProvidesNavigationMenuItemBadge> badgeProvider = (id<VProvidesNavigationMenuItemBadge>)viewController;
            NSInteger badgeNumber = [badgeProvider badgeNumber];
            [badgeView setBadgeNumber:badgeNumber];
            [self addSubview:badgeView];
        }
    }];
}

#pragma mark - Properties

- (NSUInteger)activeViewControllerIndex
{
    // To be implemented by subclasses
    return NSNotFound;
}

- (void)setActiveViewControllerIndex:(NSUInteger)index
{
    // To be implemented by subclasses
}

@end
