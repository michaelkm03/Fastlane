//
//  VStoredUser.m
//  victorious
//
//  Created by Patrick Lynch on 4/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStoredUser.h"
#import "VUser+RestKit.h"
#import "VObjectManager.h"

static NSString * const kUserDefaultStoredUserIdKey     = @"com.getvictorious.VUserManager.StoredUser";
static NSString * const kKeychainTokenService           = @"com.getvictorious.VUserManager.Token";

@implementation VStoredUser

- (VUser *)loadLastLoggedInUserFromDisk
{
    NSNumber *storedUserId = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultStoredUserIdKey];
    if ( storedUserId == nil || storedUserId.integerValue == 0 )
    {
        return nil;
    }
    
    NSString *token = [self savedTokenForUserId:storedUserId];
    if ( token != nil )
    {
        VUser *user = [[VObjectManager sharedManager] objectWithEntityName:[VUser entityName] subclass:[VUser class]];
        user.remoteId = storedUserId;
        user.token = token;
        return user;
    }
    
    return nil;
}

- (BOOL)saveLoggedInUserToDisk:(VUser *)user
{
    if ( user.remoteId == nil || user.remoteId.integerValue == 0 )
    {
        return NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:user.remoteId forKey:kUserDefaultStoredUserIdKey];
    if ( [self savedTokenForUserId:user.remoteId] )
    {
        [self clearSavedToken];
    }
    return [self saveToken:user.token withUserId:user.remoteId];
}

- (BOOL)clearLoggedInUserFromDisk
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultStoredUserIdKey];
    return [self clearSavedToken];
}

- (NSString *)savedTokenForUserId:(NSNumber *)userId
{
    CFTypeRef result;
    NSDictionary *dictionary = @{ (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                  (__bridge id)kSecAttrService: kKeychainTokenService,
                                  (__bridge id)kSecAttrAccount: userId.stringValue,
                                  (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne,
                                  (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue,
                                  (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue };
    
    OSStatus status = SecItemCopyMatching( (__bridge CFDictionaryRef)dictionary, &result );
    if ( status == errSecSuccess )
    {
        NSDictionary *keychainItem = (__bridge_transfer NSDictionary *)result;
        NSData *keychainData = (NSData *)keychainItem[(__bridge id)(kSecValueData)];
        return [[NSString alloc] initWithData:keychainData encoding:NSUTF8StringEncoding];
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

@end
