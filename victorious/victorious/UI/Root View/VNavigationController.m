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

#pragma mark - UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    BOOL prefersNavigationBarHidden = [viewController v_prefersNavigationBarHidden];
    
    if ( !prefersNavigationBarHidden && self.innerNavigationController.navigationBarHidden )
    {
        [self.innerNavigationController setNavigationBarHidden:NO animated:animated];
    }
    else if ( prefersNavigationBarHidden && !self.innerNavigationController.navigationBarHidden )
    {
        [self.innerNavigationController setNavigationBarHidden:YES animated:animated];
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
