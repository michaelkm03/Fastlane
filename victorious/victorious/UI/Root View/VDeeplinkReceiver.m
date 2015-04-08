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

#import <KVOController/FBKVOController.h>

#define FORCE_DEEPLINK 1

@interface VDeeplinkReceiver()

@property (nonatomic, strong) VAuthorizedAction *authorizedAction;
@property (nonatomic, readonly) VScaffoldViewController *scaffold;
@property (nonatomic, assign, readonly) BOOL canNavigateToDeepLink;

@end

@implementation VDeeplinkReceiver

- (instancetype)init
{
    self = [super init];
    if (self)
    {
#if FORCE_DEEPLINK
#warning FORCE_DEEPLINK is activated.  A hardcoded deeplink will automatically open with each app launch
        //NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://inbox/491"];
        NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://content/11377"];
        //NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://comment/11377/7511"];
        //NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://profile/1677"];
        //NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://discover/"];
        [self performSelector:@selector(receiveDeeplink:) withObject:testDeepLinkURL afterDelay:5.0];
#endif
    }
    return self;
}

- (void)dealloc
{
    [self.KVOController unobserve:self];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    if ( self.scaffold.hasBeenShown )
    {
        [self receiveQueuedDeeplink];
        return;
    }
    
    [self.KVOController unobserve:self];
    [self.KVOController observe:self
                        keyPath:@"scaffold.hasBeenShown"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [self receiveQueuedDeeplink];
     }];
}

- (void)receiveDeeplink:(NSURL *)url
{
    if ( self.canNavigateToDeepLink )
    {
        [self navigateToDeeplinkURL:url];
    }
    else
    {
        self.queuedURL = url;
    }
}

- (VScaffoldViewController *)scaffold
{
    return [self.dependencyManager scaffoldViewController];
}

- (BOOL)canNavigateToDeepLink
{
    VScaffoldViewController *scaffold = [self.dependencyManager scaffoldViewController];
    return scaffold != nil && scaffold.hasBeenShown;
}

- (void)receiveQueuedDeeplink
{
    if ( self.queuedURL != nil )
    {
        [self navigateToDeeplinkURL:self.queuedURL];
        self.queuedURL = nil;
    }
}

- (void)navigateToDeeplinkURL:(NSURL *)url
{
    if ( self.scaffold.presentedViewController != nil )
    {
        [self.scaffold dismissViewControllerAnimated:YES completion:^(void)
         {
             [self navigateToDeeplinkURL:url];
         }];
        return;
    }
    
    NSArray *possibleDeeplinkSupporters = [[self.scaffold navigationDestinations] arrayByAddingObject:self.scaffold];
    
    id<VMultipleContainer> parentContainer;
    id<VDeeplinkSupporter> supporter = [self deeplinkSupporterWithHandlerForURL:url
                                                                parentContainer:&parentContainer
                                                   fromRecursiveSearchInObjects:possibleDeeplinkSupporters];
    if ( supporter != nil && supporter.deeplinkHandler != nil )
    {
        if ( supporter.deeplinkHandler.requiresAuthorization )
        {
            VAuthorizationContext context = VAuthorizationContextDefault;
            if ( [supporter.deeplinkHandler respondsToSelector:@selector(authorizationContext)] )
            {
                context = supporter.deeplinkHandler.authorizationContext;
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
        }
        else if ( destinationViewController != nil )
        {
            [self.scaffold navigateToDestination:destinationViewController];
        }
    };
    if ( parentContainer != nil )
    {
        [parentContainer selectChild:(id<VMultipleContainerChild>)supporter];
    }
    [supporter.deeplinkHandler displayContentForDeeplinkURL:url completion:completion];
}

- (id<VDeeplinkSupporter>)deeplinkSupporterWithHandlerForURL:(NSURL *)url
                                             parentContainer:(id<VMultipleContainer> *)parentContainer
                                fromRecursiveSearchInObjects:(NSArray *)objects
{
    for ( id object in objects )
    {
        // Check first for conformance among and children of a VMultipleContainer
        if ( [object conformsToProtocol:@protocol(VMultipleContainer)] )
        {
            id<VMultipleContainer> multipleContainer = (id<VMultipleContainer>)object;
            id<VDeeplinkSupporter> supporter = [self deeplinkSupporterWithHandlerForURL:url
                                                                        parentContainer:parentContainer
                                                           fromRecursiveSearchInObjects:multipleContainer.children];
            id<VDeeplinkHandler> handler = supporter.deeplinkHandler;
            if ( handler != nil && [handler canDisplayContentForDeeplinkURL:url] )
            {
                *parentContainer = multipleContainer;
                return supporter;
            }
        }
        // Then check for conformation to VDeeplinkSupporter at top level, which may be nay object
        // including a VMultipleContainerViewController who supports deeplinks but whose children do not
        if ( [object conformsToProtocol:@protocol(VDeeplinkSupporter)] )
        {
            id<VDeeplinkSupporter> supporter = (id<VDeeplinkSupporter>)object;
            if ( [supporter conformsToProtocol:@protocol(VDeeplinkSupporter)] )
            {
                id<VDeeplinkHandler> handler = supporter.deeplinkHandler;
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
