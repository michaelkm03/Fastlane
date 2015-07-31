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

static CGFloat kPaddingForNotifications = 10.0f;
static CGFloat kDiameterForNotifications = 20.0f;

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
    NSAssert(NO, @"subclasses of VSelectorViewBase must override frameOfButtonAtIndex");
    
    return CGRectZero;
}

- (void)layoutSubviews
{
    [self updateBadging];
}

- (void)updateBadging
{
    // subclasses can override this method
    return;
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
