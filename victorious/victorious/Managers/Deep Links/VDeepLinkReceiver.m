//
//  VDeeplinkReceiver.m
//  victorious
//
//  Created by Patrick Lynch on 4/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDeeplinkReceiver.h"
#import "VAuthorizedAction.h"
#import "VMultipleContainer.h"
#import "VDependencyManager+VObjectManager.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VDeeplinkHandler.h"

#define FORCE_DEEPLINK 0

@interface VDeeplinkReceiver()

@property (nonatomic, strong) VAuthorizedAction *authorizedAction;
@property (nonatomic, readonly) VScaffoldViewController *scaffold;
@property (nonatomic, strong) NSURL *queuedURL; ///< A deep link URL that came in before we were ready for it

@end

@implementation VDeeplinkReceiver

- (instancetype)init
{
    self = [super init];
    if (self)
    {
#if FORCE_DEEPLINK
#warning FORCE_DEEPLINK is activated.  A hardcoded deep link will automatically open with each app launch
        //NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://inbox/491"];
        //NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://content/11377"];
        //NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://comment/11377/7511"];
        //NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://profile/1677"];
        //NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://discover/"];
        [self performSelector:@selector(receiveDeeplink:) withObject:testDeepLinkURL afterDelay:0.0];
#endif
    }
    return self;
}

- (VScaffoldViewController *)scaffold
{
    return [self.dependencyManager scaffoldViewController];
}

- (BOOL)canReceiveDeeplinks
{
    return self.scaffold != nil;
}

- (void)queueDeeplink:(NSURL *)url
{
    self.queuedURL = url;
}

- (void)receiveDeeplink:(NSURL *)deepLink
{
    if ( self.canReceiveDeeplinks )
    {
        [self navigateToDeeplinkURL:deepLink];
    }
    else
    {
        self.queuedURL = deepLink;
    }
}

- (void)receiveQueuedDeeplink
{
    if ( self.queuedURL != nil )
    {
        [self receiveDeeplink:self.queuedURL];
        self.queuedURL = nil;
    }
}

- (void)navigateToDeeplinkURL:(NSURL *)url
{
    if ( self.scaffold.presentedViewController != nil )
    {
        [self.scaffold dismissViewControllerAnimated:YES completion:^(void)
         {
             [self receiveDeeplink:url];
         }];
        return;
    }
    
    NSArray *possibleDeeplinkSupporters = [[self.scaffold navigationDestinations] arrayByAddingObject:self.scaffold];
    
    id<VMultipleContainer> parentContainer;
    id<VDeeplinkSupporter> supporter = [self deepLinkSupporterWithHandlerForURL:url
                                                                parentContainer:&parentContainer
                                                   fromRecursiveSearchInObjects:possibleDeeplinkSupporters];
    if ( supporter != nil && supporter.deepLinkHandler != nil )
    {
        if ( supporter.deepLinkHandler.requiresAuthorization )
        {
            VAuthorizationContext context = VAuthorizationContextDefault;
            if ( [supporter.deepLinkHandler respondsToSelector:@selector(authorizationContext)] )
            {
                context = supporter.deepLinkHandler.authorizationContext;
            }
            typeof(self) __weak welf = self;
            [self.authorizedAction performFromViewController:self.scaffold context:context completion:^(BOOL authorized)
             {
                 if ( authorized )
                 {
                     [welf executeDeeplinkWithURL:url supporter:supporter parentContainer:parentContainer];
                 }
             }];
        }
        else
        {
            [self executeDeeplinkWithURL:url supporter:supporter parentContainer:parentContainer];
        }
    }
    else
    {
        [self showBadDeeplinkError];
    }
}

- (void)executeDeeplinkWithURL:(NSURL *)url supporter:(id<VDeeplinkSupporter>)supporter parentContainer:(id<VMultipleContainer>)parentContainer
{
    VDeeplinkHandlerCompletionBlock completion = ^( BOOL didSucceed, UIViewController *destinationViewController )
    {
        if ( !didSucceed )
        {
            [self showBadDeeplinkError];
            return;
        }
        
        if ( parentContainer != nil )
        {
            [self.scaffold navigateToDestination:parentContainer];
            [parentContainer selectChild:(id<VMultipleContainerChild>)supporter];
        }
        else if ( destinationViewController != nil )
        {
            [self.scaffold navigateToDestination:destinationViewController];
        }
    };
    [supporter.deepLinkHandler displayContentForDeeplinkURL:url completion:completion];
}

- (id<VDeeplinkSupporter>)deepLinkSupporterWithHandlerForURL:(NSURL *)url
                                             parentContainer:(id<VMultipleContainer> *)parentContainer
                                fromRecursiveSearchInObjects:(NSArray *)objects
{
    for ( id object in objects )
    {
        // Check first for conformance among and children of a VMultipleContainer
        if ( [object conformsToProtocol:@protocol(VMultipleContainer)] )
        {
            id<VMultipleContainer> multipleContainer = (id<VMultipleContainer>)object;
            id<VDeeplinkSupporter> supporter = [self deepLinkSupporterWithHandlerForURL:url
                                                                        parentContainer:parentContainer
                                                           fromRecursiveSearchInObjects:multipleContainer.children];
            id<VDeeplinkHandler> handler = supporter.deepLinkHandler;
            if ( handler != nil && [handler canDisplayContentForDeeplinkURL:url] )
            {
                *parentContainer = multipleContainer;
                return supporter;
            }
        }
        // Then check for conformationgit push to VDeeplinkSupporter at top level, which may be nay object
        // including a VMultipleContainerViewController who supports deepLinks but whose children do not
        if ( [object conformsToProtocol:@protocol(VDeeplinkSupporter)] )
        {
            id<VDeeplinkSupporter> supporter = (id<VDeeplinkSupporter>)object;
            if ( [supporter conformsToProtocol:@protocol(VDeeplinkSupporter)] )
            {
                id<VDeeplinkHandler> handler = supporter.deepLinkHandler;
                if ( handler != nil && [handler canDisplayContentForDeeplinkURL:url] )
                {
                    return supporter;
                }
            }
        }
    }
    return nil;
}

- (void)showBadDeeplinkError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Content", nil)
                                                    message:NSLocalizedString(@"Missing Content Message", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Authorized actions

- (VAuthorizedAction *)authorizedAction
{
    if ( _authorizedAction == nil )
    {
        _authorizedAction = [[VAuthorizedAction alloc] initWithObjectManager:[self.dependencyManager objectManager]
                                                           dependencyManager:self.dependencyManager];
    }
    return _authorizedAction;
}

@end
