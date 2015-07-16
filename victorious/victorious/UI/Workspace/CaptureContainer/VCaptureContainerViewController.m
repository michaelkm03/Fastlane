//
//  VCaptureContainerViewController.m
//  victorious
//
//  Created by Michael Sena on 7/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCaptureContainerViewController.h"

// API
#import "VAlternateCaptureOption.h"

// Views + Helpers
#import <OAStackView/OAStackView.h>
#import "UIView+Autolayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface VCaptureContainerViewController ()

@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet OAStackView *stackView;
@property (nonatomic, strong) UIViewController *viewControllerToContain;
@property (nonatomic, strong) NSArray *buttonsForCaptureOptions;

@end

@implementation VCaptureContainerViewController

+ (instancetype)captureContainerWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboardForClass = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                                 bundle:bundleForClass];
    return [storyboardForClass instantiateInitialViewController];
}

#pragma mark -  View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableArray *buttonsForOptions = [[NSMutableArray alloc] init];
    // Create alternateOption buttons
    for (VAlternateCaptureOption *alternateOption in self.alternateCaptureOptions)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tintColor = [UIColor whiteColor];
        [button setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [button setImage:alternateOption.icon forState:UIControlStateNormal];
        [button setTitle:alternateOption.title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectedAlternateOption:) forControlEvents:UIControlEventTouchUpInside];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        // Move the image a bit to the left
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        [self.stackView addArrangedSubview:button];
        [buttonsForOptions addObject:button];
    }
    self.buttonsForCaptureOptions = [NSArray arrayWithArray:buttonsForOptions];
    self.stackView.distribution = OAStackViewDistributionFillEqually;
    
    NSAssert( self.viewControllerToContain != nil, @"The contained view controller must be set before this view is loaded using `setContainedViewController:`" );
    
    // Setup contained VC
    if (self.viewControllerToContain)
    {
        [self addChildViewController:self.viewControllerToContain];
        [self.containerView addSubview:self.viewControllerToContain.view];
        [self.containerView v_addFitToParentConstraintsToSubview:self.viewControllerToContain.view];
        [self.viewControllerToContain didMoveToParentViewController:self];
        
        // Forward navigationItem
        self.navigationItem.titleView = self.viewControllerToContain.navigationItem.titleView;
    }
}

#pragma mark - Public Methods

- (void)setContainedViewController:(UIViewController *)viewController
{
    _viewControllerToContain = viewController;
}

#pragma mark - Target/Action

- (void)selectedAlternateOption:(UIButton *)button
{
    NSUInteger indexOfButton = [self.buttonsForCaptureOptions indexOfObject:button];
    VAlternateCaptureOption *optionForButtonIndex = self.alternateCaptureOptions[indexOfButton];
    optionForButtonIndex.selectionBlock();
}

@end

NS_ASSUME_NONNULL_END
