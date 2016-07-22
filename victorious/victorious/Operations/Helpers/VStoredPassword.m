//
//  VStoredPassword.m
//  victorious
//
//  Created by Josh Hinman on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import "VStoredPassword.h"

static NSString * const kKeychainServiceName = @"com.getvictorious.VUserManager.LoginPassword";

@implementation VStoredPassword

- (BOOL)savePassword:(NSString *)password forUsername:(NSString *)username
{
    if ( username.length == 0 || password.length == 0 )
    {
        return NO;
    }
    
    if ( [self passwordForUsername:username] != nil )
    {
        [self clearSavedPassword];
    }
    
    CFTypeRef result;
    OSStatus err = SecItemAdd((__bridge CFDictionaryRef)(@{
                                                           (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                                           (__bridge id)kSecAttrAccount: username,
                                                           (__bridge id)kSecAttrService: kKeychainServiceName,
                                                           (__bridge id)kSecValueData: [password dataUsingEncoding:NSUTF8StringEncoding]
                                                           }), &result);
    return err == errSecSuccess;
}

- (NSString *)passwordForUsername:(NSString *)username
{
    if ( username == nil )
    {
        return nil;
    }
    
    CFTypeRef result;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)(@{
                                                                    (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                                                    (__bridge id)kSecAttrService: kKeychainServiceName,
                                                                    (__bridge id)kSecAttrAccount: username,
                                                                    (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne,
                                                                    (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue,
                                                                    (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue
                                                                    }), &result);
    if (err == errSecSuccess)
    {
        NSDictionary *keychainItem = (__bridge_transfer NSDictionary *)result;
        NSData *keychainData = (NSData *)keychainItem[(__bridge id)(kSecValueData)];
        NSString *password = [[NSString alloc] initWithData:keychainData encoding:NSUTF8StringEncoding];
        return password;
    }
    else
    {
        return nil;
    }
}

- (BOOL)clearSavedPassword
{
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef)(@{
                                                              (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                                              (__bridge id)kSecAttrService: kKeychainServiceName,
                                                              }));
    return err == errSecSuccess;
}

@end
