//
//  UIViewController+VNavMenu.m
//  victorious
//
//  Created by Will Long on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIViewController+VNavMenu.h"
#import "UIViewController+VSideMenuViewController.h"

#import <objc/runtime.h>

static const char kNavHeaderViewKey;
static const char kNavHeaderYConstraintKey;

@interface UIViewController (VNavMenuPrivate)

@property (nonatomic, strong) NSLayoutConstraint *navHeaderYConstraint;

@end

@implementation UIViewController (VNavMenu)

#pragma mark - Header

- (void)setNavHeaderView:(VNavigationHeaderView *)navHeaderView
{
    [self.navHeaderView removeFromSuperview];
    objc_setAssociatedObject(self, &kNavHeaderViewKey, navHeaderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VNavigationHeaderView *)navHeaderView
{
    VNavigationHeaderView *navHeaderView = objc_getAssociatedObject(self, &kNavHeaderViewKey);
    return navHeaderView;
}

- (void)setNavHeaderYConstraint:(NSLayoutConstraint *)navHeaderYConstraint
{
    objc_setAssociatedObject(self, &kNavHeaderYConstraintKey, navHeaderYConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutConstraint *)navHeaderYConstraint
{
    NSLayoutConstraint *navHeaderYConstraint = objc_getAssociatedObject(self, &kNavHeaderYConstraintKey);
    return navHeaderYConstraint;
}

- (void)addNewNavHeaderWithTitles:(NSArray *)titles
{
    if (self.navigationController.viewControllers.count <= 1)
    {
        self.navHeaderView = [VNavigationHeaderView menuButtonNavHeaderWithControlTitles:titles];
    }
    else
    {
        self.navHeaderView = [VNavigationHeaderView backButtonNavHeaderWithControlTitles:titles];
    }
    
    self.navHeaderView.headerText = self.title;//Set the title in case there is no logo
    [self.navHeaderView updateUI];
    [self.view addSubview:self.navHeaderView];
    
    self.navHeaderYConstraint = [NSLayoutConstraint constraintWithItem:self.navHeaderView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:0.0f];
    [self.view addConstraint:self.navHeaderYConstraint];
    
    VNavigationHeaderView *header = self.navHeaderView;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[header]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(header)]];
}

- (void)hideHeader
{
    if (!CGRectContainsRect(self.view.frame, self.navHeaderView.frame))
    {
        return;
    }
    
    self.navHeaderYConstraint.constant = -CGRectGetHeight(self.navHeaderView.frame);
    [self.view layoutIfNeeded];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)showHeader
{
    if (CGRectContainsRect(self.view.frame, self.navHeaderView.frame))
    {
        return;
    }
    
    self.navHeaderYConstraint.constant = 0;
    [self.view layoutIfNeeded];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)backPressedOnNavHeader:(VNavigationHeaderView *)navHeaderView
{
    if (navHeaderView == self.navHeaderView)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)menuPressedOnNavHeader:(VNavigationHeaderView *)navHeaderView
{
    if (navHeaderView == self.navHeaderView)
    {
        [self.sideMenuViewController presentMenuViewController];
    }
}

@end
