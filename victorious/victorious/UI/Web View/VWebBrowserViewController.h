//
//  VWebBrowserViewController.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VWebBrowserLayout.h"

#import <UIKit/UIKit.h>

@class VWebBrowserHeaderViewController;

/**
 A view controller that provides a web view and basic navigation controls
 for displaying external URLs or HTML content.  Can be used as part of the main menu
 when specified in the template or can be presented standalone to display some
 arbitrary web content.
 */
@interface VWebBrowserViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 A template specifier that can determine alternate layouts
 */
@property (nonatomic, assign) NSString *layoutIdentifier;

/**
 A title to display instead of the URL's page title
 */
@property (nonatomic, strong) NSString *templateTitle;

/**
 A specialized header component with navigation actions
 */
@property (nonatomic, weak) VWebBrowserHeaderViewController *headerViewController;

/**
 A specified for content alignment property of the header
 */
@property (nonatomic, assign) VWebBrowserHeaderContentAlignment headerContentAlignment;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Load and display the web content at the specified URL.
 */
- (void)loadUrl:(NSURL *)url;

/**
 Load and display the web content at a URL made from the specified string.
 */
- (void)loadUrlString:(NSString *)urlString;

/**
 Set to YES to allow support for landscape orientation.  Default is NO;
 */
@property (nonatomic, assign) BOOL isLandscapeOrientationSupported;

@end
