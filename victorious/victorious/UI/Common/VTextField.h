//
//  VTextField.h
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

@interface VTextField : UITextField

@property (nonatomic, strong) VStringValidator *validator;

@property (nonatomic) BOOL showInlineValidation;

- (void)incorrectTextAnimationAndVibration;

- (void)validateTextWithValidator:(VStringValidator *)validator;

- (void)applyTextFieldStyle:(VTextFieldStyle)textFieldStyle;

@end
