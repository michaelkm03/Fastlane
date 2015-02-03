//
//  VPasswordValidator.m
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPasswordValidator.h"
#import "VConstants.h"

NSInteger const VErrorCodeCurrentPasswordIsIncorrect        = 5000;
NSInteger const VErrorCodeCurrentPasswordIsInvalid          = 5050;
NSInteger const VErrorCodeInvalidPasswordEntered            = 5051;
NSInteger const VErrorCodeInvalidPasswordsDoNotMatch        = 5052;
NSInteger const VErrorCodeInvalidPasswordsNewEqualsCurrent  = 5053;

@implementation VPasswordValidator

- (BOOL)validateString:(NSString *)string
              andError:(NSError **)error
{
    if ( string == nil || string.length < 8 )
    {
        if ( error != nil )
        {
            *error = [self errorForErrorCode:VErrorCodeInvalidPasswordEntered];
        }
        return NO;
    }

    if (![string isEqualToString:[self confirmationString]] && ([self confirmationString] != nil))
    {
        if ( error != nil )
        {
            *error = [self errorForErrorCode:VErrorCodeInvalidPasswordsDoNotMatch];
        }
        return NO;
    }

    if ( [self.currentPassword isEqualToString:string] || [self.currentPassword isEqualToString:[self confirmationString]] )
    {
        if ( error != nil )
        {
            *error = [self errorForErrorCode:VErrorCodeInvalidPasswordsNewEqualsCurrent];
        }
        return NO;
    }
    
    return YES;
}

- (NSError *)errorForErrorCode:(NSInteger)errorCode
{
    NSString *domain;
    NSString *title;
    NSString *localizedDescription;
    
    switch ( errorCode )
    {
        case VErrorCodeCurrentPasswordIsIncorrect:
            domain = NSLocalizedString( @"PasswordValidation", @"" );
            title = NSLocalizedString( @"ResetPasswordErrorIncorrectTitle", @"");
            localizedDescription = NSLocalizedString( @"ResetPasswordErrorMessage", @"");
            break;
        case VErrorCodeInvalidPasswordEntered:
            domain = NSLocalizedString( @"PasswordValidation", @"" );
            title = NSLocalizedString( @"PasswordError", @"");
            localizedDescription = NSLocalizedString( @"PasswordValidation", @"" );
            break;
        case VErrorCodeInvalidPasswordsDoNotMatch:
            domain = NSLocalizedString( @"PasswordNotMatching", @"" );
            title = NSLocalizedString( @"PasswordError", @"");
            localizedDescription = NSLocalizedString( @"PasswordNotMatching", @"");
            break;
        case VErrorCodeCurrentPasswordIsInvalid:
            domain = NSLocalizedString( @"PasswordValidation", @"" );
            title = NSLocalizedString( @"ResetPasswordErrorInvalidTitle", @"");
            localizedDescription = NSLocalizedString( @"ResetPasswordErrorMessage", @"");
            break;
        case VErrorCodeInvalidPasswordsNewEqualsCurrent:
            domain = NSLocalizedString( @"ResetPasswordNewEqualsCurrentTitle", @"" );;
            title = NSLocalizedString( @"ResetPasswordNewEqualsCurrentTitle", @"");
            localizedDescription = NSLocalizedString( @"ResetPasswordNewEqualsCurrentMessage", @"");
            break;
        default:
            domain = NSLocalizedString( @"PasswordValidation", @"" );
            title = NSLocalizedString( @"ResetPasswordErrorFailTitle", @"");
            localizedDescription = NSLocalizedString( @"ResetPasswordErrorFailMessage", @"");
            break;
    }
    NSError *errorForCode = [[NSError alloc] initWithDomain:domain
                                                       code:errorCode
                                                   userInfo:@{
                                                              NSLocalizedFailureReasonErrorKey : title,
                                                              NSLocalizedDescriptionKey : localizedDescription
                                                              }];
    return errorForCode;
}

- (NSString *)confirmationString
{
    return [self.confirmationObject valueForKeyPath:self.keyPath];
}

@end
