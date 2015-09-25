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

// Stoelen shamelessly from: http://emailregex.com
static NSString * const kVEmailValidateRegEx =
@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";

@implementation VEmailValidator

- (BOOL)validateString:(NSString *)string
              andError:(NSError **)error
{
    if ( (string == nil)  || string.length == 0 )
    {
        if (error != nil)
        {
            *error = [self errorForErrorCode:VSignupErrorCodeInvalidEmailAddress];
        }
        return NO;
    }
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kVEmailValidateRegEx];
    if ( ![emailTest evaluateWithObject:[string lowercaseString]] )
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
