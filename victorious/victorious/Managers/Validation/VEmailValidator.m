//
//  VEmailValidator.m
//  victorious
//
//  Created by Patrick Lynch on 11/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEmailValidator.h"
#import "VConstants.h"

NSInteger const VSignupErrorCodeInvalidEmailAddress  = 5102;

static NSString * const kVEmailValidateRegEx =
@"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[a-"
@"z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
@"9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";

@implementation VEmailValidator

- (BOOL)validateString:(NSString *)string
              andError:(NSError **)error
{
    if ( !string || string.length == 0 )
    {
        if (error != nil)
        {
            *error = [self errorForErrorCode:VSignupErrorCodeInvalidEmailAddress];
        }
        return NO;
    }
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kVEmailValidateRegEx];
    if ( ![emailTest evaluateWithObject:string] )
    {
        if (error != nil)
        {
            *error = [self errorForErrorCode:VSignupErrorCodeInvalidEmailAddress];
        }
        return NO;
    }
    
    return YES;
}


- (NSError *)errorForErrorCode:(NSInteger)errorCode
{
    NSString *domain;
    NSString *localizedDescription;
    
    switch ( errorCode )
    {
        case VSignupErrorCodeInvalidEmailAddress:
        default:
            domain = NSLocalizedString( @"EmailValidation", @"" );
            localizedDescription = NSLocalizedString( @"EmailValidation", @"" );
            break;
    }
    
    NSError *errorForCode = [[NSError alloc] initWithDomain:domain
                                                       code:errorCode
                                                   userInfo:@{NSLocalizedFailureReasonErrorKey:localizedDescription,
                                                              NSLocalizedDescriptionKey:localizedDescription}];
    return errorForCode;
}

@end
