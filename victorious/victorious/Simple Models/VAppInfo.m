//
//  VAppOwner.m
//  victorious
//
//  Created by Sharif Ahmed on 3/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAppInfo.h"
#import "VDependencyManager.h"

// Global configuration keys
static NSString * const kAppStoreURLKey = @"appStoreURL";
static NSString * const kAppNameKey = @"appName";

static NSString * const kOwnerDictionaryKey = @"owner";
static NSString * const kOwnerNameKey = @"name";
static NSString * const kOwnerProfileImageURLKey = @"profile_image";
static NSString * const kOwnerIdKey = @"id";

@interface VAppInfo ()

@end

@implementation VAppInfo

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSAssert(dependencyManager != nil, @"dependencyManager used to init appInfo should not be nil");
    self = [super init];
    if ( self != nil )
    {
        NSDictionary *ownerDictionary = [dependencyManager templateValueOfType:[NSDictionary class] forKey:kOwnerDictionaryKey];
        if ( ownerDictionary != nil )
        {
            _ownerName = ownerDictionary[ kOwnerNameKey ];
            _profileImageURL = [NSURL URLWithString:ownerDictionary[ kOwnerProfileImageURLKey ]];
            _ownerId = ownerDictionary[ kOwnerIdKey ];
        }
        _appName = [dependencyManager stringForKey:kAppNameKey];
        _appURL = [NSURL URLWithString:[dependencyManager stringForKey:kAppStoreURLKey]];
    }
    return self;
}

@end
