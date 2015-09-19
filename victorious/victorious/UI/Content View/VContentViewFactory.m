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
#import "VDependencyManager+VTabScaffoldViewController.h"
@import SafariServices;

static NSString * const kContentViewComponentKey = @"contentView";
static NSString * const kSequenceIdKey = @"sequenceId";

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

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (UIViewController *)contentViewForSequence:(VSequence *)sequence inStreamWithID:(NSString *)streamId commentID:(NSNumber *)commentID placeholderImage:(UIImage *)placeholderImage
{
    if ( [sequence isWebContent] )
    {
        NSURL *sequenceContentURL = [NSURL URLWithString:sequence.webContentUrl];
        return [self webContentViewControllerWithURL:sequenceContentURL sequence:sequence];
    }
    
    VContentViewViewModel *contentViewModel = [[VContentViewViewModel alloc] initWithSequence:sequence streamID:streamId depenencyManager:self.dependencyManager];
    contentViewModel.deepLinkCommentId = commentID;
    
    NSDictionary *dic = @{ kSequenceIdKey : sequence.remoteId};
    
    VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:dic];
    VNewContentViewController *contentViewController = [VNewContentViewController contentViewControllerWithViewModel:contentViewModel dependencyManager:childDependencyManager];
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
        [[VRootViewController rootViewController] openURL:url];
        return nil;
    }
    else if ( [url v_hasCustomScheme] )
    {
        [[UIApplication sharedApplication] openURL:url];
        return nil;  return nil;
    }
    else
    {
        // Opens up the webview with SFSafariViewController in iOS9 and above
        NSOperatingSystemVersion iOS9 = {9, 0, 0};
        if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)] && [[NSProcessInfo new] isOperatingSystemAtLeastVersion:iOS9])
        {
            SFSafariViewController *webVC = (url != nil) ? [[SFSafariViewController alloc] initWithURL:url] : nil;
            
            return webVC;
        }
        
        // Opens up the webview with WKWebview in iOS 8
        VNavigationController *navigationController = [[VNavigationController alloc] initWithDependencyManager:self.dependencyManager];
        VWebBrowserViewController *viewController = [VWebBrowserViewController newWithDependencyManager:[self.dependencyManager dependencyManagerForNavigationBar]];
        viewController.isLandscapeOrientationSupported = YES;
        viewController.sequence = sequence;
        if ( url != nil )
        {
            [viewController loadUrl:url];
        }
        navigationController.innerNavigationController.viewControllers = @[viewController];
        return navigationController;
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