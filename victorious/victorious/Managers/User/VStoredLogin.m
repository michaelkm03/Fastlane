//
//  VStoredLogin.m
//  victorious
//
//  Created by Patrick Lynch on 4/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStoredLogin.h"
#import "VUser+RestKit.h"
#import "VObjectManager.h"

static const NSTimeInterval kTokenExpirationDuration    = (60 * 60) * 24 * 30 - (60 * 60); ///< 30 days minus one hour (value in seconds)

static NSString * const kUserDefaultStoredUserIdKey     = @"com.getvictorious.VUserManager.StoredUserId";
static NSString * const kKeychainTokenService           = @"com.getvictorious.VUserManager.Token";

@implementation VStoredLogin

- (VUser *)lastLoggedInUserFromDisk
{
    NSNumber *storedUserId = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultStoredUserIdKey];
    if ( storedUserId == nil || storedUserId.integerValue == 0 )
    {
        return nil;
    }
    
    NSString *token = [self savedTokenForUserId:storedUserId];
    if ( token == nil )
    {
        return nil;
    }
    
    NSDate *creationDate = [self savedTokenCreationDateForUserId:storedUserId];
    if ( [self isTokenCreatedOnDateExpired:creationDate] )
    {
        [self clearSavedToken];
        return nil;
    }
    else
    {
        return [self createNewUserWithRemoteId:storedUserId token:token];
    }
}

- (BOOL)saveLoggedInUserToDisk:(VUser *)user
{
    if ( user.remoteId == nil || user.remoteId.integerValue == 0 ||
         user.token == nil || user.token.length == 0 )
    {
        return NO;
    }
    
    NSString *existingToken = [self savedTokenForUserId:user.remoteId];
    const BOOL isNewToken = existingToken == nil || ![existingToken isEqualToString:user.token];
    if ( isNewToken ) //< We don't want to save the same token again otherwise we'll reset the creation date
    {
        [[NSUserDefaults standardUserDefaults] setValue:user.remoteId forKey:kUserDefaultStoredUserIdKey];
        [self clearSavedToken];
        return [self saveToken:user.token withUserId:user.remoteId];
    }
    
    return NO;
}

- (BOOL)clearLoggedInUserFromDisk
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultStoredUserIdKey];
    return [self clearSavedToken];
}

#pragma mark - Private

- (BOOL)isTokenCreatedOnDateExpired:(NSDate *)creationDate
{
    NSTimeInterval tokenLifetime = ABS( [creationDate timeIntervalSinceNow] );
    return tokenLifetime >= kTokenExpirationDuration;
}

- (NSDictionary *)tokenKeychainItemForUserId:(NSNumber *)userId
{
    CFTypeRef result;
    NSDictionary *dictionary = @{ (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                  (__bridge id)kSecAttrService: kKeychainTokenService,
                                  (__bridge id)kSecAttrAccount: userId.stringValue,
                                  (__bridge id)kSecClass: (__bridge id)kSecAttrCreationDate,
                                  (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne,
                                  (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue,
                                  (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue };
    
    OSStatus status = SecItemCopyMatching( (__bridge CFDictionaryRef)dictionary, &result );
    if ( status == errSecSuccess )
    {
        NSDictionary *keychainItem = (__bridge_transfer NSDictionary *)result;
        return keychainItem;
    }
    
    return nil;
}

- (NSString *)savedTokenForUserId:(NSNumber *)userId
{
    NSDictionary *keychainItem = [self tokenKeychainItemForUserId:userId];
    if ( keychainItem != nil )
    {
        NSData *keychainData = (NSData *)keychainItem[(__bridge id)(kSecValueData)];
        return [[NSString alloc] initWithData:keychainData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSDate *)savedTokenCreationDateForUserId:(NSNumber *)userId
{
    NSDictionary *keychainItem = [self tokenKeychainItemForUserId:userId];
    if ( keychainItem != nil )
    {
        return (NSDate *)keychainItem[(__bridge id)(kSecAttrCreationDate)];
    }
    return nil;
}

- (BOOL)saveToken:(NSString *)token withUserId:(NSNumber *)userId
{
    CFTypeRef result;
    NSDictionary *dictionary = @{ (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                  (__bridge id)kSecAttrService: kKeychainTokenService,
                                  (__bridge id)kSecAttrAccount: userId.stringValue,
                                  (__bridge id)kSecValueData: [token dataUsingEncoding:NSUTF8StringEncoding] };
    OSStatus status = SecItemAdd( (__bridge CFDictionaryRef)dictionary, &result );
    return status == errSecSuccess;
}

- (BOOL)clearSavedToken
{
    NSDictionary *dictionary = @{ (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                  (__bridge id)kSecAttrService: kKeychainTokenService };
    OSStatus status = SecItemDelete( (__bridge CFDictionaryRef)dictionary );
    return status == errSecSuccess;
}

- (VUser *)createNewUserWithRemoteId:(NSNumber *)remoteId token:(NSString *)token
{
    VUser *user = [[VObjectManager sharedManager] objectWithEntityName:[VUser entityName] subclass:[VUser class]];
    user.remoteId = remoteId;
    user.token = token;
    return user;
}

@end
