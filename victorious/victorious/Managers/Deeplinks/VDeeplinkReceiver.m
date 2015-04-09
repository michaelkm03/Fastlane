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

@interface VDeeplinkReceiver()

@property (nonatomic, strong) VAuthorizedAction *authorizedAction;
@property (nonatomic, readonly) VScaffoldViewController *scaffold;

@end

@implementation VDeeplinkReceiver

- (VScaffoldViewController *)scaffold
{
    return [self.dependencyManager scaffoldViewController];
}

- (BOOL)canReceiveDeeplinks
{
    return self.scaffold != nil;
}

- (void)receiveDeeplink:(NSURL *)url
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
