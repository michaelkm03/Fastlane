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
@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation VNavigationController

#pragma mark - VHasManagedDependencies compliant initializer

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _navigationController = [[UINavigationController alloc] init];
        _navigationController.delegate = self;
    }
    return self;
}

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [self initWithNibName:nil bundle:nil];
    if (self)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

#pragma mark -

- (void)dealloc
{
    self.navigationController.delegate = nil;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    self.view = [[UIView alloc] init];
    
    [self addChildViewController:self.navigationController];
    UIView *navigationControllerView = self.navigationController.view;
    navigationControllerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:navigationControllerView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[navigationControllerView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(navigationControllerView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[navigationControllerView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(navigationControllerView)]];
    [self addNavigationBarStyles];
    [self.navigationController didMoveToParentViewController:self];
}

- (void)addNavigationBarStyles
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage v_imageWithColor:[self.dependencyManager colorForKey:VDependencyManagerAccentColorKey]]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage v_imageWithColor:[UIColor clearColor]];
    
    NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
    UIColor *navigationBarTitleTintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    UIFont *navigationBarTitleFont = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    
    if ( navigationBarTitleTintColor != nil )
    {
        titleAttributes[NSForegroundColorAttributeName] = navigationBarTitleTintColor;
        self.navigationController.navigationBar.tintColor = navigationBarTitleTintColor;
    }
    
    if ( navigationBarTitleFont != nil )
    {
        titleAttributes[NSFontAttributeName] = navigationBarTitleFont;
    }
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
}

#pragma mark - Status bar & Rotation

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.navigationController.topViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate
{
    return self.navigationController.topViewController.shouldAutorotate;
}

#pragma mark - UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    BOOL prefersNavigationBarHidden = [viewController v_prefersNavigationBarHidden];
    
    if ( !prefersNavigationBarHidden && self.navigationController.navigationBarHidden )
    {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
    else if ( prefersNavigationBarHidden && !self.navigationController.navigationBarHidden )
    {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
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
