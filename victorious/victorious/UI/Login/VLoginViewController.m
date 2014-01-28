//
//  VLoginViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoginViewController.h"
#import "VProfileWithSocialViewController.h"
#import "VObjectManager+Login.h"
#import "VUser.h"

@import Accounts;
@import Social;

@interface VLoginViewController ()
@property (nonatomic, assign) VLoginType    loginType;
@end

@implementation VLoginViewController

+ (VLoginViewController *)loginViewController
{
    UIStoryboard*   storyboard  =   [UIStoryboard storyboardWithName:@"login" bundle:nil];
    
    return [storyboard instantiateInitialViewController];
}

- (void)facebookAccessDidFail
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [self presentViewController:composeViewController animated:NO completion:^{
            [composeViewController dismissViewControllerAnimated:NO completion:nil];
        }];
    });
}

- (IBAction)facebookClicked:(id)sender
{
    ACAccountStore * const accountStore = [[ACAccountStore alloc] init];
    ACAccountType * const accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];

    [accountStore requestAccessToAccountsWithType:accountType
                                          options:@{
                                                    ACFacebookAppIdKey: @"1374328719478033",
                                                    ACFacebookPermissionsKey: @[@"email"] // Needed for first login
                                                    }
                                       completion:^(BOOL granted, NSError *error)
    {
        if (!granted)
        {
            switch (error.code)
            {
                case ACErrorAccountNotFound:
                {
                    [self facebookAccessDidFail];
                    break;
                }
                default:
                {
                    [self didFailWithError:error];
                    break;
                }
            }
            
            return;
        }
        else
        {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            
            // It will always be the last object with single sign on
            ACAccount* facebookAccount = [accounts lastObject];
            ACAccountCredential *fbCredential = [facebookAccount credential];
            NSString *accessToken = [fbCredential oauthToken];
 
             VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
             {
                 if (![[resultObjects firstObject] isKindOfClass:[VUser class]])
                     [self didFailWithError:nil];
                 
                 [self didLoginWithUser:[resultObjects firstObject] withLoginType:kVLoginTypeFaceBook];
             };
             VFailBlock failed = ^(NSOperation* operation, NSError* error)
             {
                 [self didFailWithError:error];
                 VLog(@"Error in FB Login: %@", error);
             };

            [[VObjectManager sharedManager] loginToFacebookWithToken:accessToken
                                                        SuccessBlock:success
                                                           failBlock:failed];
        }
    }];
}

- (void)twitterAccessDidFail
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [self presentViewController:composeViewController animated:NO completion:^{
            [composeViewController dismissViewControllerAnimated:NO completion:nil];
        }];
    });
}

- (IBAction)twitterClicked:(id)sender
{
    ACAccountStore* account = [[ACAccountStore alloc] init];
    ACAccountType* accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
    {
         if (!granted)
         {
             switch (error.code)
             {
                 case ACErrorAccountNotFound:
                 {
                     [self twitterAccessDidFail];
                     break;
                 }
                 default:
                 {
                     [self didFailWithError:error];
                     break;
                 }
             }
             return;
         }
         else
         {
             NSArray *accounts = [account accountsWithAccountType:accountType];
             ACAccount *twitterAccount = [accounts lastObject];
             ACAccountCredential*  ftwCredential = [twitterAccount credential];
             NSString* accessToken = [ftwCredential oauthToken];
             VLog(@"Twitter Access Token: %@", accessToken);

             VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
             {
                 if (![[resultObjects firstObject] isKindOfClass:[VUser class]])
                     [self didFailWithError:nil];
                 
                 [self didLoginWithUser:[resultObjects firstObject] withLoginType:kVLoginTypeTwitter];
             };
             VFailBlock failed = ^(NSOperation* operation, NSError* error)
             {
                 [self didFailWithError:error];
                 VLog(@"Error in Twitter Login: %@", error);
             };
             
             [[VObjectManager sharedManager] loginToTwitterWithToken:accessToken
                                                        SuccessBlock:success
                                                           failBlock:failed];
         }
    }];
}

- (void)didLoginWithUser:(VUser*)mainUser withLoginType:(VLoginType)loginType
{
    VLog(@"Succesfully logged in as: %@", mainUser);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInChangedNotification object:mainUser];

    if (NO) //  priorUser
        [self dismissViewControllerAnimated:YES completion:NULL];
    else if (kVLoginTypeFaceBook == loginType)
        [self performSegueWithIdentifier:@"toProfileWithFacebook" sender:self];
    else if (kVLoginTypeTwitter == loginType)
        [self performSegueWithIdentifier:@"toProfileWithTwitter" sender:self];
}

- (void)didFailWithError:(NSError*)error
{
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginFail", @"")
                                                           message:error.localizedDescription
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                 otherButtonTitles:nil];
    [alert show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VProfileWithSocialViewController*   profileViewController = (VProfileWithSocialViewController *)segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"toProfileWithFacebook"])
    {
        profileViewController.loginType = kVLoginTypeFaceBook;
    }
    else if ([segue.identifier isEqualToString:@"toProfileWithTwitter"])
    {
        profileViewController.loginType = kVLoginTypeTwitter;
    }
}

@end
