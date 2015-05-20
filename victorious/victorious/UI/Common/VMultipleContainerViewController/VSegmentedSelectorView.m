//
//  VSegmentedSelectorView.m
//  victorious
//
//  Created by Josh Hinman on 12/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "VDependencyManager.h"
#import "VSegmentedSelectorView.h"
#import "UIView+AbsoluteFrame.h"

@interface VSegmentedSelectorView ()

@property (nonatomic, weak) UISegmentedControl *segmentedControl;

@end

@implementation VSegmentedSelectorView

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        self.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    }
    return self;
}

- (CGRect)frameOfButtonAtIndex:(NSUInteger)index
{
    NSUInteger numberOfSegments = self.segmentedControl.numberOfSegments;
    if ( index > numberOfSegments )
    {
        return CGRectZero;
    }
    
    CGRect segmentFrame = self.segmentedControl.frame;
    segmentFrame.origin = [self absoluteOriginOfView:self.segmentedControl];
    CGFloat segmentWidth = CGRectGetWidth(segmentFrame) / numberOfSegments;
    segmentFrame.size.width = segmentWidth;
    segmentFrame.origin.x += segmentWidth * index;
    return segmentFrame;
}

#pragma mark - Properties

- (void)setViewControllers:(NSArray *)viewControllers
{
    [super setViewControllers:viewControllers];
    [self makeSegmentedControlWithCurrentItems];
}

- (NSUInteger)activeViewControllerIndex
{
    return (NSUInteger)self.segmentedControl.selectedSegmentIndex;
}

- (void)setActiveViewControllerIndex:(NSUInteger)index
{
    [self.segmentedControl setSelectedSegmentIndex:(NSInteger)index];
}

#pragma mark -

- (void)makeSegmentedControlWithCurrentItems
{
    if ( self.segmentedControl != nil )
    {
        [self.segmentedControl removeFromSuperview];
    }
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[self.viewControllers v_map:^(UIViewController *viewController)
                                                                                      {
                                                                                          return viewController.navigationItem.title ?: @"";
                                                                                      }]];
    segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [segmentedControl setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:segmentedControl];
    self.segmentedControl = segmentedControl;
    
    if ( self.segmentedControl.numberOfSegments > 0 )
    {
        self.segmentedControl.selectedSegmentIndex = 0;
    }
    
    UIColor *foregroundColor = self.foregroundColor;
    UIColor *backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    
    segmentedControl.tintColor = foregroundColor;
    segmentedControl.backgroundColor = backgroundColor;
    segmentedControl.layer.cornerRadius = 4;
    segmentedControl.clipsToBounds = YES;
    
    [segmentedControl setTitleTextAttributes:@{
                                               NSFontAttributeName: [UIFont boldSystemFontOfSize:12],
                                               NSForegroundColorAttributeName: foregroundColor
                                               }
                                    forState:UIControlStateNormal];
    [segmentedControl setTitleTextAttributes:@{
                                               NSFontAttributeName: [UIFont boldSystemFontOfSize:12],
                                               NSForegroundColorAttributeName: backgroundColor
                                               }
                                    forState:UIControlStateSelected];
    
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[segmentedControl]-12-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(segmentedControl)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[segmentedControl]-10-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(segmentedControl)]];
}

#pragma mark - Actions

- (void)segmentedControlValueChanged:(UISegmentedControl *)sender
{
    if ( [self.delegate respondsToSelector:@selector(viewSelector:didSelectViewControllerAtIndex:)] )
    {
        [self.delegate viewSelector:self didSelectViewControllerAtIndex:self.segmentedControl.selectedSegmentIndex];
    }
}

@end
