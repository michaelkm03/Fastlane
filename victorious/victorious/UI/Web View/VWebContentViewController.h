//
//  VWebContentViewController.h
//  victorious
//
//  Recreated by Lawrence H. Leach on 08/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@interface VWebContentViewController : UIViewController <UIWebViewDelegate>

- (instancetype)initWithWebView:(UIWebView *)webView;

@property (nonatomic, strong) NSURL *urlToView;
@property (nonatomic, weak, readonly) IBOutlet UIWebView *webView;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *activitiyIndicator;

@end
