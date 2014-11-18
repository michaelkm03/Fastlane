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

- (BOOL)validatePassword:(NSString *)password error:(NSError **)outError
{
    if ( password == nil || password.length < 8 )
    {
        if ( outError != nil )
        {
            NSString *errorString = NSLocalizedString( @"PasswordValidation", @"" );
            *outError = [[NSError alloc] initWithDomain:errorString
                                                       code:VErrorCodeInvalidPasswordEntered
                                                   userInfo:nil];
        }
        return NO;
    }
    return YES;
}

- (BOOL)validatePassword:(NSString *)password withConfirmation:(NSString *)confirmationPassword error:(NSError **)outError
{
    if (![self validatePassword:password error:outError])
    {
        return NO;
    }
    
    if (![password isEqualToString:confirmationPassword])
    {
        if ( outError != nil )
        {
            NSString *errorString = NSLocalizedString( @"PasswordNotMatching", @"" );
            *outError = [[NSError alloc] initWithDomain:errorString
                                                   code:VErrorCodeInvalidPasswordsDoNotMatch
                                               userInfo:nil];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)validateCurrentPassword:(NSString *)currentPassword withNewPassword:(NSString *)newPassword withConfirmation:(NSString *)confirmationPassword error:(NSError **)outError
{
    if ( [currentPassword isEqualToString:newPassword] || [currentPassword isEqualToString:confirmationPassword] )
    {
        if ( outError != nil )
        {
            NSString *errorString = NSLocalizedString( @"ResetPasswordNewEqualsCurrentTitle", @"" );
            *outError = [[NSError alloc] initWithDomain:errorString
                                                   code:VErrorCodeInvalidPasswordsNewEqualsCurrent
                                               userInfo:nil];
        }
        return NO;
    }
    else if (![self validatePassword:newPassword withConfirmation:confirmationPassword error:outError] )
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)localizedErrorStringsForError:(NSError *)error title:(NSString **)title message:(NSString **)message
{
    NSParameterAssert( title != nil );
    NSParameterAssert( message != nil );
    
    switch ( error.code )
    {
        case VErrorCodeCurrentPasswordIsIncorrect:
            *title = NSLocalizedString( @"ResetPasswordErrorIncorrectTitle", @"");
            *message = NSLocalizedString( @"ResetPasswordErrorMessage", @"");
            break;
        case VErrorCodeInvalidPasswordEntered:
            *title = NSLocalizedString( @"PasswordError", @"");
            *message = NSLocalizedString( @"PasswordValidation", @"" );
            break;
        case VErrorCodeInvalidPasswordsDoNotMatch:
            *title = NSLocalizedString( @"PasswordError", @"");
            *message = NSLocalizedString( @"PasswordNotMatching", @"");
            break;
        case VErrorCodeCurrentPasswordIsInvalid:
            *title = NSLocalizedString( @"ResetPasswordErrorInvalidTitle", @"");
            *message = NSLocalizedString( @"ResetPasswordErrorMessage", @"");
            break;
        case VErrorCodeInvalidPasswordsNewEqualsCurrent:
            *title = NSLocalizedString( @"ResetPasswordNewEqualsCurrentTitle", @"");
            *message = NSLocalizedString( @"ResetPasswordNewEqualsCurrentMessage", @"");
            break;
        default:
            *title = NSLocalizedString( @"ResetPasswordErrorFailTitle", @"");
            *message = NSLocalizedString( @"ResetPasswordErrorFailMessage", @"");
            break;
    }
    
    return YES;
}

@end
