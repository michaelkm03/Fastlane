//
//  VInlineValidationTextField.h
//  victorious
//
//  Created by Michael Sena on 2/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VTextFieldStyle)
{
    VTextFieldStyleLoginRegistration,
};

@class VStringValidator;

/**
 *  VInlineValidationTextField is a UITextField subclass for providing inline validation. Provide VInlineValidationTextField with a validator and set it's showInlineValidation to YES for it to update.
 */
@interface VInlineValidationTextField : UITextField

/**
 *  When VTextField is first responder this will replace the current placeholder.
 */
@property (nonatomic, strong) NSAttributedString *activePlaceholder;

/**
 *  The validator to use, if any.
 */
@property (nonatomic, strong) VStringValidator *validator;

/**
 *  Indicates whether or not to show inline validation.
 */
@property (nonatomic) BOOL showInlineValidation;

/**
 *  Show a shake animation (like the lock screen incorrect password), and vibrate the device.
 */
- (void)showIncorrectTextAnimationAndVibration;

/**
 *  Validate this textfield with a validator that may or may not be the VInlineValidationTextField's own.
 */
- (void)validateTextWithValidator:(VStringValidator *)validator;

/**
 *  A style to use for the text field.
 */
- (void)applyTextFieldStyle:(VTextFieldStyle)textFieldStyle;

@end
