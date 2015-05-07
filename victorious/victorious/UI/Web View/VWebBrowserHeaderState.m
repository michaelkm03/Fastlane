//
//  VWebBrowserHeaderState.m
//  victorious
//
//  Created by Patrick Lynch on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWebBrowserHeaderState.h"
#import "VWebBrowserHeaderViewController.h"

@interface VWebBrowserHeaderState()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonBackWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *pageTitleX1Constraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonExitWidthConstraint;

@property (nonatomic, assign) CGFloat startingBackButtonWidth;
@property (nonatomic, assign) CGFloat startingExitButtonWidth;
@property (nonatomic, assign) CGFloat startingPageTitleX1;

@end

@implementation VWebBrowserHeaderState

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.startingBackButtonWidth = self.buttonBackWidthConstraint.constant;
    self.startingExitButtonWidth = self.buttonExitWidthConstraint.constant;
    self.startingPageTitleX1 = self.pageTitleX1Constraint.constant;
}

- (void)update
{
    const BOOL shouldHideNavControls = ![self.webBrowserHeader.browserDelegate canGoBack];
    self.webBrowserHeader.buttonBack.enabled = [self.webBrowserHeader.browserDelegate canGoBack];
    self.buttonBackWidthConstraint.constant = shouldHideNavControls ? 0.0f : self.startingBackButtonWidth;
    
    self.webBrowserHeader.labelTitle.textAlignment = NSTextAlignmentLeft;
    self.buttonExitWidthConstraint.constant = self.startingExitButtonWidth;
    self.pageTitleX1Constraint.constant = self.startingPageTitleX1 + (shouldHideNavControls ? kDefaultLeadingSpace : 0.0f);
    
    [self.webBrowserHeader.view layoutIfNeeded];
}

- (void)updateAnimated:(BOOL)animated
{
    void (^updateBlock)() = ^void ()
    {
        [self update];
    };
    
    if ( animated )
    {
        [UIView animateWithDuration:kLayoutChangeAnimationDuration
                              delay:0.0f
             usingSpringWithDamping:kLayoutChangeAnimationSpringDampening
              initialSpringVelocity:kLayoutChangeAnimationSpringVelocity
                            options:kNilOptions
                         animations:updateBlock
                         completion:nil];
    }
    else
    {
        updateBlock();
    }
}

- (void)update2
{
    const BOOL shouldHideNavControls = ![self.webBrowserHeader.browserDelegate canGoBack];
    self.webBrowserHeader.buttonBack.enabled = [self.webBrowserHeader.browserDelegate canGoBack];
    self.buttonBackWidthConstraint.constant = shouldHideNavControls ? 0.0f : self.startingBackButtonWidth;
    
    self.webBrowserHeader.labelTitle.textAlignment = NSTextAlignmentCenter;
    self.buttonExitWidthConstraint.constant = 0.0f;
    self.pageTitleX1Constraint.constant = self.startingPageTitleX1 + (shouldHideNavControls ? self.startingBackButtonWidth : 0.0f);
    
    [self.webBrowserHeader.view layoutIfNeeded];
}

@end