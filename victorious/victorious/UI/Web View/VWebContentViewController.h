//
//  VWebContentViewController.h
//  victorious
//
//  Recreated by Lawrence H. Leach on 08/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VWebContentViewController : UIViewController

@property (nonatomic, strong) NSURL *urlToView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, assign) BOOL shouldShowLoadingState;

- (void)addHeader;

- (void)addConstraintsToWebView:(UIWebView *)webView withHeaderView:(UIView *)headerView;

@end
