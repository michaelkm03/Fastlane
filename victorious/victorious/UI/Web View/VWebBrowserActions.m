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
#import "VFacebookManager.h"

@import Social;
@import MessageUI;

@interface VWebBrowserActions() <MFMessageComposeViewControllerDelegate>

@end

@implementation VWebBrowserActions

- (void)showInViewController:(UIViewController *)viewController withCurrentUrl:(NSURL *)url titleText:(NSString *)title descriptionText:(NSString *)description
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:nil
                                                       onCancelButton:nil
                                               destructiveButtonTitle:nil
                                                  onDestructiveButton:nil
                                           otherButtonTitlesAndBlocks:nil];
    
    [actionSheet addButtonWithTitle:NSLocalizedString( @"ShareFacebook", nil) block:^
     {
         [[VFacebookManager sharedFacebookManager] shareLink:url description:description name:title previewUrl:url];
     }];
    
    if ( [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] )
    {
        [actionSheet addButtonWithTitle:NSLocalizedString( @"ShareTwitter", nil) block:^
         {
             SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
             if ( title != nil )
             {
                 [controller setInitialText:title];
             }
             [controller addURL:url];
             [viewController presentViewController:controller animated:YES completion:nil];
         }];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString( @"OpenSafari", nil) block:^
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)),
                        dispatch_get_main_queue(), ^
                        {
                            [[UIApplication sharedApplication] openURL:url];
                        });
     }];
    
    
    if ( [MFMessageComposeViewController canSendText] )
    {
        [actionSheet addButtonWithTitle:NSLocalizedString( @"ShareSMS", nil) block:^
         {
             NSString *message = nil;
             if ( title != nil )
             {
                 message = [NSString stringWithFormat:@"%@\n%@", title, url.absoluteString];
             }
             else
             {
                 message = [NSString stringWithFormat:@"%@", url.absoluteString];
             }
             MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
             controller.messageComposeDelegate = self;
             if ( message != nil )
             {
                 [controller setBody:message];
             }
             [viewController presentViewController:controller animated:YES completion:nil];
         }];
    }
    
    // Setup cancel button here to ensure it is on the bottom of the action sheet
    [actionSheet addButtonWithTitle:NSLocalizedString( @"Cancel", nil)];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    [actionSheet showInView:viewController.view];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult )result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            break;
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
