//
//  VValidator.m
//  victorious
//
//  Created by Patrick Lynch on 11/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VValidator.h"

@implementation VValidator

- (void)showAlertInViewController:(UIViewController *)viewController withError:(NSError *)error
{
    NSParameterAssert( viewController != nil ); //< This is here for future use of UIAlertController
    
    NSString *title = nil;
    NSString *message = nil;
    [self localizedErrorStringsForError:error title:&title message:&message];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)localizedErrorStringsForError:(NSError *)error title:(NSString **)title message:(NSString **)message
{
    NSAssert( NO, @"Must be overidden in a subclass." );
    return NO;
}

@end
