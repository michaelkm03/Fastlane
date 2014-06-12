//
//  VFacebookConnectViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import Accounts;
@import Social;

#import "VFacebookConnectViewController.h"
#import "VInviteFacebookViewController.h"
#import "VObjectManager+Users.h"
#import "VConstants.h"

@implementation VFacebookConnectViewController

- (IBAction)connect:(id)sender
{
    self.connectButton.userInteractionEnabled = NO;

    ACAccount*      __block facebookAccount;
    ACAccountStore*         accountStore = [[ACAccountStore alloc] init];
    ACAccountType*          facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    [accountStore requestAccessToAccountsWithType:facebookAccountType
                                          options:@{
                                                    ACFacebookAppIdKey: [[NSBundle mainBundle] objectForInfoDictionaryKey:kFacebookAppIDKey],
                                                    ACFacebookPermissionsKey: @[@"email"] // Needed for first login
                                                    }
                                       completion:^(BOOL granted, NSError *error)
                                        {
                                            if (granted)
                                            {
                                                NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
                                                facebookAccount = [accounts lastObject];
                                                    
                                                ACAccountCredential *fbCredential = [facebookAccount credential];
                                                NSString *accessToken = [fbCredential oauthToken];
                                                
                                                [[VObjectManager sharedManager] findFriendsBySocial:kVFacebookSocialSelector
                                                                                              token:accessToken
                                                                                             secret:nil
                                                                                   withSuccessBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                                 {
                                                     self.users = resultObjects;
                                                     [self performSegueWithIdentifier:@"toFacebookList" sender:self];
                                                 }
                                                                                          failBlock:^(NSOperation* operation, NSError* error)
                                                 {
                                                     
                                                 }];
                                            }
                                            else
                                            {
                                                if (error.code == ACErrorAccountNotFound)
                                                {
                                                    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
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
    if ([segue.identifier isEqualToString:@"toFacebookList"])
    {
        VInviteFacebookViewController*   facebookListViewController = (VInviteFacebookViewController *)segue.destinationViewController;
        facebookListViewController.users = self.users;
    }
}

@end
