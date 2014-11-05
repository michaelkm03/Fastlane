//
//  VNavigationWebBrowserHeader.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNavigationWebBrowserHeader.h"



@interface VNavigationWebBrowserHeader ()

@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelSubtitle;

@property (nonatomic, weak) IBOutlet UIButton *buttonBack;
@property (nonatomic, weak) IBOutlet UIButton *buttonNext;
@property (nonatomic, weak) IBOutlet UIButton *buttonOpenURL;

@end

@implementation VNavigationWebBrowserHeader

- (void)viewDidLoad
{
    [super viewDidLoad];
}

 -(void)setTitle:(NSString *)title
{
    self.labelTitle.text = title;
}

- (void)setURL:(NSURL *)URL
{
    _URL = URL;
    
    if ( !_URL )
    {
        self.buttonOpenURL.enabled = NO;
        self.labelSubtitle.text = nil;
    }
    else
    {
        self.buttonOpenURL.enabled = YES;
        self.labelSubtitle.text = URL.absoluteString;
    }
}

- (void)setCanGoBack:(BOOL)canGoBack
{
    _canGoBack = canGoBack;
    self.buttonBack.enabled = canGoBack;
}

- (void)setCanGoForward:(BOOL)canGoForward
{
    _canGoForward = canGoForward;
    self.buttonNext.enabled = canGoForward;
}

- (IBAction)backSelected:(id)sender
{
    if ( self.delegate )
    {
        [self.delegate didGoBack];
    }
}

- (IBAction)forwardSelected:(id)sender
{
    if ( self.delegate )
    {
        [self.delegate didGoForward];
    }
}

- (IBAction)viewInBrowserSelected:(id)sender
{
    if ( self.URL != nil )
    {
        [[UIApplication sharedApplication] openURL:self.URL];
    }
}

- (IBAction)exitSelected:(id)sender
{
    if ( self.delegate )
    {
        [self.delegate didExit];
    }
}

@end
