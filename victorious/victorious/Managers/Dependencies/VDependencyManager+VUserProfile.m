//
//  VDependencyManager+VUserProfile.m
//  victorious
//
//  Created by Patrick Lynch on 4/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VUserProfile.h"
#import "VUserProfileHeader.h"
#import "VUserProfileViewController.h"

NSString * const VDependencyManagerUserProfileViewComponentKey = @"userProfileView";
NSString * const VDependencyManagerUserProfileHeaderComponentKey = @"userProfileHeader";
NSString * const VDependencyManagerUserKey = @"user";
NSString * const VDependencyManagerUserRemoteIdKey = @"remoteId";
NSString * const VDependencyManagerFindFriendsIconKey = @"findFriendsIcon";

@implementation VDependencyManager (VUserProfileViewController)

- (VUserProfileViewController *)userProfileViewControllerWithUser:(VUser *)user
{
    NSAssert( user != nil, @"Cannot create a VUserProfileViewController with a nil `user` parameter." );
    return [self templateValueOfType:[VUserProfileViewController class] forKey:VDependencyManagerUserProfileViewComponentKey
               withAddedDependencies:@{ VDependencyManagerUserKey: user }];
}

- (VUserProfileViewController *)userProfileViewControllerWithRemoteId:(NSNumber *)remoteId
{
    NSAssert( remoteId != nil, @"Cannot create a VUserProfileViewController with a nil user `remoteId` parameter." );
    return [self templateValueOfType:[VUserProfileViewController class] forKey:VDependencyManagerUserProfileViewComponentKey
               withAddedDependencies:@{ VDependencyManagerUserRemoteIdKey: remoteId }];
}

- (UIViewController<VUserProfileHeader> *)userProfileHeaderWithUser:(VUser *)user
{
    NSAssert( user != nil, @"Cannot create a VUserProfileHeader with a nil `user` parameter." );
    UIViewController<VUserProfileHeader> *header = [self templateValueConformingToProtocol:@protocol(VUserProfileHeader)
                                                                                    forKey:VDependencyManagerUserProfileHeaderComponentKey
                                                                     withAddedDependencies:@{ VDependencyManagerUserKey: user }];
    return header;
}

@end