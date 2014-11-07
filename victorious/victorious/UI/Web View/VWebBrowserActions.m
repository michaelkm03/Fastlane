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

@implementation VWebBrowserActions

- (void)showInViewController:(UIViewController *)viewController withSequence:(VSequence *)sequence
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString( @"Cancel", nil)
                                                       onCancelButton:nil
                                               destructiveButtonTitle:nil
                                                  onDestructiveButton:nil
                                           otherButtonTitlesAndBlocks:nil];
    
    [actionSheet addButtonWithTitle:NSLocalizedString( @"Share", nil) block:^
     {
         //Remove the styling for the mail view.
         [[VThemeManager sharedThemeManager] removeStyling];
         
         VFacebookActivity *fbActivity = [[VFacebookActivity alloc] init];
         NSArray *acitivtyItems = @[ sequence,
                                     @"Share text",
                                     [NSURL URLWithString:sequence.webContentUrl] ];
         UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:acitivtyItems
                                                                                              applicationActivities:@[ fbActivity ]];
         
         NSString *emailSubject = [NSString stringWithFormat:NSLocalizedString(@"EmailShareSubjectFormat", nil), [[VThemeManager sharedThemeManager] themedStringForKey:kVChannelName]];
         [activityViewController setValue:emailSubject forKey:@"subject"];
         activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
         activityViewController.completionHandler = ^(NSString *activityType, BOOL completed)
         {
             [[VThemeManager sharedThemeManager] applyStyling];
             NSDictionary *params = @{ VTrackingKeySequenceCategory : sequence.category,
                                       VTrackingKeyActivityType : activityType };
             [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidShare parameters:params];
         };
         
         [viewController presentViewController:activityViewController
                                      animated:YES
                                    completion:nil];
     }];
    [actionSheet addButtonWithTitle:NSLocalizedString( @"Email Link", nil) block:^
     {
         
     }];
    [actionSheet addButtonWithTitle:NSLocalizedString( @"Copy Link", nil) block:^
     {
         
     }];
    [actionSheet addButtonWithTitle:NSLocalizedString( @"Open In Safari", nil) block:^
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)),
                        dispatch_get_main_queue(), ^
                        {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sequence.webContentUrl]];
                        });
     }];
    
    [actionSheet showInView:viewController.view];
}

@end
