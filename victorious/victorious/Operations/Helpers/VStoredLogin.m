//
//  VStoredLogin.m
//  victorious
//
//  Created by Patrick Lynch on 4/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStoredLogin.h"
#import "victorious-Swift.h"

NSString * const kLoggedInChangedNotification   = @"com.getvictorious.LoggedInChangedNotification";

@interface VStoredLoginInfo()

@property (nonatomic, strong, readwrite) NSString *token;
@property (nonatomic, strong, readwrite) NSNumber *userRemoteId;
@property (nonatomic, assign, readwrite) VLoginType lastLoginType;

@end

@implementation VStoredLoginInfo

@end

static const NSTimeInterval kTokenExpirationTotalDuration           = 60 * 60 * 24 * 30; ///< 30 days in seconds
static const NSTimeInterval kTokenExpirationAnticipationDuration    = 60 * 60; ///< 1 hour in seconds

static NSString * const kUserDefaultStoredUserIdKey             = @"com.getvictorious.VUserManager.StoredUserId";
static NSString * const kUserDefaultStoredExpirationDateKey     = @"com.getvictorious.VUserManager.StoredExpirationDate";
static NSString * const kUserDefaultLoginTypeKey                = @"com.getvictorious.VUserManager.LoginType";
static NSString * const kKeychainTokenService                   = @"com.getvictorious.VUserManager.Token";

@implementation VStoredLogin

- (VStoredLoginInfo *)storedLoginInfo
{
    NSNumber *storedUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultStoredUserIdKey];
    if ( storedUserId == nil || storedUserId.integerValue == 0 )
    {
        return nil;
    }
    
    NSString *token = [self savedTokenForUserId:storedUserId];
    if ( token == nil )
    {
        return nil;
    }
    
    NSDate *expirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultStoredExpirationDateKey];
    if ( [self isTokenExpirationDateExpired:expirationDate] )
    {
        [self clearSavedToken];
        return nil;
    }
    else
    {
        VStoredLoginInfo *info = [[VStoredLoginInfo alloc] init];
        info.userRemoteId = storedUserId;
        info.token = token;
        info.lastLoginType = [self lastLoginType];
        return info;
    }
}

- (VLoginType)lastLoginType
{
    NSDate *expirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultStoredExpirationDateKey];
    if ( [self isTokenExpirationDateExpired:expirationDate] )
    {
        return VLoginTypeNone;
    }
    
    NSNumber *loginTypeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLoginTypeKey];
    if ( loginTypeNumber == nil )
    {
        return VLoginTypeNone;
    }
    
    return (VLoginType)loginTypeNumber.integerValue;
}

- (BOOL)saveLoggedInUserToDisk
{
    if ( VCurrentUser.loginType == nil ||
         VCurrentUser.userID == nil || VCurrentUser.userID.integerValue == 0 ||
         VCurrentUser.token == nil || VCurrentUser.token.length == 0 )
    {
        return NO;
    }
    
    NSString *existingToken = [self savedTokenForUserId:VCurrentUser.userID];
    const BOOL isNewToken = existingToken == nil || ![existingToken isEqualToString:VCurrentUser.token];
    if ( isNewToken ) //< We don't want to save the same token again otherwise we'll reset the creation date
    {
        [[NSUserDefaults standardUserDefaults] setObject:VCurrentUser.userID forKey:kUserDefaultStoredUserIdKey];
        [[NSUserDefaults standardUserDefaults] setObject:[self defaultExpirationDate] forKey:kUserDefaultStoredExpirationDateKey];
        [[NSUserDefaults standardUserDefaults] setObject:VCurrentUser.loginType forKey:kUserDefaultLoginTypeKey];
        [self clearSavedToken];
        return [self saveToken:VCurrentUser.token withUserId:VCurrentUser.userID];
    }
    
    return NO;
}

- (BOOL)clearLoggedInUserFromDisk
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultStoredUserIdKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultStoredExpirationDateKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultLoginTypeKey];
    return [self clearSavedToken];
}

#pragma mark - Private

- (NSDate *)defaultExpirationDate
{
    return [NSDate dateWithTimeIntervalSinceNow:kTokenExpirationTotalDuration];
}

- (BOOL)isTokenExpirationDateExpired:(NSDate *)expirationDate
{
    if ( expirationDate == nil )
    {
        return YES;
    }
    NSTimeInterval lifetimeRemaining = [expirationDate timeIntervalSinceNow];
    return lifetimeRemaining - kTokenExpirationAnticipationDuration <= 0;
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
