//
//  VEmailValidator.m
//  victorious
//
//  Created by Patrick Lynch on 11/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEmailValidator.h"
#import "VConstants.h"

static NSString * const kVEmailValidateRegEx =
@"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[a-"
@"z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
@"9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";

@implementation VEmailValidator

- (BOOL)validateEmailAddress:(NSString *)emailAddress error:(NSError **)outError
{
    if ( emailAddress == nil || emailAddress.length == 0 )
    {
        if (outError != NULL)
        {
            NSString *errorString = NSLocalizedString(@"EmailValidation", @"Invalid Email Address");
            *outError = [[NSError alloc] initWithDomain:errorString
                                                   code:kVSignupErrorCodeInvalidEmailAddress
                                               userInfo:nil];
        }
        return NO;
    }
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kVEmailValidateRegEx];
    if ( ![emailTest evaluateWithObject:emailAddress] )
    {
        if (outError != NULL)
        {
            NSString *errorString = NSLocalizedString(@"EmailValidation", @"Invalid Email Address");
            *outError = [[NSError alloc] initWithDomain:errorString
                                                   code:kVSignupErrorCodeInvalidEmailAddress
                                               userInfo:nil];
        }
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
        case kVSignupErrorCodeInvalidEmailAddress:
        default:
            *title = NSLocalizedString( @"EmailValidation", @"" );
            *message = nil;
            break;
    }
    
    return YES;
}

@end
