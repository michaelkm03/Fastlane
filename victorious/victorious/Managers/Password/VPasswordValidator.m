//
//  VPasswordValidator.m
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPasswordValidator.h"
#import "VConstants.h"

@implementation VPasswordValidator

+ (BOOL)validatePassword:(NSString *)password error:(NSError **)outError
{
    if ( password == nil || password.length < 8 )
    {
        if ( outError != nil )
        {
            NSString *errorString = NSLocalizedString(@"PasswordValidation", @"Invalid Password");
            NSDictionary *userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError = [[NSError alloc] initWithDomain:kVictoriousErrorDomain
                                                       code:VAccountUpdateViewControllerBadPasswordErrorCode
                                                   userInfo:userInfoDict];
        }
        return NO;
    }
    return YES;
}

+ (BOOL)validateAndShowAlertPassword:(NSString *)password withConfirmation:(NSString *)confirmationPassword
{
    NSError *theError;
    
    if (![self validatePassword:password error:&theError])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                        message:theError.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    if (![password isEqualToString:confirmationPassword])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                        message:NSLocalizedString(@"PasswordNotMatching", @"")
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
        [alert show];
        return NO;
    }
    
    
    return YES;
}

@end
