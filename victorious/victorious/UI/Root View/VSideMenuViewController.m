//
//  VSideMenuViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VMenuController.h"
#import "VMultipleStreamViewController.h"
#import "VNavigationDestination.h"
#import "VSettingManager.h"
#import "VSideMenuViewController.h"
#import "VStreamCollectionViewController.h"
#import "VThemeManager.h"
#import "UIImage+ImageEffects.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "UIViewController+VSideMenuViewController.h"

// Keys for managed dependencies
static NSString * const kMenuKey = @"menu";

@interface VSideMenuViewController () <UINavigationControllerDelegate>

@property (strong, readwrite, nonatomic) VDependencyManager *dependencyManager;
@property (strong, readwrite, nonatomic) UIImageView *backgroundImageView;
@property (assign, readwrite, nonatomic) BOOL visible;
@property (assign, readwrite, nonatomic) CGPoint originalPoint;
@property (strong, readwrite, nonatomic) UIButton *contentButton;

@end

@implementation VSideMenuViewController

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _animationDuration = 0.35f;
    _scaleContentView      = YES;
    _contentViewScaleValue = 0.7f;
    
    _scaleBackgroundImageView = YES;
    
    _parallaxEnabled = YES;
    _parallaxMenuMinimumRelativeValue = @(-15);
    _parallaxMenuMaximumRelativeValue = @(15);
    
    _parallaxContentMinimumRelativeValue = @(-25);
    _parallaxContentMaximumRelativeValue = @(25);
    
    _bouncesHorizontally = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerDidSelectRow:) name:VMenuControllerDidSelectRowNotification object:nil];
}

#pragma mark VHasManagedDependencies conforming initializer

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VSideMenuViewController *sideMenuViewController = (VSideMenuViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:NSStringFromClass([VSideMenuViewController class])];
    sideMenuViewController.dependencyManager = dependencyManager;
    return sideMenuViewController;
}

#pragma mark -

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.backgroundImage = [[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice]
                            applyBlurWithRadius:25 tintColor:[UIColor colorWithWhite:0.0 alpha:0.75] saturationDeltaFactor:1.8 maskImage:nil];
    
    
    self.menuViewController = [self.dependencyManager viewControllerForKey:kMenuKey];
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    NSAssert([self.contentViewController isKindOfClass:[UINavigationController class]], @"contentController should be a UINavigationController");
    self.contentViewController.delegate = self;
    
    if (!_contentViewInLandscapeOffsetCenterX)
    {
        _contentViewInLandscapeOffsetCenterX = CGRectGetHeight(self.view.frame) + 30.f;
    }
    
    if (!_contentViewInPortraitOffsetCenterX)
    {
        _contentViewInPortraitOffsetCenterX  = CGRectGetWidth(self.view.frame) + 30.f;
    }
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.image = self.backgroundImage;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView;
    });
    self.contentButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectNull];
        [button addTarget:self action:@selector(hideMenuViewController) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    [self.view addSubview:self.backgroundImageView];
    [self displayController:self.menuViewController frame:self.view.bounds];
    [self displayController:self.contentViewController frame:self.view.bounds];
    self.menuViewController.view.alpha = 0;
    if (self.scaleBackgroundImageView)
    {
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    }
    
    [self addMenuViewControllerMotionEffects];

    UIViewController *initialVC = [self.dependencyManager viewControllerForKey:VDependencyManagerInitialViewControllerKey];
    if (initialVC != nil)
    {
        [self transitionToNavStack:@[initialVC]];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (_contentViewController)
    {
        return _contentViewController.supportedInterfaceOrientations;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)shouldAutorotate
{
    return [_contentViewController shouldAutorotate];
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    if (self.visible)
    {
        return nil;
    }
    else
    {
        return _contentViewController;
    }
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    if (self.visible)
    {
        return nil;
    }
    else
    {
        return _contentViewController;
    }
}

#pragma mark -

- (void)presentMenuViewController
{
    self.menuViewController.view.transform = CGAffineTransformIdentity;
    if (self.scaleBackgroundImageView)
    {
        self.backgroundImageView.transform = CGAffineTransformIdentity;
        self.backgroundImageView.frame = self.view.bounds;
    }
    self.menuViewController.view.frame = self.view.bounds;
    self.menuViewController.view.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    self.menuViewController.view.alpha = 0;
    if (self.scaleBackgroundImageView)
    {
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    }
    
    [self showMenuViewController];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectMainMenu];
}

- (void)showMenuViewController
{
    [self.view.window endEditing:YES];
    [self addContentButton];
    
    self.visible = YES;
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (self.scaleContentView)
        {
            self.contentViewController.view.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        }
        
        self.contentViewController.view.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? self.contentViewInLandscapeOffsetCenterX : self.contentViewInPortraitOffsetCenterX), self.contentViewController.view.center.y);
        
        self.menuViewController.view.alpha = 1.0f;
        self.menuViewController.view.transform = CGAffineTransformIdentity;
        if (self.scaleBackgroundImageView)
        {
            self.backgroundImageView.transform = CGAffineTransformIdentity;
        }
    }
    completion:^(BOOL finished)
    {
        [self addContentViewControllerMotionEffects];
    }];
    
    [self updateStatusBar];
}

- (void)hideMenuViewController
{
    [self.contentButton removeFromSuperview];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [UIView animateWithDuration:self.animationDuration animations:^{
        self.contentViewController.view.transform = CGAffineTransformIdentity;
        self.contentViewController.view.frame = self.view.bounds;
        self.menuViewController.view.alpha = 0;
        if (self.scaleBackgroundImageView)
        {
            self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
        }

        if (self.parallaxEnabled)
        {
            for (UIMotionEffect *effect in self.contentViewController.view.motionEffects)
            {
               [self.contentViewController.view removeMotionEffect:effect];
            }
        }
        self.visible = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    completion:^(BOOL finished)
    {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

- (void)addContentButton
{
    if (self.contentButton.superview)
    {
        return;
    }
    
    self.contentButton.autoresizingMask = UIViewAutoresizingNone;
    self.contentButton.frame = self.contentViewController.view.bounds;
    self.contentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentViewController.view addSubview:self.contentButton];
}

- (void)navigateToViewController:(id)destination
{
    void (^goTo)(UIViewController *) = ^(UIViewController *vc)
    {
        NSAssert([vc isKindOfClass:[UIViewController class]], @"non-UIViewController specified as destination for navigation");
        [self transitionToNavStack:@[vc]];
    };
    
    if ([destination respondsToSelector:@selector(shouldNavigateWithAlternateDestination:)])
    {
        UIViewController *alternateDestination = nil;
        if ([destination shouldNavigateWithAlternateDestination:&alternateDestination])
        {
            if (alternateDestination == nil)
            {
                goTo(destination);
            }
            else
            {
                [self navigateToViewController:alternateDestination];
            }
        }
    }
    else
    {
        goTo(destination);
    }
}

- (void)transitionToNavStack:(NSArray *)navStack
{
    //Dismiss any modals in the stack or they will cover the new VC
    for (UIViewController *vc in self.contentViewController.viewControllers)
    {
        [vc dismissViewControllerAnimated:NO completion:nil];
    }
    
    self.contentViewController.viewControllers = navStack;
}

#pragma mark - Motion effects

- (void)addMenuViewControllerMotionEffects
{
    if (self.parallaxEnabled)
    {
       for (UIMotionEffect *effect in self.menuViewController.view.motionEffects)
           [self.menuViewController.view removeMotionEffect:effect];

       UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
       interpolationHorizontal.minimumRelativeValue = self.parallaxMenuMinimumRelativeValue;
       interpolationHorizontal.maximumRelativeValue = self.parallaxMenuMaximumRelativeValue;
       
       UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
       interpolationVertical.minimumRelativeValue = self.parallaxMenuMinimumRelativeValue;
       interpolationVertical.maximumRelativeValue = self.parallaxMenuMaximumRelativeValue;
       
       [self.menuViewController.view addMotionEffect:interpolationHorizontal];
       [self.menuViewController.view addMotionEffect:interpolationVertical];
    }
}

- (void)addContentViewControllerMotionEffects
{
    if (self.parallaxEnabled)
    {
        for (UIMotionEffect *effect in self.contentViewController.view.motionEffects)
        {
            [self.contentViewController.view removeMotionEffect:effect];
        }

        [UIView animateWithDuration:0.2 animations:^{
            UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            interpolationHorizontal.minimumRelativeValue = self.parallaxContentMinimumRelativeValue;
            interpolationHorizontal.maximumRelativeValue = self.parallaxContentMaximumRelativeValue;
            
            UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            interpolationVertical.minimumRelativeValue = self.parallaxContentMinimumRelativeValue;
            interpolationVertical.maximumRelativeValue = self.parallaxContentMaximumRelativeValue;
            
            [self.contentViewController.view addMotionEffect:interpolationHorizontal];
            [self.contentViewController.view addMotionEffect:interpolationVertical];
        }];
    }
}

#pragma mark - Setters

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    if (self.backgroundImageView)
    {
        self.backgroundImageView.image = backgroundImage;
    }
}

- (void)setContentViewController:(UINavigationController *)contentViewController
{
    NSAssert(!_contentViewController, @"contentViewController should only be set once");
    _contentViewController = contentViewController;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setMenuViewController:(UIViewController *)menuViewController
{
    if (!_menuViewController)
    {
        _menuViewController = menuViewController;
        return;
    }

    [self hideController:_menuViewController];
    _menuViewController = menuViewController;
    [self displayController:menuViewController frame:self.view.frame];
    
    [self addMenuViewControllerMotionEffects];
    [self.view bringSubviewToFront:self.contentViewController.view];
}

#pragma mark - Status bar appearance management

- (void)updateStatusBar
{
    [UIView animateWithDuration:0.3f animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

#pragma mark - UINavigationControllerDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if ([fromVC respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)])
    {
        return [(UIViewController<UINavigationControllerDelegate> *)fromVC navigationController:navigationController
                                                                animationControllerForOperation:operation
                                                                             fromViewController:fromVC
                                                                               toViewController:toVC];
    }
    else if ([toVC respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)])
    {
        return [(UIViewController<UINavigationControllerDelegate> *)toVC navigationController:navigationController
                                                              animationControllerForOperation:operation
                                                                           fromViewController:fromVC
                                                                             toViewController:toVC];
    }
    else
    {
        return nil;
    }
}

#pragma mark - NSNotification handlers

- (void)menuControllerDidSelectRow:(NSNotification *)notification
{
    [self hideMenuViewController];

    id viewController = notification.userInfo[VMenuControllerDestinationViewControllerKey];
    if (viewController)
    {
        [self navigateToViewController:viewController];
    }
}

@end
