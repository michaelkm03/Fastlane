//
//  VFindTwitterFriendsTableViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "TWAPIManager.h"
#import "VFindFriendsTableView.h"
#import "VFindTwitterFriendsTableViewController.h"
#import "VObjectManager+Users.h"

@import Accounts;

@implementation VFindTwitterFriendsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setConnectPromptLabelText:NSLocalizedString(@"FindTwitterFriends", @"")];
    [self.tableView setSafetyInfoLabelText:NSLocalizedString(@"TwitterSafety", @"")];
    [self.tableView.connectButton setTitle:NSLocalizedString(@"Connect to Twitter", @"") forState:UIControlStateNormal];
}

- (void)connectToSocialNetworkWithPossibleUserInteraction:(BOOL)userInteraction completion:(void (^)(BOOL, NSError *))completionBlock
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType  *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    if (!userInteraction && !twitterAccountType.accessGranted)
    {
        if (completionBlock)
        {
            completionBlock(NO, nil);
        }
        return;
    }
    
    [accountStore requestAccessToAccountsWithType:twitterAccountType
                                          options:nil
                                       completion:^(BOOL granted, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            if (granted)
            {
                NSArray *accounts = [accountStore accountsWithAccountType:twitterAccountType];
                if (completionBlock)
                {
                    if (accounts.count)
                    {
                        completionBlock(YES, nil);
                    }
                    else
                    {
                        completionBlock(NO, nil);
                        if (userInteraction)
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoTwitterTitle", @"")
                                                                            message:NSLocalizedString(@"NoTwitterMessage", @"")
                                                                           delegate:nil
                                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                  otherButtonTitles:nil];
                            [alert show];
                        }
                    }
                }
            }
            else
            {
                if (completionBlock)
                {
                    completionBlock(NO, error);
                }
            }
        });
    }];
}

- (void)loadFriendsFromSocialNetworkWithCompletion:(void (^)(NSArray *, NSError *))completionBlock
{
    if (!completionBlock)
    {
        return;
    }
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType  *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    if (!twitterAccountType.accessGranted)
    {
        completionBlock(nil, nil);
        return;
    }
    
    TWAPIManager *twitterApiManager = [[TWAPIManager alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
    {
        NSArray *accounts = [accountStore accountsWithAccountType:twitterAccountType];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        NSMutableArray *users = [[NSMutableArray alloc] init];
        NSError *__block anError = nil;
        BOOL     __block success = NO;
        
        for (ACAccount *account in accounts)
        {
            [twitterApiManager performReverseAuthForAccount:account
                                                withHandler:^(NSData *responseData, NSError *error)
            {
                if (error)
                {
                    anError = error;
                    dispatch_semaphore_signal(semaphore);
                    return;
                }
                
                NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                NSDictionary *parsedData = RKDictionaryFromURLEncodedStringWithEncoding(responseStr, NSUTF8StringEncoding);
                
                NSString *oauthToken = [parsedData objectForKey:@"oauth_token"];
                NSString *tokenSecret = [parsedData objectForKey:@"oauth_token_secret"];
                
                [[VObjectManager sharedManager] findFriendsBySocial:kVTwitterSocialSelector
                                                              token:oauthToken
                                                             secret:tokenSecret
                                                   withSuccessBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
                {
                    success = YES;
                    [users addObjectsFromArray:resultObjects];
                    dispatch_semaphore_signal(semaphore);
                }
                                                          failBlock:^(NSOperation *operation, NSError *error)
                {
                    anError = error;
                    dispatch_semaphore_signal(semaphore);
                }];
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            if (success)
            {
                completionBlock(users, nil);
            }
            else
            {
                completionBlock(nil, anError);
            }
        });
    });
}

- (NSString *)headerTextForNewFriendsSection
{
    return NSLocalizedString(@"TwitterFollowingSectionHeader", @"");
}

@end
