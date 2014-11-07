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

@property (nonatomic, weak) IBOutlet UIButton *buttonBack;
@property (nonatomic, weak) IBOutlet UIButton *buttonNext;
@property (nonatomic, weak) IBOutlet UIButton *buttonRefresh;
@property (nonatomic, weak) IBOutlet UIButton *buttonOpenURL;
@property (nonatomic, weak) IBOutlet UIButton *buttonExit;
@property (nonatomic, weak) IBOutlet VProgressBarView *progressBar;

@end

@implementation VWebBrowserHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)applyTheme
{
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    NSString *tintColorKey = isTemplateC ? kVContentTextColor : kVMainTextColor;
    
    UIColor *progressColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    [self.progressBar setProgressColor:progressColor];
    
    UIColor *tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:tintColorKey];
    self.tintColor = tintColor;
    for ( UIButton *button in @[ self.buttonBack, self.buttonNext, self.buttonRefresh,
                                self.buttonExit, self.buttonOpenURL ])
    {
        [button setTitleColor:tintColor forState:UIControlStateNormal];
        button.tintColor = tintColor;
    }
    
    self.backgroundColor = isTemplateC ? [UIColor whiteColor] : [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
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
    self.buttonRefresh.enabled = [self.browserDelegate canRefresh];
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


- (IBAction)refreshSelected:(id)sender
{
    [self.browserDelegate refresh];
    [self updateHeaderState];
}

@end
