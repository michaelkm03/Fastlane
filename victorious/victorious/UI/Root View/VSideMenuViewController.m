//
//  VSideMenuViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VHamburgerButton.h"
#import "VMenuController.h"
#import "VNavigationController.h"
#import "VNavigationDestination.h"
#import "VNavigationDestinationsProvider.h"
#import "VProvidesNavigationMenuItemBadge.h"
#import "VSettingManager.h"
#import "VSideMenuViewController.h"
#import "VStreamCollectionViewController.h"
#import "VThemeManager.h"
#import "UIImage+ImageEffects.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "UIView+AutoLayout.h"

@interface VSideMenuViewController ()

@property (strong, readwrite, nonatomic) VDependencyManager *dependencyManager;
@property (strong, readwrite, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (assign, readwrite, nonatomic) BOOL visible;
@property (assign, readwrite, nonatomic) CGPoint originalPoint;
@property (strong, readwrite, nonatomic) UIButton *contentButton;
@property (strong, readwrite, nonatomic) VHamburgerButton *hamburgerButton;

@end

@implementation VSideMenuViewController

#pragma mark - Initializers

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager nibName:(NSString *)nibName
{
    self = [super initWithDependencyManager:dependencyManager nibName:nibName];
    if ( self != nil )
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
        
        [self registerBadgeUpdateBlock];
    }
    return self;
}

- (void)registerBadgeUpdateBlock
{
    __weak typeof(self) weakSelf = self;
    VNavigationMenuItemBadgeNumberUpdateBlock badgeNumberUpdateBlock = ^(NSInteger badgeNumber)
    {
        [weakSelf.hamburgerButton setBadgeNumber:badgeNumber];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
    };
    
    if ( [self.menuViewController respondsToSelector:@selector(setBadgeNumberUpdateBlock:)] )
    {
        [(id<VProvidesNavigationMenuItemBadge>)self.menuViewController setBadgeNumberUpdateBlock:badgeNumberUpdateBlock];
    }
    
    if ( [self.menuViewController respondsToSelector:@selector(badgeNumber)] )
    {
        NSInteger badgeNumber = [(id<VProvidesNavigationMenuItemBadge>)self.menuViewController badgeNumber];
        badgeNumberUpdateBlock(badgeNumber);
    }
}

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return [self initWithDependencyManager:dependencyManager nibName:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImage = [[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice]
                            applyBlurWithRadius:25 tintColor:[UIColor colorWithWhite:0.0 alpha:0.75] saturationDeltaFactor:1.8 maskImage:nil];
    self.backgroundImageView.image = self.backgroundImage;
    
    self.contentViewController = [[VNavigationController alloc] initWithDependencyManager:self.dependencyManager];
    
    self.hamburgerButton = [VHamburgerButton newWithDependencyManager:[self.dependencyManager dependencyManagerForNavigationBar]];
    [self.hamburgerButton addTarget:self action:@selector(presentMenuViewController) forControlEvents:UIControlEventTouchUpInside];
    self.contentViewController.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.hamburgerButton];
    
    if (!_contentViewInLandscapeOffsetCenterX)
    {
        _contentViewInLandscapeOffsetCenterX = CGRectGetHeight(self.view.frame) + 30.f;
    }
    
    if (!_contentViewInPortraitOffsetCenterX)
    {
        _contentViewInPortraitOffsetCenterX  = CGRectGetWidth(self.view.frame) + 30.f;
    }
    
    self.contentButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectNull];
        [button addTarget:self action:@selector(hideMenuViewController) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    [self addChildViewController:self.menuViewController];
    self.menuViewController.view.frame = self.view.bounds;
    self.menuViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.menuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.menuViewController.view];
    [self.menuViewController didMoveToParentViewController:self];

    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    self.contentViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    self.menuViewController.view.alpha = 0;
    if (self.scaleBackgroundImageView)
    {
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    }
    
    [self addMenuViewControllerMotionEffects];

    UIViewController *initialVC = [self.dependencyManager singletonViewControllerForKey:VDependencyManagerInitialViewControllerKey];
    if (initialVC != nil)
    {
        [self displayResultOfNavigation:initialVC];
    }
    else if ( [self.menuViewController respondsToSelector:@selector(navigationDestinations)] )
    {
        NSArray *destinations = [(id<VNavigationDestinationsProvider>)self.menuViewController navigationDestinations];
        
        if ( destinations.count > 0 )
        {
            [self navigateToDestination:destinations[0]];
        }
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
        
        CGFloat contentViewOffsetCenterX = CGRectGetWidth(self.view.frame) + 30.f;
        
        self.contentViewController.view.center = CGPointMake(contentViewOffsetCenterX, self.contentViewController.view.center.y);
        
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

- (void)navigateToDestination:(id)navigationDestination completion:(void (^)())completion
{
    if ( self.visible )
    {
        [self hideMenuViewController];
    }
    [super navigateToDestination:navigationDestination completion:completion];
}

- (void)displayResultOfNavigation:(UIViewController *)viewController
{
    NSAssert(viewController != nil, @"Can't display a nil view controller");
    
    // Dismiss any modals
    if ( self.presentedViewController != nil )
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    self.contentViewController.innerNavigationController.viewControllers = @[viewController];
}

#pragma mark - Motion effects

- (void)addMenuViewControllerMotionEffects
{
    if (self.parallaxEnabled)
    {
       for (UIMotionEffect *effect in self.menuViewController.view.motionEffects)
       {
           [self.menuViewController.view removeMotionEffect:effect];
       }

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

- (void)setContentViewController:(VNavigationController *)contentViewController
{
    NSAssert(!_contentViewController, @"contentViewController should only be set once");
    _contentViewController = contentViewController;
    [self setNeedsStatusBarAppearanceUpdate];
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

@end
