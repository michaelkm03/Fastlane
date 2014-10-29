//
//  VOpenXAdViewController.m
//  victorious
//
//  Created by Lawrence Leach on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VOpenXAdViewController.h"
#import "OpenXMSDK.h"
#import "VSettingManager.h"

@interface VOpenXAdViewController ()

@property (nonatomic, strong) OXMVideoAdManager *adManager;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) BOOL adViewAppeared;

@end

@implementation VOpenXAdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.adViewAppeared)
    {
        self.adViewAppeared = YES;
        
        // Initialize ad manager and push it onto view stack
        VSettingManager *settingsManager = [VSettingManager sharedManager];
        self.vastTag = [settingsManager fetchMonetizationItemByKey:kOpenXVastTag];
        self.adManager.customContentPlaybackView.frame = self.view.bounds;
        self.adManager.vastTag = self.vastTag;
        [self.view addSubview:self.adManager.customContentPlaybackView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Start the OpenX Ad Manager
    [self.adManager startAdManager];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

@end
