//
//  VWebBrowserHeaderView.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebBrowserHeaderViewController.h"
#import "VSettingManager.h"
#import "VThemeManager.h"
#import "VConstants.h"
#import "VDependencyManager.h"

static const NSTimeInterval kLayoutChangeAnimationDuration  = 0.5f;
static const CGFloat kLayoutChangeAnimationSpringDampening  = 0.8f;
static const CGFloat kLayoutChangeAnimationSpringVelocity   = 0.1f;

static const CGFloat kDefaultLeadingSpace                   = 8.0f;

@interface VWebBrowserHeaderViewController()

@property (nonatomic, strong) NSURL *currentURL;

@property (nonatomic, weak) IBOutlet UIButton *buttonBack;
@property (nonatomic, weak) IBOutlet UIButton *buttonOpenURL;
@property (nonatomic, weak) IBOutlet UIButton *buttonExit;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet VProgressBarView *progressBar;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonBackWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *pageTitleX1Constraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonExitX2Constraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonExitWidthConstraint;

@property (nonatomic, assign) CGFloat startingBackButtonWidth;
@property (nonatomic, assign) CGFloat startingExitButtonWidth;
@property (nonatomic, assign) CGFloat startingPageTitleX1;

@end

@implementation VWebBrowserHeaderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self applyTheme];
    
    self.labelTitle.text = NSLocalizedString( @"Loading...", @"" );
    
    self.startingBackButtonWidth = self.buttonBackWidthConstraint.constant;
    self.startingExitButtonWidth = self.buttonExitWidthConstraint.constant;
    self.startingPageTitleX1 = self.pageTitleX1Constraint.constant;
    
    [self updateState];
}

- (void)applyTheme
{
    if ( self.dependencyManager == nil )
    {
        return;
    }
    UIColor *progressColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    [self.progressBar setProgressColor:progressColor];
    
    UIColor *tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    for ( UIButton *button in @[ self.buttonBack, self.buttonExit, self.buttonOpenURL ])
    {
        [button setImage:[button.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [button setTitleColor:tintColor forState:UIControlStateNormal];
        button.tintColor = tintColor;
    }
    
    self.view.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.labelTitle.textColor = tintColor;
    
    self.labelTitle.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
}

- (void)updateStateAnimated:(BOOL)animated
{
    void (^updateBlock)() = ^void ()
    {
        [self updateState];
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

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( [self isViewLoaded] )
    {
        [self applyTheme];
    }
}

- (void)setLoadingProgress:(float)loadingProgress
{
    [self.progressBar setProgress:loadingProgress animated:YES];
}

- (void)setLoadingComplete:(BOOL)didFail
{
    if ( !didFail )
    {
        self.progressBar.progress = 1.0f;
    }
    [self.progressBar clearProgressAnimated:YES];
}

- (void)setLoadingStarted
{
    self.progressBar.progress = 0.0f;
}

- (void)setTitle:(NSString *)title
{
    [self.labelTitle setText:title];
}

- (void)setLayoutMode:(VWebBrowserHeaderLayoutMode)layoutMode
{
    _layoutMode = layoutMode;
    
    if ( self.isViewLoaded )
    {
        [self updateState];
    }
}

- (void)updateState
{
    const BOOL shouldHideNavControls = ![self.browserDelegate canGoBack];
    self.buttonBack.enabled = [self.browserDelegate canGoBack];
    self.buttonBackWidthConstraint.constant = shouldHideNavControls ? 0.0f : self.startingBackButtonWidth;
    
    switch ( self.layoutMode )
    {
        case VWebBrowserHeaderLayoutModeStandalone:
            self.labelTitle.textAlignment = NSTextAlignmentLeft;
            self.buttonExitWidthConstraint.constant = self.startingExitButtonWidth;
            self.pageTitleX1Constraint.constant = self.startingPageTitleX1 + (shouldHideNavControls ? kDefaultLeadingSpace : 0.0f);
            break;
            
        case VWebBrowserHeaderLayoutModeMenuItem:
            self.labelTitle.textAlignment = NSTextAlignmentCenter;
            self.buttonExitWidthConstraint.constant = 0.0f;
            self.pageTitleX1Constraint.constant = self.startingPageTitleX1 + (shouldHideNavControls ? self.startingBackButtonWidth : 0.0f);
            break;
    }
    
    [self.view layoutIfNeeded];
}

#pragma mark - Header Actions

- (IBAction)backSelected:(id)sender
{
    [self.browserDelegate goBack];
    [self updateStateAnimated:YES];
}

- (IBAction)forwardSelected:(id)sender
{
    [self.browserDelegate goForward];
    [self updateStateAnimated:YES];
}

- (IBAction)exportSelected:(id)sender
{
    [self.browserDelegate export];
    [self updateStateAnimated:YES];
}

- (IBAction)exitSelected:(id)sender
{
    [self.browserDelegate exit];
    [self updateStateAnimated:YES];
}

- (IBAction)refreshSelected:(id)sender
{
    [self.browserDelegate reload];
    [self updateStateAnimated:YES];
}

@end
