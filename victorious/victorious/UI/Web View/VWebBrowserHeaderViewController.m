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
#import "VDependencyManager+VBackgroundContainer.h"

@interface VWebBrowserHeaderViewController() <VBackgroundContainer>

@property (nonatomic, strong) NSURL *currentURL;
@property (nonatomic, weak) IBOutlet UIButton *buttonOpenURL;
@property (nonatomic, weak) IBOutlet UIButton *buttonExit;
@property (nonatomic, weak, readwrite) IBOutlet UIButton *buttonBack;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak, readwrite) IBOutlet VProgressBarView *progressBar;
@property (nonatomic, strong, readwrite) IBOutlet VWebBrowserHeaderLayoutManager *layoutManager;
@property (nonatomic, weak) IBOutlet UIView *backgroundContainerView;

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
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
    
    self.labelTitle.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
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
    [self.delegate goBack];
    [self.layoutManager updateAnimated:YES];
}

- (IBAction)forwardSelected:(id)sender
{
    [self.delegate goForward];
    [self.layoutManager updateAnimated:YES];
}

- (IBAction)exportSelected:(id)sender
{
    [self.delegate export];
    [self.layoutManager updateAnimated:YES];
}

- (IBAction)exitSelected:(id)sender
{
    [self.delegate exit];
    [self.layoutManager updateAnimated:YES];
}

- (IBAction)refreshSelected:(id)sender
{
    [self.delegate reload];
    [self.layoutManager updateAnimated:YES];
}

@end
