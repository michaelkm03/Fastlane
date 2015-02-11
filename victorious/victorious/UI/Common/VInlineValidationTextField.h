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

@property (nonatomic, readonly) BOOL hasResignedFirstResponder;

/**
<<<<<<< HEAD
 *  Color of the line that runs along the bottom to separate in a multi-field form.
 */
@property (nonatomic) UIColor *separatorColor;

/**
 *  Show a shake animation (like the lock screen incorrect password), and vibrate the device.
=======
 *  Show invalid text with a conditional animation. Will not show animation or text while hasResignedFirstResponder AND force are NO. 
>>>>>>> 2c42aa8e4f389bf7fa238273ce8a5e1b16d6dceb
 */
- (void)showInvalidText:(NSString *)invalidText
               animated:(BOOL)animated
                  shake:(BOOL)shake
                 forced:(BOOL)force;

/**
 *  Hide the invalid text.
 */
- (void)hideInvalidText;

/**
 *  A style to use for the text field.
 */
- (void)applyTextFieldStyle:(VTextFieldStyle)textFieldStyle;

@end
