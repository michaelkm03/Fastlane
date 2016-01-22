//
//  VObjectManager+Login.m
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager+Private.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Users.h"
#import "VStoredPassword.h"
#import "VDependencyManager.h"
#import "VVoteType.h"
#import "VTracking.h"
#import "MBProgressHUD.h"
#import "VTemplateDecorator.h"
#import "NSDictionary+VJSONLogging.h"
#import "VStoredLogin.h"
#import "VLoginType.h"
#import "VImageAsset+Fetcher.h"
#import "victorious-Swift.h"

@import CoreData;
@import FBSDKLoginKit;

@implementation VObjectManager (Login)

NSString * const kLoggedInChangedNotification   = @"com.getvictorious.LoggedInChangedNotification";

static NSString * const kVExperimentsKey        = @"experiments";
static NSString * const kVAppearanceKey         = @"appearance";
static NSString * const kVVideoQualityKey       = @"video_quality";
static NSString * const kVAppTrackingKey        = @"video_quality";

- (RKManagedObjectRequestOperation *)templateWithSuccessBlock:(VSuccessBlock)success failBlock:(VFailBlock)failed
{
    return [self GET:@"/api/template"
              object:nil
          parameters:nil
        successBlock:success
           failBlock:failed];
}

#pragma mark - Login and status

- (BOOL)mainUserProfileComplete
{
    return self.mainUser != nil && ![self.mainUser.status isEqualToString:kUserStatusIncomplete];
}

- (BOOL)mainUserLoggedIn
{
    return self.mainUser != nil;
}

- (BOOL)authorized
{
    return self.mainUserLoggedIn && self.mainUserProfileComplete;
}

- (BOOL)mainUserLoggedInWithSocial
{
    return self.loginType == VLoginTypeTwitter || self.loginType == VLoginTypeFacebook;
}

@end
