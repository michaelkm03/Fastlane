//
//  VDeeplinkManager.m
//  victorious
//
//  Created by Will Long on 6/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDeeplinkManager.h"

#import "VObjectManager+Sequence.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Login.h"
#import "VSettingManager.h"
#import "VUserManager.h"

#import "VConversation.h"
#import "VUser.h"
#import "VSequence.h"

#import "VRootViewController.h"
#import "VUserProfileViewController.h"
#import "VInboxContainerViewController.h"
#import "VMessageContainerViewController.h"
#import "VCommentsContainerViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VEnterResetTokenViewController.h"
#import "VNewContentViewController.h"
#import "VMultipleStreamViewController.h"
#import "VStreamCollectionViewController.h"


static NSString * const kVContentDeeplinkScheme = @"//content/";

@implementation VDeeplinkManager

+ (instancetype)sharedManager
{
    static  VDeeplinkManager  *sharedManager;
    static  dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,
                  ^{
                      sharedManager = [[self alloc] init];
                  });
    
    return sharedManager;
}

- (void)handleOpenURL:(NSURL *)aURL
{
    NSString *linkString = [aURL resourceSpecifier];
    
    if (!linkString)
    {
        return;
    }
    
    for (NSString *pattern in [[self deepLinkPatterns] allKeys])
    {
        NSRegularExpression    *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:nil];
        
        NSTextCheckingResult *result = [regex firstMatchInString:linkString
                                                         options:NSMatchingAnchored
                                                           range:NSMakeRange(0, linkString.length)];
        
        if (result)
        {
            NSMutableArray *captures = [NSMutableArray array];
            for (NSUInteger i = 1; i < result.numberOfRanges; i++)
            {
                NSRange range = [result rangeAtIndex:i];
                NSString   *capture = [linkString substringWithRange:range];
                [captures addObject:capture];
            }
            
            //  This may look ugly, but this provides greater type safety than simply calling performSelector, allowing ARC to perform correctly.
            SEL selector = NSSelectorFromString([[self deepLinkPatterns] objectForKey:pattern]);
            IMP imp = [self methodForSelector:selector];
            void (*func)(id, SEL, NSArray *) = (void *)imp;
            
            func(self, selector, captures);
            
            return;
        }
    }
    [self showMissingContentAlert];
}

- (void)showMissingContentAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Content", nil)
                                                    message:NSLocalizedString(@"Missing Content Message", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)showLoginFailedAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginFail", nil)
                                                    message:NSLocalizedString(@"NotLoggedInMessage", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (NSDictionary *)deepLinkPatterns
{
    return @{
             @"//content/(\\d+)"                : @"handleContentURL:",
             @"//comment/(\\d+)"                : @"handleCommentURL:",
             @"//profile/(\\d+)"                : @"handleProfileURL:",
             @"//inbox/(\\d+)"                  : @"handleConversationURL:",
             @"//resetpassword/([a-zA-Z0-9]+)/([a-zA-Z0-9]+)"   : @"handleResetPasswordURL:"
             };
}

- (void)handleContentURL:(NSArray *)captures
{
    NSString *sequenceId = ((NSString *)[captures firstObject]);
    if (!sequenceId)
    {
        [self showMissingContentAlert];
        return;
    }
    
    [[VObjectManager sharedManager] fetchSequenceByID:sequenceId
                                     successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         VSequence *sequence = (VSequence *)[resultObjects firstObject];
         VContentViewViewModel *contentViewModel = [[VContentViewViewModel alloc] initWithSequence:sequence];
         VNewContentViewController *contentViewController = [VNewContentViewController contentViewControllerWithViewModel:contentViewModel];
         UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
         contentNav.navigationBarHidden = YES;

         UIViewController *homeStream;
         if ([[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
         {
             homeStream = [VMultipleStreamViewController homeStream];
             contentViewController.delegate = (VMultipleStreamViewController *)homeStream;
         }
         else
         {
             homeStream = [VStreamCollectionViewController homeStreamCollection];
             contentViewController.delegate = (VStreamCollectionViewController *)homeStream;
         }
         
         VRootViewController *root = [VRootViewController rootViewController];
         [root transitionToNavStack:@[homeStream]];
         [homeStream presentViewController:contentNav
                                  animated:YES
                                completion:nil];
     }
                                        failBlock:^(NSOperation *operation, NSError *error)
     {
         VLog(@"Failed with error: %@", error);
         [self showMissingContentAlert];
     }];
}

- (void)handleProfileURL:(NSArray *)captures
{
    NSNumber *userID = @(((NSString *)[captures firstObject]).intValue);
    if (!userID)
    {
        [self showMissingContentAlert];
        return;
    }
    
    [[VObjectManager sharedManager] fetchUser:(NSNumber *)userID
                             withSuccessBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         VUserProfileViewController *profileVC = [VUserProfileViewController userProfileWithUser:[resultObjects firstObject]];
         
         UIViewController *homeStream;
         if ([[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
         {
             homeStream = [VMultipleStreamViewController homeStream];
         }
         else
         {
             homeStream = [VStreamCollectionViewController homeStreamCollection];
         }
         
         VRootViewController *root = [VRootViewController rootViewController];
         [root transitionToNavStack:@[homeStream]];
         [homeStream.navigationController pushViewController:profileVC animated:YES];
     }
                                    failBlock:^(NSOperation *operation, NSError *error)
     {
         VLog(@"Failed with error: %@", error);
         [self showMissingContentAlert];
     }];
}

- (void)handleConversationURL:(NSArray *)captures
{
    NSNumber *conversationId = @(((NSString *)[captures firstObject]).intValue);
    if (!conversationId)
    {
        [self showMissingContentAlert];
        return;
    }
    
    if ([VObjectManager sharedManager].authorized)
    {
        [self goToConversation:conversationId];
    }
    else
    {
        [[VUserManager sharedInstance] loginViaSavedCredentialsOnCompletion:^(VUser *user, BOOL created)
         {
             [self goToConversation:conversationId];
         }
                                                                    onError:^(NSError *error)
         {
             [self showLoginFailedAlert];
         }];
    }
}

- (void)goToConversation:(NSNumber *)conversationId
{
    [[VObjectManager sharedManager] conversationByID:conversationId
                                        successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         VConversation *conversation = (VConversation *)[resultObjects firstObject];
         VInboxContainerViewController *inbox = [VInboxContainerViewController inboxContainer];
         VMessageContainerViewController *messageVC = [VMessageContainerViewController messageViewControllerForUser:conversation.user];
         
         VRootViewController *root = [VRootViewController rootViewController];
         [root transitionToNavStack:@[inbox]];
         [inbox.navigationController pushViewController:messageVC animated:YES];
     }
                                           failBlock:^(NSOperation *operation, NSError *error)
     {
         VLog(@"Failed with error: %@", error);
         [self showMissingContentAlert];
     }];
}


- (void)handleCommentURL:(NSArray *)captures
{
    NSString *sequenceId = ((NSString *)[captures firstObject]);
    if (!sequenceId)
    {
        [self showMissingContentAlert];
        return;
    }
    
    [[VObjectManager sharedManager] fetchSequenceByID:sequenceId
                                         successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         VSequence *sequence = (VSequence *)[resultObjects firstObject];
         VContentViewViewModel *contentViewModel = [[VContentViewViewModel alloc] initWithSequence:sequence];
         VNewContentViewController *contentViewController = [VNewContentViewController contentViewControllerWithViewModel:contentViewModel];
         UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
         contentNav.navigationBarHidden = YES;
         
         UIViewController *homeStream;
         if ([[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
         {
             homeStream = [VMultipleStreamViewController homeStream];
             contentViewController.delegate = (VMultipleStreamViewController *)homeStream;
         }
         else
         {
             homeStream = [VStreamCollectionViewController homeStreamCollection];
             contentViewController.delegate = (VStreamCollectionViewController *)homeStream;
         }
         
         VCommentsContainerViewController *commentsContainer = [VCommentsContainerViewController commentsContainerView];
         commentsContainer.sequence = sequence;
         
         VRootViewController *root = [VRootViewController rootViewController];
         [root transitionToNavStack:@[homeStream]];
         [homeStream presentViewController:contentNav
                                  animated:YES
                                completion:^
         {
             [contentNav pushViewController:commentsContainer animated:YES];
         }];
     }
                                            failBlock:^(NSOperation *operation, NSError *error)
     {
         VLog(@"Failed with error: %@", error);
         [self showMissingContentAlert];
     }];
}

- (void)handleResetPasswordURL:(NSArray *)captures
{
    NSString *userToken = ((NSString *)[captures firstObject]);
    NSString *deviceToken = (NSString *)[captures lastObject];
    if (!userToken || !deviceToken)
    {
        [self showMissingContentAlert];
        return;
    }
    
    VRootViewController *root = [VRootViewController rootViewController];
    VEnterResetTokenViewController *enterTokenVC = [VEnterResetTokenViewController enterResetTokenViewController];
    enterTokenVC.deviceToken = deviceToken;
    enterTokenVC.userToken = userToken;
    
    [root.contentViewController pushViewController:enterTokenVC animated:YES];
}

#pragma mark - Deeplink generation

- (NSURL *)contentDeeplinkForSequence:(VSequence *)sequence
{
    //TODO: Fetch the actual deeplink prefix from the info.plist
    return [NSURL URLWithString:[[@"qa-mp:" stringByAppendingString:kVContentDeeplinkScheme] stringByAppendingPathComponent:sequence.remoteId]];
}

@end
