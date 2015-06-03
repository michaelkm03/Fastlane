//
//  VUserProfileNavigationDestination.m
//  victorious
//
//  Created by Josh Hinman on 11/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager+VObjectManager.h"
#import "VObjectManager+Users.h"
#import "VScaffoldViewController.h"
#import "VUserProfileNavigationDestination.h"
#import "VUserProfileViewController.h"
#import "VUser.h"
#import "VProfileDeeplinkHandler.h"
#import "VCoachmarkDisplayer.h"
#import "VProvidesNavigationMenuItemBadge.h"

@interface VUserProfileNavigationDestination () <VCoachmarkDisplayer, VProvidesNavigationMenuItemBadge>

@property (nonatomic, strong, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VUserProfileViewController *profileViewController;

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
        [self createProfile];
        [self.profileViewController updateAccessoryItems];
    }
    return self;
}

- (void)createProfile
{
    if ( self.profileViewController == nil )
    {
        self.profileViewController = [VUserProfileViewController userProfileWithUser:self.objectManager.mainUser
                                                                andDependencyManager:self.dependencyManager];
        self.profileViewController.representsMainUser = YES;
    }
}

#pragma mark - VNavigationDestination conformance

- (BOOL)shouldNavigateWithAlternateDestination:(id __autoreleasing *)alternateViewController
{
    [self createProfile];
    *alternateViewController = self.profileViewController;
    return YES;
}

#pragma mark - VDeepLinkSupporter methods

- (id<VDeeplinkHandler>)deepLinkHandler
{
    return [[VProfileDeeplinkHandler alloc] initWithDependencyManager:self.dependencyManager];
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
