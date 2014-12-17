//
//  VBasicViewSelectorViewController.m
//  victorious
//
//  Created by Josh Hinman on 12/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "VBasicViewSelectorViewController.h"
#import "VDependencyManager.h"

@interface VBasicViewSelectorViewController ()

@property (nonatomic, weak) UISegmentedControl *segmentedControl;

@end

@implementation VBasicViewSelectorViewController

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    [self makeSegmentedControlWithCurrentItems];
}

#pragma mark - Properties

- (void)setViewControllers:(NSArray *)viewControllers
{
    [super setViewControllers:viewControllers];
    
    if ( [self isViewLoaded] )
    {
        [self makeSegmentedControlWithCurrentItems];
    }
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
        return viewController.title;
    }]];
    segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [segmentedControl setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    self.segmentedControl = segmentedControl;
    
    segmentedControl.tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    segmentedControl.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    segmentedControl.layer.cornerRadius = 4;
    segmentedControl.clipsToBounds = YES;
    
    [segmentedControl setDividerImage:[UIImage imageNamed:@"segmentedControlSeperatorLeftUnselected"]
                  forLeftSegmentState:UIControlStateNormal
                    rightSegmentState:UIControlStateSelected
                           barMetrics:UIBarMetricsDefault];
    [segmentedControl setDividerImage:[UIImage imageNamed:@"segmentedControlSeperatorRightUnselected"]
                  forLeftSegmentState:UIControlStateSelected
                    rightSegmentState:UIControlStateNormal
                           barMetrics:UIBarMetricsDefault];
    [segmentedControl setBackgroundImage:[UIImage imageNamed:@"segmentedControlBorderUnselected"]
                                forState:UIControlStateNormal
                              barMetrics:UIBarMetricsDefault];
    [segmentedControl setBackgroundImage:[UIImage imageNamed:@"segmentedControlBorderSelected"]
                                forState:UIControlStateSelected
                              barMetrics:UIBarMetricsDefault];
    [segmentedControl setTitleTextAttributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:12] }
                                    forState:UIControlStateNormal];
    UIColor *secondaryAccentColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    
    if ( secondaryAccentColor != nil )
    {
        [segmentedControl setTitleTextAttributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:12],
                                                    NSForegroundColorAttributeName: secondaryAccentColor }
                                        forState:UIControlStateSelected];
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[segmentedControl]-12-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(segmentedControl)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[segmentedControl]-10-|"
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
