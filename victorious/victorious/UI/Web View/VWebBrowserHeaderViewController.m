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
#import "VWebBrowserHeaderLayoutManager.h"

@interface VWebBrowserHeaderViewController()

@property (nonatomic, strong) NSURL *currentURL;
@property (nonatomic, weak) IBOutlet UIButton *buttonOpenURL;
@property (nonatomic, weak) IBOutlet UIButton *buttonExit;

@end

@implementation VWebBrowserHeaderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self applyTheme];
    
    [self.layoutManager update];
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
    
    self.labelTitle.font = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
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

#pragma mark - Header Actions

- (IBAction)backSelected:(id)sender
{
    [self.browserDelegate goBack];
    [self.layoutManager updateAnimated:YES];
}

- (IBAction)forwardSelected:(id)sender
{
    [self.browserDelegate goForward];
    [self.layoutManager updateAnimated:YES];
}

- (IBAction)exportSelected:(id)sender
{
    [self.browserDelegate export];
    [self.layoutManager updateAnimated:YES];
}

- (IBAction)exitSelected:(id)sender
{
    [self.browserDelegate exit];
    [self.layoutManager updateAnimated:YES];
}

- (IBAction)refreshSelected:(id)sender
{
    [self.browserDelegate reload];
    [self.layoutManager updateAnimated:YES];
}

@end
