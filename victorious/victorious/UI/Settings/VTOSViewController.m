//
//  VTOSViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

@import WebKit;

#import "VTOSViewController.h"
#import "VObjectManager+Websites.h"

@implementation VTOSViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldShowLoadingState = YES;
    
    [[VObjectManager sharedManager] fetchToSWithCompletionBlock:^(NSOperation *completion, NSString *htmlString, NSError *error)
    {
        if ( !error )
        {
            [self.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://www.victorious.com/"]];
        }
        else
        {
            [self setFailureWithError:error];
        }
    }];
}

@end
