//
//  VDeeplinkReceiver.m
//  victorious
//
//  Created by Patrick Lynch on 4/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDeeplinkReceiver.h"
#import "VMultipleContainer.h"
#import "VDependencyManager+VTabScaffoldViewController.h"
#import "VDeeplinkHandler.h"
#import "VNavigationDestination.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VTabScaffoldViewController.h"
#import "VUser.h"
#import "victorious-Swift.h"

#define FORCE_DEEPLINK 0

@interface VDeeplinkReceiver()

@property (nonatomic, readonly) VTabScaffoldViewController *scaffold;
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
         NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://inbox/2694"];
        // NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://content/11377"];
        // NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://comment/11377/5618"];
        // NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://menu/4"];
        // NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://profile/3694"];
        // NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://discover/"];
        [self performSelector:@selector(receiveDeeplink:) withObject:testDeepLinkURL afterDelay:0.0];
#endif
    }
    return self;
}

- (VTabScaffoldViewController *)scaffold
{
    return [self.dependencyManager scaffoldViewController];
}

- (BOOL)canReceiveDeeplinks
{
    return self.scaffold != nil && [VCurrentUser user] != nil;
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
    if ( self.queuedURL != nil && self.canReceiveDeeplinks )
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
    
    NSMutableOrderedSet *navigationStack = [[NSMutableOrderedSet alloc] init];
    
    id<VDeeplinkSupporter> supporter = [self deepLinkSupporterWithHandlerForURL:url
                                                                navigationStack:&navigationStack
                                                   fromRecursiveSearchInObjects:possibleDeeplinkSupporters];
    id<VDeeplinkHandler> handler = [supporter deepLinkHandlerForURL:url];
    if ( supporter != nil && handler != nil )
    {
        if ( handler.requiresAuthorization )
        {
            [self executeDeeplinkWithURL:url supporter:supporter navigationStack:navigationStack.copy];
        }
        else
        {
            [self executeDeeplinkWithURL:url supporter:supporter navigationStack:navigationStack.copy];
        }
    }
    else
    {
        if ((url.host != nil) || (url.path != nil))
        {
            [self showBadDeeplinkError];
        }
    }
}

- (void)executeDeeplinkWithURL:(NSURL *)url supporter:(id<VDeeplinkSupporter>)supporter navigationStack:(NSOrderedSet *)navigationStack
{
    VDeeplinkHandlerCompletionBlock completion = ^( BOOL didSucceed, UIViewController *destinationViewController )
    {
        if ( !didSucceed )
        {
            [self showBadDeeplinkError];
            return;
        }
        
        if ( destinationViewController != nil )
        {
            // Re-order the navigation stack that we'll be executing as part of the deep link
            NSMutableOrderedSet *completeNavigationStack = [NSMutableOrderedSet orderedSetWithSet:navigationStack.reversedOrderedSet.set];
            [completeNavigationStack addObject:destinationViewController];
            
            id parentDestination = nil;
            for ( id destination in completeNavigationStack )
            {
                // If an item in here is a multiple container, instead of using `navigateToDestination:`,
                // we want to the destination as the seleted child in its parent multiple container
                if ( [parentDestination conformsToProtocol:@protocol(VMultipleContainer)] )
                {
                    id<VMultipleContainer> multipleContainer = parentDestination;
                    [multipleContainer selectChild:destination];
                }
                else
                {
                    [self.scaffold navigateToDestination:destination animated:NO];
                }
                parentDestination = destination;
            }
        }
    };
    
    id<VDeeplinkHandler> handler = [supporter deepLinkHandlerForURL:url];
    [handler displayContentForDeeplinkURL:url completion:completion];
}

- (id<VDeeplinkSupporter>)deepLinkSupporterWithHandlerForURL:(NSURL *)url
                                             navigationStack:(NSMutableOrderedSet **)navigationStack
                                fromRecursiveSearchInObjects:(NSArray *)objects
{
    for ( id object in objects )
    {
        if ( [object conformsToProtocol:@protocol(VNavigationDestination)] &&
             [object respondsToSelector:@selector(dependencyManager)] )
        {
            // Search accessory items for another deep link handler
            id<VNavigationDestination> navigationDestination = object;
            NSMutableArray *destinations = [[NSMutableArray alloc] init];
            for ( VNavigationMenuItem *menuItem in [navigationDestination.dependencyManager accessoryMenuItemsWithInheritance:NO] )
            {
                if ( menuItem.destination != nil )
                {
                    [destinations addObject:menuItem.destination];
                }
            }
            id<VDeeplinkSupporter> supporter = [self deepLinkSupporterWithHandlerForURL:url
                                                                        navigationStack:navigationStack
                                                           fromRecursiveSearchInObjects:destinations];
            id<VDeeplinkHandler> handler = [supporter deepLinkHandlerForURL:url];
            if ( handler != nil && [handler canDisplayContentForDeeplinkURL:url] )
            {
                [*navigationStack addObject:navigationDestination];
                return supporter;
            }
        }
        
        // Check first for conformance among and children of a VMultipleContainer
        if ( [object conformsToProtocol:@protocol(VMultipleContainer)] )
        {
            id<VMultipleContainer> multipleContainer = object;
            id<VDeeplinkSupporter> supporter = [self deepLinkSupporterWithHandlerForURL:url
                                                                        navigationStack:navigationStack
                                                           fromRecursiveSearchInObjects:multipleContainer.children];
            id<VDeeplinkHandler> handler = [supporter deepLinkHandlerForURL:url];
            if ( handler != nil && [handler canDisplayContentForDeeplinkURL:url] )
            {
                [*navigationStack addObject:multipleContainer];
                return supporter;
            }
        }
        // Then check for conformation to VDeeplinkSupporter at top level, which may be nay object
        // including a VMultipleContainerViewController who supports deepLinks but whose children do not
        if ( [object conformsToProtocol:@protocol(VDeeplinkSupporter)] )
        {
            id<VDeeplinkSupporter> supporter = object;
            if ( [supporter conformsToProtocol:@protocol(VDeeplinkSupporter)] )
            {
                id<VDeeplinkHandler> handler = [supporter deepLinkHandlerForURL:url];
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Missing Content", nil)
                                                                             message:NSLocalizedString(@"Missing Content Message", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [self.scaffold presentViewController:alertController animated:YES completion:nil];
}

@end
