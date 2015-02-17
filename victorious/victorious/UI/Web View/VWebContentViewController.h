//
//  VWebContentViewController.h
//  victorious
//
//  Recreated by Lawrence H. Leach on 08/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WKWebView;

@interface VWebContentViewController : UIViewController

@property (nonatomic, strong) NSURL *urlToView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) BOOL shouldShowLoadingState;

- (void)setFailureWithError:(NSError *)error;

@end
