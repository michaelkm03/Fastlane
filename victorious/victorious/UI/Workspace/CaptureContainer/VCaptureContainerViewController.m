//
//  VCaptureContainerViewController.m
//  victorious
//
//  Created by Michael Sena on 7/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCaptureContainerViewController.h"

// Views + Helpers
#import <OAStackView/OAStackView.h>
#import "UIView+Autolayout.h"

@interface VCaptureContainerViewController ()

@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet OAStackView *stackView;

@property (nonatomic, strong) UIViewController<VCaptureContainedViewController> *viewControllerToContain;

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

    for (VAlternateCaptureOption *alternateOption in self.alternateCaptureOptions)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [button setImage:alternateOption.icon forState:UIControlStateNormal];
        [button setTitle:alternateOption.title forState:UIControlStateNormal];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [self.stackView addArrangedSubview:button];
    }

    self.stackView.distribution = OAStackViewDistributionFillEqually;
    
    
    // Setup contained VC
    [self addChildViewController:self.viewControllerToContain];
    [self.containerView addSubview:self.viewControllerToContain.view];
    [self.containerView v_addFitToParentConstraintsToSubview:self.viewControllerToContain.view];
    [self.viewControllerToContain didMoveToParentViewController:self];
    
    self.navigationItem.titleView = [self.viewControllerToContain titleView];
}

#pragma mark - Public Methods

- (void)setContainedViewController:(UIViewController<VCaptureContainedViewController> *)viewController
{
    _viewControllerToContain = viewController;    
}

@end

#pragma mark - VAlternateCaptureOption

@interface VAlternateCaptureOption ()

@property (nonatomic, copy) VAlternateCaptureOption *selectionBlock;

@end

@implementation VAlternateCaptureOption

- (instancetype)initWithTitle:(NSString *)title
                         icon:(UIImage *)icon
            andSelectionBlock:(VImageVideoLibraryAlternateCaptureSelection)selectionBlock
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _icon = icon;
        _selectionBlock = [selectionBlock copy];
    }
    return self;
}

@end
