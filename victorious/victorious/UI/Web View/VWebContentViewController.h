//
//  VWebContentViewController.h
//  victorious
//
//  Recreated by Lawrence H. Leach on 08/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebViewDelegate.h"

@interface VWebContentViewController : UIViewController

@property (nonatomic, strong) NSURL *urlToView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) VWebViewDelegate *webViewDelegate;

@end
