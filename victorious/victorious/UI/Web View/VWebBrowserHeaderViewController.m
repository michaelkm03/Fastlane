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

static const NSTimeInterval kLayoutChangeAnimationDuration  = 0.5f;
static const NSTimeInterval kLayoutChangeAnimationDelay     = 0.5f;
static const float kLayoutChangeAnimationSpringDampening    = 0.8f;
static const float kLayoutChangeAnimationSpringVelocity     = 0.1f;

@interface VWebBrowserHeaderViewController() <UIWebViewDelegate>

@property (nonatomic, strong) NSURL *currentURL;

@property (nonatomic, weak) IBOutlet UIButton *buttonBack;
@property (nonatomic, weak) IBOutlet UIButton *buttonNext;
@property (nonatomic, weak) IBOutlet UIButton *buttonRefresh;
@property (nonatomic, weak) IBOutlet UIButton *buttonOpenURL;
@property (nonatomic, weak) IBOutlet UIButton *buttonExit;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelSubtitle;
@property (nonatomic, weak) IBOutlet VProgressBarView *progressBar;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonBackWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonNextWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *subtitleHeightConstraint;

@property (nonatomic, assign) CGFloat startingButtonWidth;
@property (nonatomic, assign) CGFloat startingSubtitleHeight;

@end

@implementation VWebBrowserHeaderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self applyTheme];
    
    self.labelTitle.text = NSLocalizedString( @"Loading...", @"" );
    self.labelSubtitle.text = nil;
    self.labelSubtitle.alpha = 0.0f;
    
    self.startingButtonWidth = self.buttonBackWidthConstraint.constant;
    self.startingSubtitleHeight = self.subtitleHeightConstraint.constant;
    
    [self contractExtraControls];
    
    [self.view layoutIfNeeded];
}

- (void)contractExtraControls
{
    self.labelTitle.textAlignment = NSTextAlignmentLeft;
    self.labelSubtitle.textAlignment = NSTextAlignmentLeft;
    self.subtitleHeightConstraint.constant = 0.0f;
    self.buttonBackWidthConstraint.constant = 0.0f;
    self.buttonNextWidthConstraint.constant = 0.0f;
}

- (void)applyTheme
{
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    NSString *tintColorKey = isTemplateC ? kVContentTextColor : kVMainTextColor;
    
    UIColor *progressColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    [self.progressBar setProgressColor:progressColor];
    
    UIColor *tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:tintColorKey];
    self.view.tintColor = tintColor;
    for ( UIButton *button in @[ self.buttonBack, self.buttonNext, self.buttonRefresh,
                                 self.buttonExit, self.buttonOpenURL ])
    {
        [button setTitleColor:tintColor forState:UIControlStateNormal];
        button.tintColor = tintColor;
    }
    
    self.view.backgroundColor = isTemplateC ? [UIColor whiteColor] : [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.labelTitle.textColor = tintColor;
    self.labelSubtitle.textColor = tintColor;
    
    NSString *headerFontKey = isTemplateC ? kVHeading2Font : kVHeaderFont;
    self.labelTitle.font = [[VThemeManager sharedThemeManager] themedFontForKey:headerFontKey];
}

- (void)expandExtraControls
{
    self.labelTitle.textAlignment = NSTextAlignmentCenter;
    self.labelSubtitle.textAlignment = NSTextAlignmentCenter;
    self.buttonBackWidthConstraint.constant = self.startingButtonWidth;
    self.buttonNextWidthConstraint.constant = self.startingButtonWidth;
}

- (BOOL)shouldShowNavigationControls
{
    return [self.browserDelegate canGoBack];
}

- (void)updateHeaderState
{
    if ( self.shouldShowNavigationControls )
    {
        [UIView animateWithDuration:kLayoutChangeAnimationDuration
                              delay:0.0f
             usingSpringWithDamping:kLayoutChangeAnimationSpringDampening
              initialSpringVelocity:kLayoutChangeAnimationSpringVelocity
                            options:kNilOptions
                         animations:^void
        {
            [self expandExtraControls];
            [self.view layoutIfNeeded];
        }
                         completion:nil];
    }
    
    self.buttonNext.enabled = [self.browserDelegate canGoForward];
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

- (void)setSubtitle:(NSString *)subtitle
{
    [self.labelSubtitle setText:subtitle];
    if ( subtitle != nil && self.shouldShowNavigationControls )
    {
        [UIView animateWithDuration:kLayoutChangeAnimationDuration
                              delay:kLayoutChangeAnimationDelay
             usingSpringWithDamping:kLayoutChangeAnimationSpringDampening
              initialSpringVelocity:kLayoutChangeAnimationSpringVelocity
                            options:kNilOptions
                         animations:^void
         {
             self.subtitleHeightConstraint.constant = self.startingSubtitleHeight;
             self.labelSubtitle.alpha = 0.6f;
             [self.view layoutIfNeeded];
         }
                         completion:nil];
    }
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
