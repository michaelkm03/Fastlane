//
//  VWebBrowserHeaderView.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebBrowserHeaderView.h"
#import "VSettingManager.h"
#import "VThemeManager.h"

@interface VWebBrowserHeaderView() <UIWebViewDelegate>

@property (nonatomic, strong) NSURL *currentURL;

@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelSubtitle;
@property (nonatomic, weak) IBOutlet UIButton *buttonBack;
@property (nonatomic, weak) IBOutlet UIButton *buttonNext;
@property (nonatomic, weak) IBOutlet UIButton *buttonOpenURL;
@property (nonatomic, weak) IBOutlet UIButton *buttonExit;
@property (nonatomic, weak) IBOutlet VProgressBarView *progressBar;

@end

@implementation VWebBrowserHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.labelTitle.text = nil;
    self.labelSubtitle.text = nil;
}

- (void)applyTheme
{
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    NSString *tintColorKey = isTemplateC ? kVContentTextColor : kVMainTextColor;
    UIColor *tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:tintColorKey];
    
    UIColor *progressColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    [self.progressBar setProgressColor:progressColor];
    
    self.tintColor = tintColor;
    self.buttonBack.tintColor = tintColor;
    [self.buttonBack setTitleColor:tintColor forState:UIControlStateNormal];
    self.buttonNext.tintColor = tintColor;
    [self.buttonNext setTitleColor:tintColor forState:UIControlStateNormal];
    self.buttonOpenURL.tintColor = tintColor;
    [self.buttonOpenURL setTitleColor:tintColor forState:UIControlStateNormal];
    self.buttonExit.tintColor = tintColor;
    [self.buttonExit setTitleColor:tintColor forState:UIControlStateNormal];
    
    self.backgroundColor = isTemplateC ? [UIColor whiteColor] : [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    
    self.labelTitle.textColor = tintColor;
    self.labelSubtitle.textColor = tintColor;
    
    NSString *headerFontKey = isTemplateC ? kVHeading2Font : kVHeaderFont;
    self.labelTitle.font = [[VThemeManager sharedThemeManager] themedFontForKey:headerFontKey];
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

- (void)updateHeaderState
{
    self.buttonNext.enabled = [self.browserDelegate canGoForward];
    self.buttonBack.enabled = [self.browserDelegate canGoBack];
}

- (void)setTitle:(NSString *)title
{
    [self.labelTitle setText:title];
}

- (void)setSubtitle:(NSString *)subtitle
{
    [self.labelSubtitle setText:subtitle];
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

- (IBAction)viewInBrowserSelected:(id)sender
{
    [self.browserDelegate openInBrowser];
    [self updateHeaderState];
}

- (IBAction)exitSelected:(id)sender
{
    [self.browserDelegate exit];
    [self updateHeaderState];
}

@end
