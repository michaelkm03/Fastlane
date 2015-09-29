//
//  VCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationFlowController.h"

// Animator
#import "VCreationFlowAnimator.h"

// Dependencies
#import "VDependencyManager.h"
#import "VSolidColorBackground.h"
#import "VDependencyManager+VStatusBarStyle.h"

// Subclasses
#import "VAbstractImageVideoCreationFlowController.h"

static NSString * const kCloseButtonTextKey = @"closeText";
static NSString * const kBarBackgroundKey = @"navBarBackground";
static NSString * const kBarTintColorKey = @"barTintColor";
static NSString * const kStatusBaryStleKey = @"statusBarStyle";

@interface VCreationFlowController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VCreationFlowAnimator *animator;

@end

@implementation VCreationFlowController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [self init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        _animator = [[VCreationFlowAnimator alloc] init];
        _publishParameters = [[VPublishParameters alloc] init];
        self.transitioningDelegate = self;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VSolidColorBackground *background = [self.dependencyManager templateValueOfType:[VSolidColorBackground class]
                                                                             forKey:kBarBackgroundKey];
    self.navigationBar.barTintColor = background.backgroundColor;
    self.navigationBar.translucent = NO;
    self.navigationBar.tintColor = [self.dependencyManager colorForKey:kBarTintColorKey];
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.dependencyManager statusBarStyleForKey:kStatusBaryStleKey];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Public Methods

- (void)addCloseButtonToViewController:(UIViewController *)viewController
{
    NSString *closeText = [self.dependencyManager stringForKey:kCloseButtonTextKey] ?: NSLocalizedString(@"Cancel", nil);
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:closeText
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(selectedCancel:)];;
    viewController.navigationItem.leftBarButtonItem = closeButton;
}

- (BOOL)shouldShowPublishText
{
    if ([self.creationFlowDelegate respondsToSelector:@selector(shouldShowPublishScreenForFlowController)])
    {
        return [self.creationFlowDelegate shouldShowPublishScreenForFlowController];
    }
    return YES;
}

- (void)selectedCancel:(UIBarButtonItem *)cancelButton
{
    [self.view endEditing:YES];
    self.delegate = nil;
    self.interactivePopGestureRecognizer.delegate = nil;
    if ([self.creationFlowDelegate respondsToSelector:@selector(creationFlowControllerDidCancel:)])
    {
        [self.creationFlowDelegate creationFlowControllerDidCancel:self];
    }
    else
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    self.animator.presenting = YES;
    return self.animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.animator.presenting = NO;
    return self.animator;
}

@end
