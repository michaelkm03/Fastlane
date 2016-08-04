//
//  VWebBrowserActions.m
//  victorious
//
//  Created by Patrick Lynch on 11/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "victorious-Swift.h"
#import "VWebBrowserActions.h"

@import Social;
@import MessageUI;

@interface VWebBrowserActions() <MFMessageComposeViewControllerDelegate>

@end

@implementation VWebBrowserActions

- (void)showInViewController:(UIViewController *)viewController withCurrentUrl:(NSURL *)url titleText:(NSString *)title descriptionText:(NSString *)description
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *shareFacebookButtonTitle = NSLocalizedString( @"ShareFacebook", nil);
    
    if ( ![AgeGate isAnonymousUser] || [AgeGate isWebViewActionItemAllowedForActionName:shareFacebookButtonTitle] )
    {
        [alertController addAction:[UIAlertAction actionWithTitle:shareFacebookButtonTitle
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
                                    {
                                        FBSDKShareLinkContent *link = [[FBSDKShareLinkContent alloc] init];
                                        link.contentURL = url;
                                        [[VFacebookHelper shareDialogWithContent:link mode:self.shareMode] show];
                                    }]];
    }
    
    if ( [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] )
    {
        NSString *shareTwitterButtonTitle = NSLocalizedString( @"ShareTwitter", nil);
        
        if ( ![AgeGate isAnonymousUser] || [AgeGate isWebViewActionItemAllowedForActionName:shareTwitterButtonTitle] )
        {
            [alertController addAction:[UIAlertAction actionWithTitle:shareTwitterButtonTitle
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action)
                                        {
                                            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                                            if ( title != nil )
                                            {
                                                [controller setInitialText:title];
                                            }
                                            [controller addURL:url];
                                            [viewController presentViewController:controller animated:YES completion:nil];
                                        }]];
        }
    }
    
    NSString *openSafariButtonTitle = NSLocalizedString( @"OpenSafari", nil);
    if ( ![AgeGate isAnonymousUser] || [AgeGate isWebViewActionItemAllowedForActionName:openSafariButtonTitle] )
    {
        [alertController addAction:[UIAlertAction actionWithTitle:openSafariButtonTitle
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
                                    {
                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)),
                                                       dispatch_get_main_queue(), ^
                                                       {
                                                           [[UIApplication sharedApplication] openURL:url];
                                                       });
                                        
                                    }]];
    }
    
    if ( [MFMessageComposeViewController canSendText] )
    {
        NSString *shareSMSButtonTitle = NSLocalizedString( @"ShareSMS", nil);
        if ( ![AgeGate isAnonymousUser] || [AgeGate isWebViewActionItemAllowedForActionName:shareSMSButtonTitle] )
        {
            [alertController addAction:[UIAlertAction actionWithTitle:shareSMSButtonTitle
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action)
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
                                        }]];
        }
    }
    
    // Setup cancel button here to ensure it is on the bottom of the action sheet
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [viewController presentViewController:alertController animated:YES completion:nil];
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
