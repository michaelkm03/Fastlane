//
//  VExpirationPickerTextField.h
//  victorious
//
//  Created by Gary Philipp on 2/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPickerTextField.h"

@protocol VExpirationPickerTextFieldDelegate <VPickerTextFieldDelegate>
@required

- (void)pickerTextField:(VPickerTextField *)pickerTextField didSelectExpirationDate:(NSDate *)expirationDate;

@end

@interface VExpirationPickerTextField : VPickerTextField

@property (nonatomic, weak) id<VExpirationPickerTextFieldDelegate> pickerDelegate;

@end
