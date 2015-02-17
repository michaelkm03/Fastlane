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

static const NSTimeInterval kLayoutChangeAnimationDuration  = 0.5f;
static const CGFloat kLayoutChangeAnimationSpringDampening  = 0.8f;
static const CGFloat kLayoutChangeAnimationSpringVelocity    = 0.1f;

@interface VWebBrowserHeaderViewController()

@property (nonatomic, strong) NSURL *currentURL;

@property (nonatomic, weak) IBOutlet UIButton *buttonBack;
@property (nonatomic, weak) IBOutlet UIButton *buttonOpenURL;
@property (nonatomic, weak) IBOutlet UIButton *buttonExit;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet VProgressBarView *progressBar;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonBackWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *pageTitleX1Constraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonBackX1Constraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonExitX2Constraint;

@property (nonatomic, assign) CGFloat startingButtonWidth;
@property (nonatomic, assign) CGFloat startingPageTitleX1;

@end

@implementation VWebBrowserHeaderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self applyTheme];
    
    self.labelTitle.text = NSLocalizedString( @"Loading...", @"" );
    
    self.startingButtonWidth = self.buttonBackWidthConstraint.constant;
    self.startingPageTitleX1 = self.pageTitleX1Constraint.constant;
    
    [self hideNavigationControls];
    
    [self.view layoutIfNeeded];
}

- (void)hideNavigationControls
{
    self.buttonBackWidthConstraint.constant = 0.0f;
    self.pageTitleX1Constraint.constant = 10.0f;
}

- (void)showNavigationControls
{
    self.buttonBackWidthConstraint.constant = self.startingButtonWidth;
    self.pageTitleX1Constraint.constant = self.startingPageTitleX1;
}

- (void)applyTheme
{
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    NSString *tintColorKey = isTemplateC ? kVContentTextColor : kVMainTextColor;
    
    UIColor *progressColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    [self.progressBar setProgressColor:progressColor];
    
    UIColor *tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:tintColorKey];
    for ( UIButton *button in @[ self.buttonBack, self.buttonExit, self.buttonOpenURL ])
    {
        [button setImage:[button.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [button setTitleColor:tintColor forState:UIControlStateNormal];
        button.tintColor = tintColor;
    }
    
    self.view.backgroundColor = isTemplateC ? [UIColor whiteColor] : [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.labelTitle.textColor = tintColor;
    
    NSString *headerFontKey = isTemplateC ? kVHeading2Font : kVHeaderFont;
    self.labelTitle.font = [[VThemeManager sharedThemeManager] themedFontForKey:headerFontKey];
}

- (void)updateHeaderState
{
    [UIView animateWithDuration:kLayoutChangeAnimationDuration
                          delay:0.0f
         usingSpringWithDamping:kLayoutChangeAnimationSpringDampening
          initialSpringVelocity:kLayoutChangeAnimationSpringVelocity
                        options:kNilOptions
                     animations:^void
     {
         if ( [self.browserDelegate canGoBack] )
         {
             [self showNavigationControls];
         }
         else
         {
             [self hideNavigationControls];
         }
         [self.view layoutIfNeeded];
     } completion:nil];
    
    self.buttonBack.enabled = [self.browserDelegate canGoBack];
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

#pragma mark - Header Actions

- (IBAction)backSelected:(id)sender
{
    [self.browserDelegate goBack];
    [self updateHeaderState];
}

- (IBAction)forwardSelected:(id)sender
{
    [self.browserDelegate goForward];
    [self updateHeaderState];
}

- (IBAction)exportSelected:(id)sender
{
    [self.browserDelegate export];
    [self updateHeaderState];
}

- (IBAction)exitSelected:(id)sender
{
    [self.browserDelegate exit];
    [self updateHeaderState];
}

- (IBAction)refreshSelected:(id)sender
{
    [self.browserDelegate reload];
    [self updateHeaderState];
}

@end
