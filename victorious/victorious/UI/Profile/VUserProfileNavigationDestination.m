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
@property (nonatomic, strong) id<VProvidesNavigationMenuItemBadge> preDisplayBadgeProvider;
@property (nonatomic, weak) VUserProfileViewController *displayedBadgeProvider;

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
        _preDisplayBadgeProvider = [self createProfileForLoggedInUser];
    }
    return self;
}

- (id<VProvidesNavigationMenuItemBadge>)createProfileForLoggedInUser
{
    VUserProfileViewController *profile = [VUserProfileViewController userProfileWithUser:self.objectManager.mainUser
                                                                     andDependencyManager:self.dependencyManager];
    profile.representsMainUser = YES;
    [profile updateAccessoryItems];
    return profile;
}

#pragma mark - VNavigationDestination conformance

- (BOOL)shouldNavigateWithAlternateDestination:(id __autoreleasing *)alternateViewController
{
    // Once this destination is selected, it will handle providing badges and this is no longer needed
    self.preDisplayBadgeProvider = nil;
    
    VUserProfileViewController *destination = [VUserProfileViewController userProfileWithUser:self.objectManager.mainUser
                                                                         andDependencyManager:self.dependencyManager];
    *alternateViewController = destination;
    self.displayedBadgeProvider = destination;
    
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
    if ( self.displayedBadgeProvider != nil )
    {
        self.displayedBadgeProvider.badgeNumberUpdateBlock = badgeNumberUpdateBlock;
    }
    else if ( self.preDisplayBadgeProvider != nil )
    {
        self.preDisplayBadgeProvider.badgeNumberUpdateBlock = badgeNumberUpdateBlock;
    }
}

@end
