//
//  VContentViewFactory.m
//  victorious
//
//  Created by Josh Hinman on 3/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentViewFactory.h"
#import "VContentViewViewModel.h"
#import "VNavigationController.h"
#import "VNewContentViewController.h"
#import "VSequence+Fetcher.h"
#import "VWebBrowserViewController.h"
#import "NSURL+VCustomScheme.h"
#import "VRootViewController.h"

static NSString * const kContentViewComponentKey = @"contentView";

@interface VContentViewFactory ()

@property (nonatomic, readonly) VDependencyManager *dependencyManager;

@end

@implementation VContentViewFactory

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (UIViewController *)contentViewForSequence:(VSequence *)sequence commentID:(NSNumber *)commentID placeholderImage:(UIImage *)placeholderImage
{
    if ( [sequence isWebContent] )
    {
        NSURL *sequenceContentURL = [NSURL URLWithString:sequence.webContentUrl];
        return [self webContentViewControllerWithURL:sequenceContentURL sequence:sequence];
    }
    
    VContentViewViewModel *contentViewModel = [[VContentViewViewModel alloc] initWithSequence:sequence depenencyManager:self.dependencyManager];
    contentViewModel.deepLinkCommentId = commentID;
    VNewContentViewController *contentViewController = [VNewContentViewController contentViewControllerWithViewModel:contentViewModel dependencyManager:self.dependencyManager];
    contentViewController.placeholderImage = placeholderImage;
    
    if ( contentViewController == nil )
    {
        return nil;
    }
    VNavigationController *contentNav = [[VNavigationController alloc] initWithDependencyManager:self.dependencyManager];
    contentNav.innerNavigationController.viewControllers = @[contentViewController];
    contentNav.innerNavigationController.navigationBarHidden = YES;
    return contentNav;
}

- (BOOL)canDisplaySequence:(VSequence *)sequence localizedReason:(NSString *__autoreleasing *)reason
{
    if ( [sequence isWebContent] )
    {
        NSURL *sequenceContentURL = [NSURL URLWithString:sequence.webContentUrl];
        if ( [sequenceContentURL v_isThisAppGenericScheme] )
        {
            [[VRootViewController rootViewController].deepLinkReceiver receiveDeeplink:sequenceContentURL];
            return YES;
        }
        else if ( [sequenceContentURL v_hasCustomScheme] )
        {
            if ( [[UIApplication sharedApplication] canOpenURL:sequenceContentURL] )
            {
                return YES;
            }
            else
            {
                if ( reason != nil )
                {
                    *reason = NSLocalizedString(@"Sorry, I can't display that right now", @"User has tapped a link that goes nowhere");
                }
                return NO;
            }
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return YES;
    }
}

- (UIViewController *)webContentViewControllerWithURL:(NSURL *)url
{
    return [self webContentViewControllerWithURL:url sequence:nil];
}

- (UIViewController *)webContentViewControllerWithURL:(NSURL *)url sequence:(VSequence *)sequence
{
    if ( [url v_isThisAppGenericScheme] )
    {
        [[VRootViewController rootViewController].deepLinkReceiver receiveDeeplink:url];
        return nil;
    }
    else if ( [url v_hasCustomScheme] )
    {
        [[UIApplication sharedApplication] openURL:url];
        return nil;  return nil;
    }
    else
    {
        VWebBrowserViewController *viewController = [VWebBrowserViewController newWithDependencyManager:self.dependencyManager];
        viewController.sequence = sequence;
        if ( url != nil )
        {
            [viewController loadUrl:url];
        }
        return viewController;
    }
    return nil;
}

@end

#pragma mark -

@implementation VDependencyManager (VContentViewFactory)

- (VContentViewFactory *)contentViewFactory
{
    return [self templateValueOfType:[VContentViewFactory class] forKey:kContentViewComponentKey];
}

@end