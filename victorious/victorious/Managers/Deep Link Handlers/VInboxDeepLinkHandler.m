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

@interface VInboxDeepLinkHandler()

@property (nonatomic, weak) VInboxContainerViewController *inboxContainerViewController;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VInboxDeepLinkHandler

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
             inboxContainerViewController:(VInboxContainerViewController *)inboxContainerViewController
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
        NSParameterAssert( dependencyManager != nil );
        
        _inboxContainerViewController = inboxContainerViewController;
        NSParameterAssert( _inboxContainerViewController != nil );
    }
    return self;
}

- (BOOL)canDisplayContentForDeeplinkURL:(NSURL *)url
{
    return [url.host isEqualToString:@"inbox"] && [[url v_firstNonSlashPathComponent] integerValue] > 0;
}

- (BOOL)requiresAuthorization
{
    return YES;
}

- (void)displayContentForDeeplinkURL:(NSURL *)url completion:(VDeeplinkHandlerCompletionBlock)completion
{
    if ( ![self canDisplayContentForDeeplinkURL:url] )
    {
        completion( NO, nil );
        return;
    }
    
    NSInteger conversationID = [[url v_firstNonSlashPathComponent] integerValue];
    [[VObjectManager sharedManager] conversationByID:@(conversationID)
                                        successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         VConversation *conversation = (VConversation *)[resultObjects firstObject];
         if ( conversation == nil )
         {
             completion( NO, nil );
         }
         else
         {
             completion( YES, self.inboxContainerViewController );
             dispatch_async(dispatch_get_main_queue(), ^(void)
                            {
                                [self.inboxContainerViewController.inboxViewController displayConversationForUser:conversation.user];
                            });
         }
     }
                                           failBlock:^(NSOperation *operation, NSError *error)
     {
         VLog( @"Failed to load conversation with error: %@", [error localizedDescription] );
         completion( NO, nil) ;
     }];
}

@end
