//
//  VTabBarViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTabBarViewController.h"
#import "VTabInfo.h"
#import "VThemeManager.h"

typedef NS_ENUM(NSInteger, VSlideDirection)
{
    VSlideDirectionNone = 0, ///< Use this to disable animation
    VSlideDirectionLeft,
    VSlideDirectionRight
};

static const CGFloat kButtonsSuperviewHeight = 49.0f;
static const CGFloat kButtonMargin           =  0.5f;

@interface VTabBarViewController ()

@property (nonatomic, weak)   UIView             *buttonsSuperview;
@property (nonatomic, weak)   UIView             *childContainer;
@property (nonatomic, strong) NSArray /* UIButton */           *buttons;
@property (nonatomic, strong) NSArray /* NSLayoutConstraint */ *buttonWidthConstraints;
@property (nonatomic)         NSUInteger          selectedIndex;
@property (nonatomic, weak)   UIImageView        *selectionIndicator;
@property (nonatomic, weak)   NSLayoutConstraint *selectionXconstraint;
@property (nonatomic, strong) UIViewController   *displayedViewController;

@end

@implementation VTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _selectedIndex = 0;
        _buttonBackgroundColor = [UIColor colorWithRed:0.184f green:0.129f blue:0.271f alpha:1.0f];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15f];
    
    UIView *buttonsSuperview = [[UIView alloc] init];
    buttonsSuperview.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:buttonsSuperview];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[buttonsSuperview]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(buttonsSuperview)]];
    self.buttonsSuperview = buttonsSuperview;
    
    
    UIView *childContainer = [[UIView alloc] init];
    childContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:childContainer];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[buttonsSuperview(==superviewHeight)][childContainer]|"
                                                                      options:0
                                                                      metrics:@{ @"superviewHeight": @(kButtonsSuperviewHeight) }
                                                                        views:NSDictionaryOfVariableBindings(buttonsSuperview, childContainer)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[childContainer]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(childContainer)]];
    
    self.childContainer = childContainer;
    
    [self addButtons];

    UIImageView *selectionIndicator = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"arrowDownIndicator"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    selectionIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [selectionIndicator setTintColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor]];
    [self.view addSubview:selectionIndicator];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:selectionIndicator
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.buttonsSuperview
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:0.0f]];

    self.selectionIndicator = selectionIndicator;

}

#pragma mark -

- (void)addButtons
{
    // remove old buttons
    for (UIButton *button in self.buttons)
    {
        [button removeFromSuperview];
    }
    
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:self.viewControllers.count];
    NSMutableArray *buttonWidthConstraints = [[NSMutableArray alloc] initWithCapacity:self.viewControllers.count];
    for (VTabInfo *tabInfo in self.viewControllers)
    {
        if ([tabInfo isKindOfClass:[VTabInfo class]])
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            button.backgroundColor = self.buttonBackgroundColor;
            button.adjustsImageWhenHighlighted = NO;
            [button setImage:tabInfo.icon forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttonsSuperview addSubview:button];
            [self.buttonsSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[button]|"
                                                                                          options:NSLayoutFormatDirectionLeftToRight
                                                                                          metrics:@{ @"margin": @(kButtonMargin) }
                                                                                            views:NSDictionaryOfVariableBindings(button)]];
            NSLayoutConstraint *buttonWidthConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                                     attribute:NSLayoutAttributeWidth
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:nil
                                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                                    multiplier:1.0f
                                                                                      constant:0];
            buttonWidthConstraint.priority = UILayoutPriorityDefaultHigh;
            [self.buttonsSuperview addConstraint:buttonWidthConstraint];
            [buttonWidthConstraints addObject:buttonWidthConstraint];
 
            //All buttons will have equal width, accomplished by forcing width of every button currently being assigned constraints to be width of previous button
            if (buttons.count == self.viewControllers.count - 1) // last button
            {
                UIButton *previousButton = [buttons lastObject];
                [self.buttonsSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousButton]-margin-[button(==previousButton)]|"
                                                                                              options:NSLayoutFormatDirectionLeftToRight
                                                                                              metrics:@{ @"margin": @(kButtonMargin) }
                                                                                                views:NSDictionaryOfVariableBindings(previousButton, button)]];
            }
            else if (buttons.count) // one of the middle buttons
            {
                UIButton *previousButton = [buttons lastObject];
                [self.buttonsSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousButton]-margin-[button(==previousButton)]"
                                                                                              options:NSLayoutFormatDirectionLeftToRight
                                                                                              metrics:@{ @"margin": @(kButtonMargin) }
                                                                                                views:NSDictionaryOfVariableBindings(previousButton, button)]];
            }
            else // first button
            {
                [self.buttonsSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button]"
                                                                                              options:NSLayoutFormatDirectionLeftToRight
                                                                                              metrics:nil
                                                                                                views:NSDictionaryOfVariableBindings(button)]];
            }
            
            [buttons addObject:button];
        }
    }
    
    self.buttons = buttons;
    self.buttonWidthConstraints = buttonWidthConstraints;
    [self.buttonsSuperview bringSubviewToFront:self.selectionIndicator];
    
    [self.view setNeedsUpdateConstraints];
    [self selectChildViewControllerAtIndex:0 animated:NO];
}

#pragma mark - Properties

- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = viewControllers;
    if ([self isViewLoaded])
    {
        [self addButtons];
    }
}

- (void)setButtonBackgroundColor:(UIColor *)buttonBackgroundColor
{
    _buttonBackgroundColor = buttonBackgroundColor;
    if ([self isViewLoaded])
    {
        for (UIButton *button in self.buttons)
        {
            button.backgroundColor = buttonBackgroundColor;
        }
    }
}

#pragma mark - Button Action

- (void)buttonTapped:(UIButton *)sender
{
    NSUInteger index = [self.buttons indexOfObject:sender];
    [self selectChildViewControllerAtIndex:index animated:YES];
}

#pragma mark - Child View Controllers

- (void)selectChildViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (self.displayedViewController && index == self.selectedIndex)
    {
        return;
    }
    if (self.viewControllers.count <= index)
    {
        return;
    }
    
    if (self.selectionXconstraint)
    {
        [self.view removeConstraint:self.selectionXconstraint];
    }
    
    NSLayoutConstraint *selectionXconstraint = [NSLayoutConstraint constraintWithItem:self.selectionIndicator
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.buttons[index]
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1.0f
                                                                             constant:0];
    [self.view addConstraint:selectionXconstraint];
    self.selectionXconstraint = selectionXconstraint;
    
    VSlideDirection slide = VSlideDirectionNone;
    if (animated)
    {
        slide = index > self.selectedIndex ? VSlideDirectionLeft : VSlideDirectionRight;
    }
    
    self.selectedIndex = index;
    [self setDisplayedViewController:[self.viewControllers[index] viewController]
                      slideDirection:slide];
}

- (void)setDisplayedViewController:(UIViewController *)displayedViewController
{
    [self setDisplayedViewController:displayedViewController slideDirection:VSlideDirectionNone];
}

- (void)setDisplayedViewController:(UIViewController *)newViewController slideDirection:(VSlideDirection)direction
{
    UIViewController *oldViewController = self.displayedViewController;
    if (!newViewController || oldViewController == newViewController)
    {
        return;
    }
    
    [self addChildViewController:newViewController];
    [oldViewController willMoveToParentViewController:nil];
    
    newViewController.view.frame = CGRectMake(direction == VSlideDirectionRight ? -CGRectGetWidth(self.childContainer.bounds) * 0.5f :
                                              CGRectGetWidth(self.childContainer.bounds) * 0.5f,
                                              CGRectGetMinY(self.childContainer.bounds),
                                              CGRectGetWidth(self.childContainer.bounds),
                                              CGRectGetHeight(self.childContainer.bounds));
    newViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    newViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    newViewController.view.alpha = 0;
    [self.childContainer addSubview:newViewController.view];
    
    [self.view layoutIfNeeded];
    
    void (^animations)() = ^(void)
    {
        newViewController.view.alpha = 1.0f;
        newViewController.view.frame = self.childContainer.bounds;
        oldViewController.view.frame = CGRectMake(direction == VSlideDirectionRight ?  CGRectGetWidth(self.childContainer.bounds) * 0.5f :
                                                                                      -CGRectGetWidth(self.childContainer.bounds) * 0.5f,
                                                  CGRectGetMinY(self.childContainer.bounds),
                                                  CGRectGetWidth(self.childContainer.bounds),
                                                  CGRectGetHeight(self.childContainer.bounds));
        oldViewController.view.alpha = 0;
        [self.view layoutIfNeeded];
    };
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        oldViewController.view.alpha = 1.0f;
        [oldViewController.view removeFromSuperview];
        [oldViewController removeFromParentViewController];
        [newViewController didMoveToParentViewController:self];
    };
    
    if (direction == VSlideDirectionNone)
    {
        animations();
        completion(YES);
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:animations completion:completion];
    }
    
    _displayedViewController = newViewController;
}

@end
