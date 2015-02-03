//
//  VTextField.m
//  victorious
//
//  Created by Michael Sena on 2/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextField.h"

#import "VPasswordValidator.h"

@interface VTextField ()


@end

@implementation VTextField

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:self];
}

- (void)setValidator:(VStringValidator *)validator
{
    if (_validator == validator)
    {
        return;
    }
    
    if (validator)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textChanged:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:self];
    }
    
    _validator = validator;
}

- (void)textChanged:(NSNotification *)notification
{
    NSError *validationError;
    BOOL isValid = [self.validator validateString:self.text
                                  withConfirmation:nil
                                          andError:&validationError];
    VLog(@"%@", isValid ? @"valid" : validationError.domain);
}

@end
