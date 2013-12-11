//
//  VValidatingTextField.h
//  victoriOS
//
//  Created by Gary Philipp on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, ValidationResult)
{
    kValidationPassed,
    kValidationFailed,
    kValueTooShortToValidate
};

extern  NSString*   const       kNameRegularExpressionString;
extern  NSString*   const       kEmailRegularExpressionString;
extern  NSString*   const       kPhoneNumberRegularExpressionString;

typedef void (^ValidationBlock)(ValidationResult result, BOOL isEditing);

@interface VValidatingTextField : UITextField

@property (nonatomic)   NSString*             regexpPattern;
@property (nonatomic)   NSRegularExpression*  regexp;

@property (nonatomic, readonly)    BOOL isValid;
@property (nonatomic, readwrite)   UIColor* validColor;
@property (nonatomic, readwrite)   UIColor* invalidColor;

@property (nonatomic, readwrite, copy) ValidationBlock validatedFieldBlock;

@property (nonatomic)   BOOL validWhenTyping;
@property (nonatomic)   NSUInteger minimalNumberOfCharactersToStartValidation;

@end
