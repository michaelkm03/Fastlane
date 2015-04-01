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
        return [self webContentViewControllerWithSequence:sequence];
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
        if ( [self isCustomScheme:sequenceContentURL] )
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

- (UIViewController *)webContentViewControllerWithSequence:(VSequence *)sequence
{
    NSURL *sequenceContentURL = [NSURL URLWithString:sequence.webContentUrl];
    if ( [self isCustomScheme:sequenceContentURL] )
    {
        [[UIApplication sharedApplication] openURL:sequenceContentURL];
        return nil;
    }
    else
    {
        VWebBrowserViewController *viewController = [VWebBrowserViewController newWithDependencyManager:self.dependencyManager];
        viewController.sequence = sequence;
        return viewController;
    }
}

- (BOOL)isCustomScheme:(NSURL *)url
{
    return [url.scheme rangeOfString:@"http"].location != 0;
}

@end

#pragma mark -

@implementation VDependencyManager (VContentViewFactory)

- (VContentViewFactory *)contentViewFactory
{
    return [self templateValueOfType:[VContentViewFactory class] forKey:kContentViewComponentKey];
}

@end