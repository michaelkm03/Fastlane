//
//  VSelectorViewBase.m
//  victorious
//
//  Created by Josh Hinman on 12/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VSelectorViewBase.h"

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
    NSAssert(false, @"frameOfButtonAtIndex: must be overridden by subclasses of VSelectorViewBase");
    return CGRectZero;
}

- (CGRect)absoluteFrameOfView:(UIView *)view
{
    CGRect frame = view.frame;
    frame.origin = [self absoluteOriginOfView:view];
    return frame;
}

- (CGPoint)absoluteOriginOfView:(UIView *)view
{
    UIView *currentView = view;
    CGRect frame = currentView.frame;
    currentView = currentView.superview;
    while ( currentView != nil )
    {
        frame.origin.x += CGRectGetMinX(currentView.frame);
        frame.origin.y += CGRectGetMinY(currentView.frame);
        currentView = currentView.superview;
    }
    return frame.origin;
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
