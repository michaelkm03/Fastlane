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
#import "VConversationListViewController.h"
#import "VDependencyManager+VTabScaffoldViewController.h"
#import "victorious-swift.h"

@import MBProgressHUD;

@interface VInboxDeepLinkHandler()

@property (nonatomic, weak) VConversationListViewController *inboxViewController;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VInboxDeepLinkHandler

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
             inboxViewController:(VConversationListViewController *)inboxViewController
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
        NSParameterAssert( dependencyManager != nil );
        
        _inboxViewController = inboxViewController;
        NSParameterAssert( _inboxViewController != nil );
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (BOOL)canDisplayContentForDeeplinkURL:(NSURL *)url
{
    return [url.host isEqualToString:@"inbox"] && [[url v_firstNonSlashPathComponent] integerValue] > 0;
}

- (BOOL)requiresAuthorization
{
    return YES;
}

- (VAuthorizationContext)authorizationContext
{
    return self.inboxViewController.authorizationContext;
}

- (void)displayContentForDeeplinkURL:(NSURL *)url completion:(VDeeplinkHandlerCompletionBlock)completion
{
    if ( ![self canDisplayContentForDeeplinkURL:url] )
    {
        completion( NO, nil );
        return;
    }
    
    UIViewController *scaffoldViewController = (UIViewController *)[self.dependencyManager scaffoldViewController];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:scaffoldViewController.view animated:YES];
    
    NSInteger conversationID = [[url v_firstNonSlashPathComponent] integerValue];
    ConversationOperation *operation = [[ConversationOperation alloc] initWithConversationID:conversationID];
    [operation queueOn:operation.defaultQueue completionBlock:^(NSError *_Nullable error)
     {
         [hud hide:YES];
         
         VConversation *conversation = (VConversation *)operation.conversation;
         if ( error != nil || conversation == nil )
         {
             VLog( @"Failed to load conversation with error: %@", [error localizedDescription] );
             completion( NO, nil) ;
         }
         else
         {
             completion( YES, self.inboxViewController );
             [self.inboxViewController displayConversation:conversation animated:YES];
         }
     }];
}

@end
