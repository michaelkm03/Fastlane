//
//  VTwitterHelper.m
//  victorious
//
//  Created by Michael Sena on 5/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTwitterAccountsHelper.h"
#import "VPermissionsTrackingHelper.h"

// Selector
#import "VSelectorViewController.h"

@import Accounts;

@interface VTwitterAccountsHelper ()

@property (nonatomic, strong) VPermissionsTrackingHelper *permissionsTrackingHelper;

@end

@implementation VTwitterAccountsHelper

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        _permissionsTrackingHelper = [[VPermissionsTrackingHelper alloc] init];
    }
    return self;
}

- (void)selectTwitterAccountWithViewControler:(UIViewController *)viewControllerToPresentOnIfNeeded
                                completion:(VTwitterAccountsHelperCompletion)completion
{
    NSParameterAssert(completion != nil);
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType
                                     options:nil
                                  completion:^(BOOL granted, NSError *error)
     {
         if (!granted)
         {
             [self.permissionsTrackingHelper permissionsDidChange:VTrackingValueTwitterDidAllow permissionState:VTrackingValueDenied];
             [self twitterAccessNotGrantedWithCompletion:completion
                               viewControllerToPresentOn:viewControllerToPresentOnIfNeeded
                                                   error:error];
         }
         else
         {
             [self.permissionsTrackingHelper permissionsDidChange:VTrackingValueTwitterDidAllow permissionState:VTrackingValueTwitterDidAllow];
             NSArray *twitterAccounts = [account accountsWithAccountType:accountType];
             if (twitterAccounts.count > 0)
             {
                 [self twitterAccessGrantedWithAtLeastOneAccount:completion
                                       viewControllerToPresentOn:viewControllerToPresentOnIfNeeded
                                                           error:error];
             }
             else
             {
                 [self twitterAccessGrantedWithNoAccountsCompletion:completion
                                          viewControllerToPresentOn:viewControllerToPresentOnIfNeeded
                                                              error:error];
             }
         }
     }];
}

- (void)twitterAccessNotGrantedWithCompletion:(VTwitterAccountsHelperCompletion)completion
                    viewControllerToPresentOn:(UIViewController *)viewControllerToPresentOnIfNeeded
                                        error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
                       [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithTwitterDidFailDenied parameters:params];
                       
                       UIAlertController *accessNotGrantedAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"TwitterDeniedTitle", @"")
                                                                                                      message:NSLocalizedString(@"TwitterDenied", @"")
                                                                                               preferredStyle:UIAlertControllerStyleAlert];
                       [accessNotGrantedAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                                                 style:UIAlertActionStyleCancel
                                                                               handler:^(UIAlertAction *action)
                                                         {
                                                             if (completion != nil)
                                                             {
                                                                 completion(nil);
                                                             }
                                                         }]];
                       [viewControllerToPresentOnIfNeeded presentViewController:accessNotGrantedAlert
                                                                       animated:YES
                                                                     completion:nil];
                   });
}

- (void)twitterAccessGrantedWithNoAccountsCompletion:(VTwitterAccountsHelperCompletion)completion
                           viewControllerToPresentOn:(UIViewController *)viewControllerToPresentOnIfNeeded
                                               error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
                       [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithTwitterDidFailNoAccounts parameters:params];
                       
                       UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"NoTwitterTitle", @"")
                                                                                                message:NSLocalizedString(@"NoTwitterMessage", @"")
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                       UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                                                          style:UIAlertActionStyleCancel
                                                                        handler:^(UIAlertAction *action)
                                                  {
                                                      if (completion != nil)
                                                      {
                                                          completion(nil);
                                                      }
                                                  }];
                       [alertController addAction:okAction];
                       [viewControllerToPresentOnIfNeeded presentViewController:alertController
                                                                       animated:YES
                                                                     completion:nil];
                   });
}

- (void)twitterAccessGrantedWithAtLeastOneAccount:(VTwitterAccountsHelperCompletion)completion
                        viewControllerToPresentOn:(UIViewController *)viewControllerToPresentOnIfNeeded
                                            error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *accounts = [account accountsWithAccountType:accountType];
        
        if (accounts.count == 1)
        {
            completion([accounts firstObject]);
            return;
        }
        
        // Select from n twitter accounts
        VSelectorViewController *selectorVC = [VSelectorViewController selectorViewControllerWithItemsToSelectFrom:accounts
                                                                                                withConfigureBlock:^(UITableViewCell *cell, ACAccount *account)
                                               {
                                                   cell.textLabel.text = account.username;
                                                   cell.detailTextLabel.text = account.accountDescription;
                                               }
                                                                                                        completion:^(id selectedItem)
                                               {
                                                   [viewControllerToPresentOnIfNeeded dismissViewControllerAnimated:YES
                                                                                                         completion:^
                                                    {
                                                        completion(selectedItem);
                                                    }];
                                               }];
        selectorVC.navigationItem.prompt = NSLocalizedString(@"SelectTwitter", @"");
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:selectorVC];
        [viewControllerToPresentOnIfNeeded presentViewController:navController
                                                        animated:YES
                                                      completion:nil];
    });
}

@end
