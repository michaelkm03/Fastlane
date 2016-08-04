//
//  VContentViewFactory.m
//  victorious
//
//  Created by Josh Hinman on 3/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentViewFactory.h"
#import "VContentViewViewModel.h"
#import "VNewContentViewController.h"
#import "VSequence+Fetcher.h"
#import "VWebBrowserViewController.h"
#import "VRootViewController.h"
#import "victorious-Swift.h"
#import "VDependencyManager+NavigationBar.h"
#import "VSequenceActionControllerDelegate.h"

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

- (UIViewController *)contentViewForContext:(ContentViewContext *)context
{
    return nil;
}

- (BOOL)canDisplaySequence:(VSequence *)sequence localizedReason:(NSString *__autoreleasing *)reason
{
    return YES;
}

- (UIViewController *)webContentViewControllerWithURL:(NSURL *)url
{
    return [self webContentViewControllerWithURL:url sequence:nil];
}

- (UIViewController *)webContentViewControllerWithURL:(NSURL *)url sequence:(VSequence *)sequence
{
    return nil;
}

@end

#pragma mark -

@implementation VDependencyManager (VContentViewFactory)

- (VContentViewFactory *)contentViewFactory
{
    return [self templateValueOfType:[VContentViewFactory class] forKey:kContentViewComponentKey];
}

- (VDependencyManager *)contentViewDependencyManager
{
    // TODO: We should not be extracting a dictionary here. Will refactory later with correct use of templateValueOfType:forKey
    NSDictionary *configuration = [self templateValueOfType:[NSDictionary class] forKey:kContentViewComponentKey];
    return [self childDependencyManagerWithAddedConfiguration:configuration];
}

@end
