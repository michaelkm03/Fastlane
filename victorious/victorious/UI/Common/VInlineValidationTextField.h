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
 *  Show invalid text with a conditional animation. Will not show animation or text while hasResignedFirstResponder AND force are NO. 
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
