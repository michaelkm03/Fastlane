//
//  VTwitterConnectViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import Accounts;
@import Social;

#import "VTwitterConnectViewController.h"
#import "VObjectManager+Users.h"
#import "VInviteTwitterViewController.h"

@implementation VTwitterConnectViewController

- (IBAction)connect:(id)sender
{
    self.connectButton.userInteractionEnabled = NO;
    
    ACAccount*      __block twitterAccount;
    ACAccountStore*         accountStore = [[ACAccountStore alloc] init];
    ACAccountType*          twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:twitterAccountType
                                          options:nil
                                       completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             NSArray *accounts = [accountStore accountsWithAccountType:twitterAccountType];
             twitterAccount = [accounts lastObject];
             
             ACAccountCredential *fbCredential = [twitterAccount credential];
             NSString *accessToken = [fbCredential oauthToken];
             
             [[VObjectManager sharedManager] findFriendsBySocial:kVTwitterSocialSelector
                                                           token:accessToken
                                                          secret:nil
                                                withSuccessBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
              {
                  self.users = resultObjects;
                  [self performSegueWithIdentifier:@"toTwitterList" sender:self];
              }
                                                       failBlock:^(NSOperation* operation, NSError* error)
              {
                  
              }];
         }
         else
         {
             if (error.code == ACErrorAccountNotFound)
             {
                 SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                 [self presentViewController:composeViewController animated:NO completion:^{
                     [composeViewController dismissViewControllerAnimated:NO completion:nil];
                 }];
             }
             
         }
     }];
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toTwitterList"])
    {
        VInviteTwitterViewController*   twitterListViewController = (VInviteTwitterViewController *)segue.destinationViewController;
        twitterListViewController.users = self.users;
    }
}

@end
