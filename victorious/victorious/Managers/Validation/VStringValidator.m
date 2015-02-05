//
//  VStringValidator.m
//  victorious
//
//  Created by Patrick Lynch on 11/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStringValidator.h"

NSString *const VValdationErrorTitleKey = @"VValdationErrorTitle";

@interface VStringValidator ()

@property (nonatomic, readwrite) id confirmationObject;
@property (nonatomic, readwrite) NSString *keyPath;

@end

@implementation VStringValidator

- (void)showAlertInViewController:(UIViewController *)viewController withError:(NSError *)error
{
    NSParameterAssert( viewController != nil ); //< This is here for future use of UIAlertController
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedFailureReason
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)validateString:(NSString *)string 
              andError:(NSError **)error
{
    NSAssert(false, @"Implement in subclasses!");
    return NO;
}

- (void)setConfirmationObject:(id)confirmationObject
                  withKeyPath:(NSString *)keyPath
{
    _confirmationObject = confirmationObject;
    _keyPath = keyPath;
    if (_confirmationObject == nil)
    {
        return;
    }
    id objectAtKeyPath = [confirmationObject valueForKeyPath:keyPath];
    NSAssert([objectAtKeyPath isKindOfClass:[NSString class]], @"Needs to resolve to an NSString");
}

@end
