//
//  VSideMenuWebBrowserViewController.m
//  victorious
//
//  Created by Patrick Lynch on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSideMenuWebBrowserViewController.h"
#import "VDependencyManager.h"
#import "VWebBrowserHeaderViewController.h"

@interface VSideMenuWebBrowserViewController ()

@end

@implementation VSideMenuWebBrowserViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WebBrowser" bundle:[NSBundle mainBundle]];
    VSideMenuWebBrowserViewController *webBrowserViewController = (VSideMenuWebBrowserViewController *)[storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    webBrowserViewController.dependencyManager = dependencyManager;
    
    NSString *templateUrlString = [dependencyManager stringForKey:VDependencyManagerWebURLKey];
    if ( templateUrlString != nil )
    {
        [webBrowserViewController loadUrlString:templateUrlString];
    }
    
    return webBrowserViewController;
}

- (void)setTitle:(NSString *)title
{
    NSString *tempalteTitle = [self.dependencyManager stringForKey:VDependencyManagerTitleKey];
    if ( tempalteTitle != nil )
    {
        super.title = tempalteTitle;
    }
    else
    {
        super.title = title;
    }
}

- (void)setHeaderViewController:(VWebBrowserHeaderViewController *)headerViewController
{
    headerViewController.layoutMode = VWebBrowserHeaderLayoutModeMenuItem;
    super.headerViewController = headerViewController;
}

@end
