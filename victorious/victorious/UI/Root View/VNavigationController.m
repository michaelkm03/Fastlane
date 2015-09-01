//
//  VNavigationController.m
//  victorious
//
//  Created by Josh Hinman on 12/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VDependencyManager+VTabScaffoldViewController.h"
#import "VNavigationController.h"
#import "VNavigationControllerScrollDelegate.h"
#import "UIImage+VSolidColor.h"
#import "UIViewController+VLayoutInsets.h"
#import  "UIColor+VBrightness.h"
#import "VTabScaffoldViewController.h"
#import "victorious-Swift.h"
#import "VExploreNavigationControllerAnimator.h"

#import <objc/runtime.h>

@interface UIViewController (VNavigationControllerPrivate)

- (void)v_setNavigationController:(VNavigationController *)navigationController;

@end

@interface VNavigationController () <UINavigationControllerDelegate>

@property (nonatomic, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, strong) UINavigationController *innerNavigationController;
@property (nonatomic, strong) UIView *supplementaryHeaderView;
@property (nonatomic, strong) UIView *statusBarBackgroundView;
@property (nonatomic, strong) UIViewController *displayedViewController; ///< The view controller currently on the top of the nav stack, as far as we know
@property (nonatomic) BOOL wantsStatusBarHidden;
@property (nonatomic) UIStatusBarStyle statusBarStyle;

@end

static const CGFloat kStatusBarHeight = 20.0f;

@implementation VNavigationController

#pragma mark - VHasManagedDependencies compliant initializer

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil)
    {
        _innerNavigationController = [[UINavigationController alloc] init];
        _innerNavigationController.delegate = self;
    }
    return self;
}

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [self initWithNibName:nil bundle:nil];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        UIColor *navigationBarTextColor = [[self.dependencyManager dependencyManagerForNavigationBar] colorForKey:VDependencyManagerMainTextColorKey];
        _statusBarStyle = [self statusBarStyleForColor:navigationBarTextColor];
    }
    return self;
}

#pragma mark -

- (void)dealloc
{
    _innerNavigationController.delegate = nil;
}

- (UIStatusBarStyle)statusBarStyleForColor:(UIColor *)color
{
    VColorLuminance luminance = [color v_colorLuminance];
    switch (luminance)
    {
        case VColorLuminanceBright:
            return UIStatusBarStyleLightContent;
            break;
            
        case VColorLuminanceDark:
            return UIStatusBarStyleDefault;
            break;
    }
}

#pragma mark - View Lifecycle

- (void)loadView
{
    self.view = [[UIView alloc] init];
    
    [self addChildViewController:self.innerNavigationController];
    UIView *innerNavigationControllerView = self.innerNavigationController.view;
    innerNavigationControllerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:innerNavigationControllerView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[innerNavigationControllerView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(innerNavigationControllerView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[innerNavigationControllerView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(innerNavigationControllerView)]];
    [self.dependencyManager applyStyleToNavigationBar:self.innerNavigationController.navigationBar];
    [self.innerNavigationController didMoveToParentViewController:self];

    UIView *statusBarBackgroundView = [[UIView alloc] init];
    statusBarBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    statusBarBackgroundView.userInteractionEnabled = NO;
    statusBarBackgroundView.backgroundColor = [[self.dependencyManager dependencyManagerForNavigationBar] colorForKey:VDependencyManagerBackgroundColorKey];
    [self.view addSubview:statusBarBackgroundView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[statusBarBackgroundView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(statusBarBackgroundView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[statusBarBackgroundView(==kStatusBarHeight)]"
                                                                      options:0
                                                                      metrics:@{ @"kStatusBarHeight": @(kStatusBarHeight) }
                                                                        views:NSDictionaryOfVariableBindings(statusBarBackgroundView)]];
    self.statusBarBackgroundView = statusBarBackgroundView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
}

- (void)viewDidLayoutSubviews
{
    if ( !UIApplication.sharedApplication.statusBarHidden &&
         CGAffineTransformIsIdentity(self.innerNavigationController.navigationBar.transform) &&
         CGRectGetMinY(self.innerNavigationController.navigationBar.frame) < CGRectGetMaxY([UIApplication.sharedApplication statusBarFrame]) )
    {
        CGRect frame = self.innerNavigationController.navigationBar.frame;
        frame.origin.y = CGRectGetMaxY([UIApplication.sharedApplication statusBarFrame]);
        self.innerNavigationController.navigationBar.frame = frame;
    }
    [self provideLayoutInsetsToViewController:self.innerNavigationController.topViewController];
}

#pragma mark - Status bar & Rotation

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.statusBarStyle;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden
{
    return self.wantsStatusBarHidden;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.innerNavigationController.topViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate
{
    return self.innerNavigationController.topViewController.shouldAutorotate;
}

#pragma mark -

- (void)transformNavigationBar:(CGAffineTransform)transform
{
    self.innerNavigationController.navigationBar.transform = transform;
    self.supplementaryHeaderView.transform = transform;
}

- (void)setNavigationBarHidden:(BOOL)hidden
{
    [self.innerNavigationController setNavigationBarHidden:hidden animated:NO];
    
    if ( hidden )
    {
        self.supplementaryHeaderView.hidden = YES;
    }
    else if ( self.supplementaryHeaderView != nil )
    {
        self.supplementaryHeaderView.hidden = NO;
        [self addSupplementaryHeaderView:self.supplementaryHeaderView];
    }
}

- (void)performCompanionAnimation:(void(^)(void))animation
        withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)transition
                           before:(void(^)(void))beforeBlock
                       completion:(void(^)(void))completion
{
    if ( [transition isInteractive] )
    {
        [transition notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context)
        {
            if ( ![context isCancelled] )
            {
                if ( beforeBlock != nil )
                {
                    beforeBlock();
                }
                if ( [context isAnimated] )
                {
                    [UIView animateWithDuration:[context transitionDuration] / [context completionVelocity]
                                          delay:0
                                        options:[context completionCurve] << 16
                                     animations:^(void)
                    {
                        if ( animation != nil )
                        {
                            animation();
                        }
                    }
                                     completion:^(BOOL finished)
                    {
                        if ( completion != nil )
                        {
                            completion();
                        }
                    }];
                }
                else
                {
                    if ( animation != nil )
                    {
                        animation();
                    }
                    if ( completion != nil )
                    {
                        completion();
                    }
                }
            }
        }];
    }
    else
    {
        if ( beforeBlock != nil )
        {
            beforeBlock();
        }
        if ( [transition isAnimated] )
        {
            [transition animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
            {
                if ( animation != nil )
                {
                    animation();
                }
            }
                                       completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
            {
                if (completion != nil )
                {
                    completion();
                }
            }];
        }
        else
        {
            if ( animation != nil )
            {
                animation();
            }
            if ( completion != nil )
            {
                completion();
            }
        }
    }
}

#pragma mark - Supplementary Header Views

- (void)addSupplementaryHeaderView:(UIView *)supplementaryHeaderView withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)transition
{
    [self performCompanionAnimation:^(void)
    {
        supplementaryHeaderView.alpha = 1.0f;
    }
          withTransitionCoordinator:transition
                             before:^(void)
    {
        [self addSupplementaryHeaderView:supplementaryHeaderView];
        supplementaryHeaderView.alpha = 0;
    }
                         completion:nil];
}

- (void)removeSupplementaryHeaderViewWithTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)transition
{
    [self performCompanionAnimation:^(void)
    {
        self.supplementaryHeaderView.alpha = 0;
    }
          withTransitionCoordinator:transition
                             before:nil
                         completion:^(void)
    {
        [self removeSupplementaryHeaderView];
    }];
}

- (void)removeSupplementaryHeaderView
{
    [self.supplementaryHeaderView removeFromSuperview];
    self.supplementaryHeaderView = nil;
}

- (void)addSupplementaryHeaderView:(UIView *)supplementaryHeaderView
{
    if ( self.supplementaryHeaderView != nil )
    {
        [self removeSupplementaryHeaderView];
    }
    
    [self.view insertSubview:supplementaryHeaderView belowSubview:self.statusBarBackgroundView];
    supplementaryHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    supplementaryHeaderView.transform = CGAffineTransformIdentity;
    supplementaryHeaderView.hidden = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.innerNavigationController.navigationBar
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:supplementaryHeaderView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[supplementaryHeaderView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(supplementaryHeaderView)]];
    self.supplementaryHeaderView = supplementaryHeaderView;
}

- (void)provideLayoutInsetsToViewController:(UIViewController *)viewController
{
    if ( [viewController v_prefersNavigationBarHidden] || ![self layoutWillExtendUnderNavigationBarForViewController:viewController] )
    {
        viewController.v_layoutInsets = UIEdgeInsetsZero;
        return;
    }
    
    CGFloat navigationBarHeight = CGRectGetHeight(self.innerNavigationController.navigationBar.frame) +
                                  CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    UIView *supplementaryView = viewController.navigationItem.v_supplementaryHeaderView;
    if ( supplementaryView != nil )
    {
        //The supplementary header exists, add its height and subtract the height of the shadow image that other content would normally be shown behind
        navigationBarHeight += CGRectGetHeight(supplementaryView.frame) -
                               self.innerNavigationController.navigationBar.shadowImage.size.height;
    }
    viewController.v_layoutInsets = UIEdgeInsetsMake(navigationBarHeight, 0, 0, 0);
}

- (BOOL)layoutWillExtendUnderNavigationBarForViewController:(UIViewController *)viewController
{
    return self.innerNavigationController.navigationBar.translucent || viewController.extendedLayoutIncludesOpaqueBars;
}

#pragma mark - UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self provideLayoutInsetsToViewController:viewController];
    [viewController v_setNavigationController:self];
    
    UIColor *statusBarBackgroundColor = [viewController statusBarBackgroundColor];
    statusBarBackgroundColor = statusBarBackgroundColor ?: [[self.dependencyManager dependencyManagerForNavigationBar] colorForKey:VDependencyManagerBackgroundColorKey];
    self.statusBarBackgroundView.backgroundColor = statusBarBackgroundColor;
    
    BOOL prefersNavigationBarHidden = [viewController v_prefersNavigationBarHidden];
    
    if ( prefersNavigationBarHidden != self.innerNavigationController.navigationBarHidden )
    {
        [self.innerNavigationController setNavigationBarHidden:prefersNavigationBarHidden animated:animated];
    }
    
    if ( viewController.toolbarItems.count > 0 )
    {
        [self.innerNavigationController setToolbarHidden:NO animated:animated];
    }
    
    [self updateSupplementaryHeaderViewForViewController:viewController];
    
    BOOL wantsStatusBarHidden = [viewController prefersStatusBarHidden];
    if ( wantsStatusBarHidden != self.wantsStatusBarHidden )
    {
        if ( [viewController.transitionCoordinator isInteractive] )
        {
            [viewController.transitionCoordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context)
            {
                if ( ![context isCancelled] )
                {
                    self.wantsStatusBarHidden = wantsStatusBarHidden;
                    [self setNeedsStatusBarAppearanceUpdate];
                }
            }];
        }
        else
        {
            self.wantsStatusBarHidden = wantsStatusBarHidden;
            [self setNeedsStatusBarAppearanceUpdate];
        }
        
        if ( !wantsStatusBarHidden )
        {
            if ( viewController.transitionCoordinator == nil )
            {
                self.statusBarBackgroundView.alpha = 1.0f;
                self.statusBarBackgroundView.hidden = NO;
            }
            else
            {
                [self performCompanionAnimation:^(void)
                 {
                     self.statusBarBackgroundView.alpha = 1.0f;
                 }
                      withTransitionCoordinator:viewController.transitionCoordinator
                                         before:^(void)
                 {
                     self.statusBarBackgroundView.hidden = NO;
                     self.statusBarBackgroundView.alpha = 0.0f;
                 }
                                     completion:nil];
            }
        }
        else
        {
            [self performCompanionAnimation:^(void)
             {
                 self.statusBarBackgroundView.alpha = 0;
             }
                  withTransitionCoordinator:viewController.transitionCoordinator
                                     before:nil
                                 completion:^(void)
             {
                 self.statusBarBackgroundView.hidden = YES;
             }];
        }
    }
    
    if ( self.leftBarButtonItem != nil &&
         navigationController.viewControllers.count > 0 &&
         navigationController.viewControllers[0] == viewController )
    {
        viewController.navigationItem.leftBarButtonItems = @[ self.leftBarButtonItem ];
    }
}

- (void)updateSupplementaryHeaderViewForViewController:(UIViewController *)viewController
{
    BOOL prefersNavigationBarHidden = [viewController v_prefersNavigationBarHidden];
    UIView *newSupplementaryHeaderView = viewController.navigationItem.v_supplementaryHeaderView;
    if ( self.supplementaryHeaderView != nil &&
        self.supplementaryHeaderView != newSupplementaryHeaderView )
    {
        if ( viewController.transitionCoordinator == nil )
        {
            [self removeSupplementaryHeaderView];
        }
        else
        {
            [self removeSupplementaryHeaderViewWithTransitionCoordinator:viewController.transitionCoordinator];
        }
    }
    
    if ( !prefersNavigationBarHidden && newSupplementaryHeaderView != nil )
    {
        if ( viewController.transitionCoordinator == nil )
        {
            [self addSupplementaryHeaderView:newSupplementaryHeaderView];
        }
        else
        {
            [self addSupplementaryHeaderView:newSupplementaryHeaderView withTransitionCoordinator:viewController.transitionCoordinator];
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ( viewController != self.displayedViewController )
    {
        [self.displayedViewController v_setNavigationController:nil];
        self.displayedViewController = viewController;
    }
}

#pragma mark - VTabMenuContainedViewControllerNavigation

- (void)reselected
{
    NSArray *poppedControllers = [self.innerNavigationController popToRootViewControllerAnimated:YES];
    
    if ( poppedControllers == nil || [poppedControllers count] == 0 )
    {
        id viewController = self.innerNavigationController.viewControllers.firstObject;
        if ( [viewController conformsToProtocol:@protocol(VTabMenuContainedViewControllerNavigation)] )
        {
            [((id<VTabMenuContainedViewControllerNavigation>)viewController) reselected];
        }
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if ([toVC isKindOfClass:[VUsersAndTagsSearchViewController class]] && [fromVC isKindOfClass:[VExploreViewController class]])
    {
        return [[VExploreNavigationControllerAnimator alloc] init];
    }
    
    if ([fromVC isKindOfClass:[VUsersAndTagsSearchViewController class]] && [toVC isKindOfClass:[VExploreViewController class]])
    {
        return [[VExploreNavigationControllerAnimator alloc] init];
    }

    return nil;
}

@end

#pragma mark -

static char kNavigationControllerKey;

@implementation UIViewController (VNavigationController)

- (BOOL)v_prefersNavigationBarHidden
{
    return NO;
}

- (UIColor *)statusBarBackgroundColor
{
    return nil;
}

- (VNavigationController *)v_navigationController
{
    VNavigationController *navigationController = (VNavigationController *)objc_getAssociatedObject(self, &kNavigationControllerKey);
    
    if ( navigationController == nil )
    {
        return [self.parentViewController v_navigationController];
    }
    return navigationController;
}

@end

#pragma mark -

@implementation UIViewController (VNavigationControllerPrivate)

- (void)v_setNavigationController:(VNavigationController *)navigationController
{
    objc_setAssociatedObject(self, &kNavigationControllerKey, navigationController, OBJC_ASSOCIATION_ASSIGN);
}

@end

#pragma mark -

static char kSupplementaryHeaderViewKey;

@implementation UINavigationItem (VNavigationController)

- (UIView *)v_supplementaryHeaderView
{
    return objc_getAssociatedObject(self, &kSupplementaryHeaderViewKey);
}

- (void)v_setSupplementaryHeaderView:(UIView *)supplementaryHeaderView
{
    objc_setAssociatedObject(self, &kSupplementaryHeaderViewKey, supplementaryHeaderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
