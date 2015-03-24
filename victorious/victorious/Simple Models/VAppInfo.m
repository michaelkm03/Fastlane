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
NSString * const kAppStoreURLKey = @"appStoreURL";
NSString * const kAppNameKey = @"appName";

NSString * const kOwnerDictionaryKey = @"owner";
NSString * const kOwnerNameKey = @"name";
NSString * const kOwnerProfileImageURLKey = @"profile_image";
NSString * const kOwnerIdKey = @"id";

@interface VAppInfo ()

@property (nonatomic, readwrite) NSString *ownerName;
@property (nonatomic, readwrite) NSString *ownerId;
@property (nonatomic, readwrite) NSURL *profileImageURL;
@property (nonatomic, readwrite) NSString *appName;
@property (nonatomic, readwrite) NSURL *appURL;

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
            _ownerName = [ownerDictionary objectForKey:kOwnerNameKey];
            _profileImageURL = [NSURL URLWithString:[ownerDictionary objectForKey:kOwnerProfileImageURLKey]];
            _ownerId = [ownerDictionary objectForKey:kOwnerIdKey];
        }
        _appName = [dependencyManager stringForKey:kAppNameKey];
        _appURL = [NSURL URLWithString:[dependencyManager stringForKey:kAppStoreURLKey]];
    }
    return self;
}

@end
