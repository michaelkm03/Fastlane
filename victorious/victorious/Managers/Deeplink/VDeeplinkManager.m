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
#import "VObjectManager+Pagination.h"

#import "VUser.h"

#import "VHomeStreamViewController.h"
#import "VStreamContainerViewController.h"
#import "VRootViewController.h"
#import "VContentViewController.h"
#import "VUserProfileViewController.h"
#import "VInboxContainerViewController.h"
#import "VCommentsContainerViewController.h"
#import "UIViewController+VSideMenuViewController.h"

@implementation VDeeplinkManager

+ (instancetype)sharedManager
{
    static  VDeeplinkManager*  sharedManager;
    static  dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,
                  ^{
                      sharedManager = [[self alloc] init];
                  });
    
    return sharedManager;
}


- (void)handleOpenURL:(NSURL *)aURL
{
    NSString*   linkString = [aURL resourceSpecifier];
    NSError*    error = NULL;
    
    if (!linkString)
        return;
    
    for (NSString* pattern in [[self deepLinkPatterns] allKeys])
    {
        NSRegularExpression*    regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:&error];
        
        NSTextCheckingResult *result = [regex firstMatchInString:linkString
                                                         options:NSMatchingAnchored
                                                           range:NSMakeRange(0, linkString.length)];
        
        if (result)
        {
            NSMutableArray* captures = [NSMutableArray array];
            for (int i=1; i < result.numberOfRanges; i++)
            {
                NSRange range = [result rangeAtIndex:i];
                NSString*   capture = [linkString substringWithRange:range];
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
             @"//inbox/(\\d+)"                  : @"handleConversationURL:"
             };
}

- (void)handleContentURL:(NSArray *)captures
{
    NSNumber* sequenceId = @(((NSString*)[captures firstObject]).intValue);
    if (!sequenceId)
    {
        [self showMissingContentAlert];
        return;
    }
    
    [[VObjectManager sharedManager] fetchSequence:sequenceId
                                     successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         VContentViewController* contentView = [VContentViewController sharedInstance];
         VStreamContainerViewController* homeContainer = [VStreamContainerViewController containerForStreamTable:[VHomeStreamViewController sharedInstance]];
         
         VSequence* sequence = (VSequence*)[resultObjects firstObject];
         contentView.sequence = sequence;
         
         VRootViewController* root = [VRootViewController rootViewController];
         [root transitionToNavStack:@[homeContainer]];
         [homeContainer.navigationController pushViewController:contentView animated:YES];
     }
                                        failBlock:^(NSOperation* operation, NSError* error)
     {
         VLog(@"Failed with error: %@", error);
         [self showMissingContentAlert];
     }];
}

- (void)handleProfileURL:(NSArray *)captures
{
    NSNumber* userID = @(((NSString*)[captures firstObject]).intValue);
    if (!userID)
    {
        [self showMissingContentAlert];
        return;
    }
    
    [[VObjectManager sharedManager] fetchUser:(NSNumber *)userID
                             withSuccessBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         VUserProfileViewController* profileVC;
         if ([VObjectManager sharedManager].mainUser && [userID isEqualToNumber:[VObjectManager sharedManager].mainUser.remoteId])
             profileVC = [VUserProfileViewController userProfileWithSelf];
         else
             profileVC = [VUserProfileViewController userProfileWithUser:[resultObjects firstObject]];
         
         VStreamContainerViewController* homeContainer = [VStreamContainerViewController containerForStreamTable:[VHomeStreamViewController sharedInstance]];
         VRootViewController* root = [VRootViewController rootViewController];
         [root transitionToNavStack:@[homeContainer]];
         [homeContainer.navigationController pushViewController:profileVC animated:YES];
     }
                                    failBlock:^(NSOperation* operation, NSError* error)
     {
         VLog(@"Failed with error: %@", error);
         [self showMissingContentAlert];
     }];
}

- (void)handleConversationURL:(NSArray *)captures
{
    [self showMissingContentAlert];
}

- (void)handleCommentURL:(NSArray *)captures
{
    NSNumber* sequenceId = @(((NSString*)[captures firstObject]).intValue);
    if (!sequenceId)
    {
        [self showMissingContentAlert];
        return;
    }
    
    [[VObjectManager sharedManager] fetchSequence:sequenceId
                                     successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         VCommentsContainerViewController* commentsContainer = [VCommentsContainerViewController commentsContainerView];
         VContentViewController* contentView = [VContentViewController sharedInstance];
         VStreamContainerViewController* homeContainer = [VStreamContainerViewController containerForStreamTable:[VHomeStreamViewController sharedInstance]];
         
         VSequence* sequence = (VSequence*)[resultObjects firstObject];
         contentView.sequence = sequence;
         commentsContainer.sequence = sequence;
         
         VRootViewController* root = [VRootViewController rootViewController];
         [root transitionToNavStack:@[homeContainer, contentView]];
         [contentView.navigationController pushViewController:commentsContainer animated:YES];
     }
                                        failBlock:^(NSOperation* operation, NSError* error)
     {
         VLog(@"Failed with error: %@", error);
         [self showMissingContentAlert];
     }];
}

@end
