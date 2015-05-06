//
//  VBottomMenuWebBrowserViewController.m
//  victorious
//
//  Created by Patrick Lynch on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBottomMenuWebBrowserViewController.h"
#import "VDependencyManager.h"
#import "VNavigationController.h"
#import "VWebBrowserHeaderViewController.h"

@interface VBottomMenuWebBrowserViewController ()

@end

@implementation VBottomMenuWebBrowserViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WebBrowser" bundle:[NSBundle mainBundle]];
    VBottomMenuWebBrowserViewController *webBrowserViewController = (VBottomMenuWebBrowserViewController *)[storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    webBrowserViewController.dependencyManager = dependencyManager;
    
    NSString *templateUrlString = [dependencyManager stringForKey:VDependencyManagerWebURLKey];
    if ( templateUrlString != nil )
    {
        [webBrowserViewController loadUrlString:templateUrlString];
    }
    
    return webBrowserViewController;
}

- (BOOL)v_prefersNavigationBarHidden
{
    return YES;
}

- (void)setHeaderViewController:(VWebBrowserHeaderViewController *)headerViewController
{
    headerViewController.layoutMode = VWebBrowserHeaderLayoutModeMenuItem;
    super.headerViewController = headerViewController;
}

@end
