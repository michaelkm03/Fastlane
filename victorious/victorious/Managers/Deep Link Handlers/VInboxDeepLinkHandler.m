//
//  VInboxDeepLinkHandler.m
//  victorious
//
//  Created by Patrick Lynch on 4/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInboxDeepLinkHandler.h"
#import "NSURL+VPathHelper.h"
#import "VConversation.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+DirectMessaging.h"
#import "VInboxContainerViewController.h"
#import "VInboxViewController.h"

@implementation VInboxDeepLinkHandler

- (BOOL)canDisplayContentForDeeplinkURL:(NSURL *)url
{
    return [url.host isEqualToString:@"inbox"] && [[url v_firstNonSlashPathComponent] integerValue] > 0;
}

- (BOOL)requiresAuthorization
{
    return YES;
}

- (BOOL)displayContentForDeeplinkURL:(NSURL *)url completion:(VDeeplinkHandlerCompletionBlock)completion
{
    if ( ![self canDisplayContentForDeeplinkURL:url] )
    {
        return NO;
    }
    
#warning See about refactoring this code to a synchronous version that returns a view controller immediately and lets that view controller handle loading the conversation once it it has been loaded and presented.
    NSInteger conversationID = [[url v_firstNonSlashPathComponent] integerValue];
    [[VObjectManager sharedManager] conversationByID:@(conversationID)
                                        successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         VConversation *conversation = (VConversation *)[resultObjects firstObject];
         if ( conversation == nil )
         {
             completion( nil );
         }
         else
         {
             completion( self.inboxContainerViewController );
             dispatch_async(dispatch_get_main_queue(), ^(void)
                            {
                                [self.inboxContainerViewController.inboxViewController displayConversationForUser:conversation.user];
                            });
         }
     }
                                           failBlock:^(NSOperation *operation, NSError *error)
     {
         VLog( @"Failed to load conversation with error: %@", [error localizedDescription] );
         completion( nil) ;
     }];
    
    return YES;
}

@end
