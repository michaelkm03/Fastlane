//
//  VSideMenuViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSideMenuViewController.h"
#import "UIViewController+VSideMenuViewController.h"

@interface VSideMenuViewController ()
@property (strong, readwrite, nonatomic) UIImageView *backgroundImageView;
@property (assign, readwrite, nonatomic) BOOL visible;
@property (assign, readwrite, nonatomic) CGPoint originalPoint;
@property (strong, readwrite, nonatomic) UIButton *contentButton;
@end

@implementation VSideMenuViewController

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

- (instancetype)initWithContentViewController:(UIViewController *)contentViewController menuViewController:(UIViewController *)menuViewController
{
    self = [self init];
    if (self)
    {
        _contentViewController = contentViewController;
        _menuViewController = menuViewController;
    }
    return self;
}

- (void)commonInit
{
    _animationDuration = 0.35f;
//    _panGestureEnabled = YES;
//    _interactivePopGestureRecognizerEnabled = YES;
    
    _scaleContentView      = YES;
    _contentViewScaleValue = 0.7f;
    
    _scaleBackgroundImageView = YES;
    
    _parallaxEnabled = YES;
    _parallaxMenuMinimumRelativeValue = @(-15);
    _parallaxMenuMaximumRelativeValue = @(15);
    
    _parallaxContentMinimumRelativeValue = @(-25);
    _parallaxContentMaximumRelativeValue = @(25);
    
    _bouncesHorizontally = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_contentViewInLandscapeOffsetCenterX)
        _contentViewInLandscapeOffsetCenterX = CGRectGetHeight(self.view.frame) + 30.f;
    
    if (!_contentViewInPortraitOffsetCenterX)
        _contentViewInPortraitOffsetCenterX  = CGRectGetWidth(self.view.frame) + 30.f;
    
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
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    
    [self addMenuViewControllerMotionEffects];
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
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    
    [self showMenuViewController];
}

- (void)showMenuViewController
{
    [self.view.window endEditing:YES];
    [self addContentButton];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (self.scaleContentView)
            self.contentViewController.view.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        
        self.contentViewController.view.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? self.contentViewInLandscapeOffsetCenterX : self.contentViewInPortraitOffsetCenterX), self.contentViewController.view.center.y);
        
        self.menuViewController.view.alpha = 1.0f;
        self.menuViewController.view.transform = CGAffineTransformIdentity;
        if (self.scaleBackgroundImageView)
            self.backgroundImageView.transform = CGAffineTransformIdentity;
        
    }
    completion:^(BOOL finished)
    {
        [self addContentViewControllerMotionEffects];
        self.visible = YES;
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
//        self.menuViewController.view.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        self.menuViewController.view.alpha = 0;
        if (self.scaleBackgroundImageView)
            self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);

        if (self.parallaxEnabled)
        {
            for (UIMotionEffect *effect in self.contentViewController.view.motionEffects)
            {
               [self.contentViewController.view removeMotionEffect:effect];
            }
        }
    }
    completion:^(BOOL finished)
    {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        self.visible = NO;
        [self updateStatusBar];
    }];
    
}

- (void)addContentButton
{
    if (self.contentButton.superview)
        return;
    
    self.contentButton.autoresizingMask = UIViewAutoresizingNone;
    self.contentButton.frame = self.contentViewController.view.bounds;
    self.contentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentViewController.view addSubview:self.contentButton];
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
           [self.contentViewController.view removeMotionEffect:effect];

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
        self.backgroundImageView.image = backgroundImage;
}

- (void)setContentViewController:(UIViewController *)contentViewController
{
    if (!_contentViewController)
    {
        _contentViewController = contentViewController;
        return;
    }

    CGRect frame = _contentViewController.view.frame;
    CGAffineTransform transform = _contentViewController.view.transform;
    [self hideController:_contentViewController];
    _contentViewController = contentViewController;
    [self displayController:contentViewController frame:self.view.bounds];
    contentViewController.view.transform = transform;
    contentViewController.view.frame = frame;
    
    [self addContentViewControllerMotionEffects];
}

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated
{
    if (!animated)
    {
        [self setContentViewController:contentViewController];
    }
    else
    {
        contentViewController.view.alpha = 0;
        contentViewController.view.frame = self.contentViewController.view.bounds;
        [self.contentViewController.view addSubview:contentViewController.view];
        [UIView animateWithDuration:self.animationDuration animations:^{
            contentViewController.view.alpha = 1;
        }
        completion:^(BOOL finished)
        {
            [contentViewController.view removeFromSuperview];
            [self setContentViewController:contentViewController];
        }];
    }
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
   UIStatusBarStyle statusBarStyle;
   if (self.contentViewController.view.frame.origin.y > 10)
       statusBarStyle = self.menuViewController.preferredStatusBarStyle;
   else
       statusBarStyle = self.contentViewController.preferredStatusBarStyle;

    return statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    BOOL statusBarHidden;
   if (self.contentViewController.view.frame.origin.y > 10)
       statusBarHidden = self.menuViewController.prefersStatusBarHidden;
   else
       statusBarHidden = self.contentViewController.prefersStatusBarHidden;

    return statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    UIStatusBarAnimation    statusBarAnimation;
   if (self.contentViewController.view.frame.origin.y > 10)
       statusBarAnimation = self.menuViewController.preferredStatusBarUpdateAnimation;
   else
       statusBarAnimation = self.contentViewController.preferredStatusBarUpdateAnimation;

    return statusBarAnimation;
}

@end
