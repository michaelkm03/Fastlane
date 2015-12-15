//
//  VWebBrowserActions.m
//  victorious
//
//  Created by Patrick Lynch on 11/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "victorious-Swift.h"
#import "VWebBrowserActions.h"
#import "UIActionSheet+VBlocks.h"
#import "VSequence+Fetcher.h"

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
    
    NSString *shareFacebookButtonTitle = NSLocalizedString( @"ShareFacebook", nil);
    
    if ( ![AgeGate isAnonymousUser] || [AgeGate isWebViewActionItemAllowedForActionName:shareFacebookButtonTitle] )
    {
        [actionSheet addButtonWithTitle:shareFacebookButtonTitle block:^
         {
             FBSDKShareLinkContent *link = [[FBSDKShareLinkContent alloc] init];
             link.contentURL = url;
             [[VFacebookHelper shareDialogWithContent:link mode:self.shareMode] show];
         }];
    }
    
    if ( [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] )
    {
        NSString * shareTwitterButtonTitle = NSLocalizedString( @"ShareTwitter", nil);
        
        if ( ![AgeGate isAnonymousUser] || [AgeGate isWebViewActionItemAllowedForActionName:shareTwitterButtonTitle] )
        {
            [actionSheet addButtonWithTitle:shareTwitterButtonTitle block:^
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
    }
    
    NSString *openSafariButtonTitle = NSLocalizedString( @"OpenSafari", nil);
    if ( ![AgeGate isAnonymousUser] || [AgeGate isWebViewActionItemAllowedForActionName:openSafariButtonTitle] )
    {
        [actionSheet addButtonWithTitle:openSafariButtonTitle block:^
         {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)),
                            dispatch_get_main_queue(), ^
                            {
                                [[UIApplication sharedApplication] openURL:url];
                            });
         }];
    }
    
    if ( [MFMessageComposeViewController canSendText] )
    {
        NSString *shareSMSButtonTitle = NSLocalizedString( @"ShareSMS", nil);
        if ( ![AgeGate isAnonymousUser] || [AgeGate isWebViewActionItemAllowedForActionName:shareSMSButtonTitle] )
        {
            [actionSheet addButtonWithTitle:shareSMSButtonTitle block:^
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
