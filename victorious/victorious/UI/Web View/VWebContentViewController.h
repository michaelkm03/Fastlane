//
//  VWebContentViewController.h
//  victorious
//
//  Recreated by Lawrence H. Leach on 08/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

@class WKWebView;

@interface VWebContentViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, strong) NSURL *urlToView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) BOOL shouldShowLoadingState;
@property (nonatomic, assign) BOOL shouldShowNavigationButtons;

- (void)setFailureWithError:(NSError *)error;

#pragma mark - Actions

/**
 *  Calls dismissViewControllerAnimated:completion: on self. Can be hooked up to an action.
 */
- (void)dismissSelf;

@end
