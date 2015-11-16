//
//  VUserProfileNavigationDestination.m
//  victorious
//
//  Created by Josh Hinman on 11/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager+VObjectManager.h"
#import "VTabScaffoldViewController.h"
#import "VUserProfileNavigationDestination.h"
#import "VUserProfileViewController.h"
#import "VUser.h"
#import "VCoachmarkDisplayer.h"
#import "VProvidesNavigationMenuItemBadge.h"
#import "victorious-Swift.h"

@interface VUserProfileNavigationDestination () <VCoachmarkDisplayer, VProvidesNavigationMenuItemBadge>

@property (nonatomic, strong, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VUserProfileViewController *profileViewController;

@end

@implementation VUserProfileNavigationDestination

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

#pragma mark VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        [self createProfile];
        [self.profileViewController updateAccessoryItems];
    }
    return self;
}

- (void)createProfile
{
    if ( self.profileViewController == nil && [VUser currentUser] != nil )
    {
        self.profileViewController = [VUserProfileViewController userProfileWithUser:[VUser currentUser]
                                                                andDependencyManager:self.dependencyManager];
        self.profileViewController.representsMainUser = YES;
        self.profileViewController.viewTrackingClassOverride = [self class];
    }
}

#pragma mark - VNavigationDestination conformance

- (BOOL)shouldNavigateWithAlternateDestination:(id __autoreleasing *)alternateViewController
{
    [self createProfile];
    *alternateViewController = self.profileViewController;
    return YES;
}

- (UIViewController *)alternateViewController
{
    return self.profileViewController;
}

#pragma mark - VDeepLinkSupporter methods

- (id<VDeeplinkHandler>)deepLinkHandlerForURL:(NSURL *)url
{
    return [self.profileViewController deepLinkHandlerForURL:url];
}

#pragma mark - VCoachmarkDisplayer

- (NSString *)screenIdentifier
{
    return [self.dependencyManager stringForKey:VDependencyManagerIDKey];
}

#pragma mark - VProvidesNavigationMenuItemBadge

@synthesize badgeNumberUpdateBlock = _badgeNumberUpdateBlock;

- (void)setBadgeNumberUpdateBlock:(VNavigationMenuItemBadgeNumberUpdateBlock)badgeNumberUpdateBlock
{
    _badgeNumberUpdateBlock = badgeNumberUpdateBlock;
    self.profileViewController.badgeNumberUpdateBlock = badgeNumberUpdateBlock;
}

@end
