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

#import "VConversation.h"
#import "VUser.h"
#import "VSequence.h"

#import "VStreamContainerViewController.h"
#import "VRootViewController.h"
#import "VUserProfileViewController.h"
#import "VInboxContainerViewController.h"
#import "VMessageContainerViewController.h"
#import "VCommentsContainerViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VEnterResetTokenViewController.h"

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
#warning  Implement with NCV
    [[VObjectManager sharedManager] fetchSequenceByID:sequenceId
                                     successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
//         VContentViewController *contentView = [VContentViewController instantiateFromStoryboard:@"Main"];
//         VStreamContainerViewController *homeContainer = [VStreamContainerViewController containerForStreamTable:[VStreamTableViewController homeStream]];
//         homeContainer.shouldShowHeaderLogo = YES;
//         
//         VSequence *sequence = (VSequence *)[resultObjects firstObject];
//         contentView.sequence = sequence;
//         
//         VRootViewController *root = [VRootViewController rootViewController];
//         [root transitionToNavStack:@[homeContainer]];
//         [homeContainer.navigationController pushViewController:contentView animated:YES];
     }
                                        failBlock:^(NSOperation *operation, NSError *error)
     {
//         VLog(@"Failed with error: %@", error);
//         [self showMissingContentAlert];
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
         
         VStreamContainerViewController *homeContainer = [VStreamContainerViewController containerForStreamTable:[VStreamTableViewController homeStream]];
         homeContainer.shouldShowHeaderLogo = YES;
         
         VRootViewController *root = [VRootViewController rootViewController];
         [root transitionToNavStack:@[homeContainer]];
         [homeContainer.navigationController pushViewController:profileVC animated:YES];
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
#warning Implement with NCV
//         VCommentsContainerViewController *commentsContainer = [VCommentsContainerViewController commentsContainerView];
//         VContentViewController *contentView = [VContentViewController instantiateFromStoryboard:@"Main"];
//         VStreamContainerViewController *homeContainer = [VStreamContainerViewController containerForStreamTable:[VStreamTableViewController homeStream]];
//         homeContainer.shouldShowHeaderLogo = YES;
//         
//         VSequence *sequence = (VSequence *)[resultObjects firstObject];
//         contentView.sequence = sequence;
//         commentsContainer.sequence = sequence;
//         
//         VRootViewController *root = [VRootViewController rootViewController];
//         [root transitionToNavStack:@[homeContainer, contentView]];
//         [contentView.navigationController pushViewController:commentsContainer animated:YES];
     }
                                            failBlock:^(NSOperation *operation, NSError *error)
     {
//         VLog(@"Failed with error: %@", error);
//         [self showMissingContentAlert];
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
