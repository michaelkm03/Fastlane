//
//  VUserProfileNavigationDestination.m
//  victorious
//
//  Created by Josh Hinman on 11/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSURL+VPathHelper.h"
#import "VDependencyManager+VObjectManager.h"
#import "VObjectManager+Users.h"
#import "VRootViewController.h"
#import "VScaffoldViewController.h"
#import "VUserProfileNavigationDestination.h"
#import "VUserProfileViewController.h"
#import "VUser.h"

static NSString * const kProfileDeeplinkHostComponent = @"profile";

@interface VUserProfileNavigationDestination ()

@property (nonatomic, strong, readonly) VDependencyManager *dependencyManager;

@end

@implementation VUserProfileNavigationDestination

#pragma mark - Initializers

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
{
    self = [super init];
    if (self)
    {
        _objectManager = objectManager;
    }
    return self;
}

#pragma mark VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [self initWithObjectManager:dependencyManager.objectManager];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

#pragma mark - VNavigationDestination conformance

- (BOOL)shouldNavigateWithAlternateDestination:(id __autoreleasing *)alternateViewController
{
    VUserProfileViewController *userProfileViewController = [VUserProfileViewController userProfileWithUser:self.objectManager.mainUser andDependencyManager:self.dependencyManager];
    userProfileViewController.representsMainUser = YES;
    if ( [userProfileViewController respondsToSelector:@selector(setDependencyManager:)] )
    {
        [userProfileViewController setDependencyManager:self.dependencyManager];
    }
    *alternateViewController = userProfileViewController;
    
    return YES;
}

#pragma mark - VDeeplinkHandler methods

- (BOOL)displayContentForDeeplinkURL:(NSURL *)url completion:(VDeeplinkHandlerCompletionBlock)completion
{
    if ( completion == nil )
    {
        return NO;
    }
    
    if ( [url.host isEqualToString:kProfileDeeplinkHostComponent] )
    {
        NSInteger userID = [[url v_firstNonSlashPathComponent] integerValue];
        if ( userID != 0 )
        {
            VUserProfileViewController *profileVC = [VUserProfileViewController rootDependencyProfileWithRemoteId:@(userID)];
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                completion(profileVC);
            });
            return YES;
        }
    }
    return NO;
}

@end
