//
//  VNavigationController.m
//  victorious
//
//  Created by Josh Hinman on 12/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VDependencyManager+NavigationBar.h"
#import "VNavigationController.h"
#import "VNavigationControllerScrollDelegate.h"
#import "UIImage+VSolidColor.h"
#import "UIViewController+VLayoutInsets.h"
#import  "UIColor+VBrightness.h"
#import "victorious-Swift.h"

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
@property (nonatomic, strong) NSMutableSet *containedViewControllers; ///< View controllers that are contained within this view controller's nav stack, as far as we know
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
        _containedViewControllers = [[NSMutableSet alloc] init];
    }
    return self;
}

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [self initWithNibName:nil bundle:nil];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        _statusBarStyle = [self defaultStatusBarStyle];
    }
    return self;
}

#pragma mark -

- (void)dealloc
{
    _innerNavigationController.delegate = nil;
    for (UIViewController *containedViewController in [_containedViewControllers copy])
    {
        [containedViewController v_setNavigationController:nil];
    }
}

- (UIStatusBarStyle)defaultStatusBarStyle
{
    VDependencyManager *navBarDependencyManager = [self.dependencyManager dependencyManagerForNavigationBar];
    return [StatusBarUtilities statusBarStyleWithColor:[navBarDependencyManager colorForKey:VDependencyManagerMainTextColorKey]];
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

    if (!self.dependencyManager.festivalIsEnabled)
    {
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
}

- (void)viewDidLayoutSubviews
{
    if (
        !self.dependencyManager.festivalIsEnabled &&
        !UIApplication.sharedApplication.statusBarHidden &&
        CGAffineTransformIsIdentity(self.innerNavigationController.navigationBar.transform) &&
        CGRectGetMinY(self.innerNavigationController.navigationBar.frame) < CGRectGetMaxY([UIApplication.sharedApplication statusBarFrame]))
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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
            BOOL successfulAnimation = [transition animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
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
            
            if (!successfulAnimation && animation != nil)
            {
                animation();
            }
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
    supplementaryHeaderView.alpha = 1;
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
    
    UIStatusBarStyle preferredStatusBarStyle = prefersNavigationBarHidden ? [viewController preferredStatusBarStyle] : [self defaultStatusBarStyle];
    
    if ( wantsStatusBarHidden != self.wantsStatusBarHidden|| preferredStatusBarStyle != self.statusBarStyle )
    {
        if ( [viewController.transitionCoordinator isInteractive] )
        {
            [viewController.transitionCoordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context)
            {
                if ( ![context isCancelled] )
                {
                    self.wantsStatusBarHidden = wantsStatusBarHidden;
                    self.statusBarStyle = preferredStatusBarStyle;
                    [self setNeedsStatusBarAppearanceUpdate];
                }
            }];
        }
        else
        {
            self.wantsStatusBarHidden = wantsStatusBarHidden;
            self.statusBarStyle = preferredStatusBarStyle;
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
    
    [self.delegate navigationController:self willShowViewController:viewController animated:animated];
}

- (void)updateSupplementaryHeaderViewForViewController:(UIViewController *)viewController
{
    BOOL prefersNavigationBarHidden = [viewController v_prefersNavigationBarHidden];
    
    UIView *newSupplementaryHeaderView = viewController.navigationItem.v_supplementaryHeaderView;
    
    // Update the supplementaryHeader only when the newValue is different
    if ( self.supplementaryHeaderView != newSupplementaryHeaderView)
    {
        // We are being told to remove the supplementaryHeaderView
        if ( newSupplementaryHeaderView == nil )
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
        // Updating with a valid newSupplementaryHeaderView
        else if ( !prefersNavigationBarHidden )
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
    // Otherwise just update the hidden status
    else
    {
        [self setNavigationBarHidden:prefersNavigationBarHidden];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ( viewController != self.displayedViewController )
    {
        [self.displayedViewController v_setNavigationController:nil];
        self.displayedViewController = viewController;
    }
    
    [self.delegate navigationController:self didShowViewController:viewController animated:animated];
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
    VNavigationController *previousNavigationController = [self v_navigationController];
    
    if ( previousNavigationController == navigationController )
    {
        return;
    }
    
    [previousNavigationController.containedViewControllers removeObject:self];
    objc_setAssociatedObject(self, &kNavigationControllerKey, navigationController, OBJC_ASSOCIATION_ASSIGN);
    [navigationController.containedViewControllers addObject:self];
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
