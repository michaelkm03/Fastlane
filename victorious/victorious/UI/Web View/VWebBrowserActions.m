//
//  VWebBrowserActions.m
//  victorious
//
//  Created by Patrick Lynch on 11/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebBrowserActions.h"
#import "UIActionSheet+VBlocks.h"
#import "VThemeManager.h"
#import "VFacebookActivity.h"
#import "VSequence+Fetcher.h"
#import "TUSafariActivity.h"

@implementation VWebBrowserActions

- (void)showInViewController:(UIViewController *)viewController withSequence:(VSequence *)sequence
{
    [[VThemeManager sharedThemeManager] applyStyling];
    
    NSArray *acitivtyItems = @[ sequence, sequence.description, [NSURL URLWithString:sequence.webContentUrl] ];
    TUSafariActivity *openInSafariActivity = [[TUSafariActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:acitivtyItems
                                                                                         applicationActivities:@[ openInSafariActivity ]];
    
    
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed)
    {
        if ( completed )
        {
            NSDictionary *params = @{ VTrackingKeySequenceCategory : sequence.category,
                                      VTrackingKeyActivityType : activityType };
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidShare parameters:params];
        }
    };
    
    [viewController presentViewController:activityViewController animated:YES completion:nil];
}

@end
