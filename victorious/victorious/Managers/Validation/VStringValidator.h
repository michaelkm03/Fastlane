//
//  VValidator.h
//  victorious
//
//  Created by Patrick Lynch on 11/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const VValdationErrorTitleKey;

@class VStringValidator;

@protocol VStringValidatorConfirmationDelegate <NSObject>

- (NSString *)confirmationStringForStringValidator:(VStringValidator *)stringValidator;

@end

@interface VStringValidator : NSObject

/**
 Loads the appropriate title and error localized strings depending on the error's code property
 and displays an alert view.
 */
- (void)showAlertInViewController:(UIViewController *)viewController withError:(NSError *)error;

/**
 *  Interface to be overridden by subclasses. Default implementation throws an exception.
 *
 *  @param string The string to validate.
 *  @param confirmationString A confirmation string to validate against the first string. EX: password & confirm password. Can pass nil or empty string to indicate user has not interacted with the confirmation field yet.
 *  @param error  An error if any. UserInfo is populated with NSLocalizedFailureReasonErrorKey, and NSLocalizedDescriptionKey where appropriate.
 *
 *  @return Whether or not this string is valid.
 */
- (BOOL)validateString:(NSString *)string
      withConfirmation:(NSString *)confirmationString
              andError:(NSError **)error;

@property (nonatomic, weak) id <VStringValidatorConfirmationDelegate> confirmationDelegate;

@end
