//
//  VNavigationController.m
//  victorious
//
//  Created by Josh Hinman on 12/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VNavigationController.h"
#import "UIImage+VSolidColor.h"

#import <objc/runtime.h>

@interface VNavigationController () <UINavigationControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) UINavigationController *innerNavigationController;
@property (nonatomic, strong) UIView *supplementaryHeaderView;

@end

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
    }
    return self;
}

#pragma mark -

- (void)dealloc
{
    _innerNavigationController.delegate = nil;
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
    [self addNavigationBarStyles];
    [self.innerNavigationController didMoveToParentViewController:self];
}

- (void)addNavigationBarStyles
{
    [self.innerNavigationController.navigationBar setBackgroundImage:[UIImage v_imageWithColor:[self.dependencyManager colorForKey:VDependencyManagerAccentColorKey]]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    self.innerNavigationController.navigationBar.shadowImage = [UIImage v_imageWithColor:[UIColor clearColor]];
    
    NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
    UIColor *navigationBarTitleTintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    UIFont *navigationBarTitleFont = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    
    if ( navigationBarTitleTintColor != nil )
    {
        titleAttributes[NSForegroundColorAttributeName] = navigationBarTitleTintColor;
        self.innerNavigationController.navigationBar.tintColor = navigationBarTitleTintColor;
    }
    
    if ( navigationBarTitleFont != nil )
    {
        titleAttributes[NSFontAttributeName] = navigationBarTitleFont;
    }
    self.innerNavigationController.navigationBar.titleTextAttributes = titleAttributes;
}

#pragma mark - Status bar & Rotation

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return self.innerNavigationController.navigationBarHidden;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.innerNavigationController.topViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate
{
    return self.innerNavigationController.topViewController.shouldAutorotate;
}

#pragma mark - Supplementary Header Views

- (void)addSupplementaryHeaderView:(UIView *)supplementaryHeaderView withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)transition
{
    if ( [transition isInteractive] )
    {
        [transition notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context)
        {
            if ( ![context isCancelled] )
            {
                [self addSupplementaryHeaderView:supplementaryHeaderView];
                if ( [context isAnimated] )
                {
                    supplementaryHeaderView.alpha = 0;
                    [UIView animateWithDuration:[context transitionDuration] / [context completionVelocity]
                                          delay:0
                                        options:[context completionCurve] << 16
                                     animations:^(void)
                    {
                        supplementaryHeaderView.alpha = 1.0f;
                    }
                                     completion:nil];
                }
            }
        }];
    }
    else
    {
        [self addSupplementaryHeaderView:supplementaryHeaderView];
        if ( [transition isAnimated] )
        {
            supplementaryHeaderView.alpha = 0;
            [transition animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
            {
                supplementaryHeaderView.alpha = 1.0f;
            }
                                        completion:nil];
            
        }
    }
}

- (void)removeSupplementaryHeaderViewWithTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)transition
{
    if ( [transition isInteractive] )
    {
        [transition notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context)
        {
            if ( ![context isCancelled] )
            {
                if ( [context isAnimated] )
                {
                    [UIView animateWithDuration:[context transitionDuration] / [context completionVelocity]
                                          delay:0
                                        options:[context completionCurve] << 16
                                     animations:^(void)
                    {
                        self.supplementaryHeaderView.alpha = 0;
                    }
                                    completion:^(BOOL finished)
                    {
                        [self removeSupplementaryHeaderView];
                    }];
                }
                else
                {
                    [self removeSupplementaryHeaderView];
                }
            }
        }];
    }
    else
    {
        if ( [transition isAnimated] )
        {
            [transition animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
            {
                self.supplementaryHeaderView.alpha = 0;
            }
                                        completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
            {
                [self removeSupplementaryHeaderView];
            }];
        }
        else
        {
            [self removeSupplementaryHeaderView];
        }
    }
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
    
    [self.view addSubview:supplementaryHeaderView];
    supplementaryHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
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

#pragma mark - UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    BOOL prefersNavigationBarHidden = [viewController v_prefersNavigationBarHidden];
    
    if ( !prefersNavigationBarHidden && self.innerNavigationController.navigationBarHidden )
    {
        [self.innerNavigationController setNavigationBarHidden:NO animated:animated];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    else if ( prefersNavigationBarHidden && !self.innerNavigationController.navigationBarHidden )
    {
        [self.innerNavigationController setNavigationBarHidden:YES animated:animated];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
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
    
    if ( self.leftBarButtonItem != nil &&
         navigationController.viewControllers.count > 0 &&
         navigationController.viewControllers[0] == viewController &&
         viewController.navigationItem.leftBarButtonItems.count == 0 )
    {
        viewController.navigationItem.leftBarButtonItems = @[ self.leftBarButtonItem ];
    }
}

@end

#pragma mark -

@implementation UIViewController (VNavigationController)

- (BOOL)v_prefersNavigationBarHidden
{
    return NO;
}

- (void)v_scrollViewDidScroll:(UIScrollView *)scrollView
{
    // TODO
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
