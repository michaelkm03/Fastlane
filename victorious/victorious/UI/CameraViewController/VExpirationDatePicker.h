//
//  VExpirationDatePicker.h
//  victorious
//
//  Created by Gary Philipp on 3/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPickerTextField.h"

@class    VExpirationDatePicker;

@protocol VExpirationDatePickerDelegate <NSObject>
@required
- (void)datePicker:(VExpirationDatePicker *)datePicker didSelectExpirationDate:(NSDate *)expirationDate;
@end

@interface VExpirationDatePicker : VPickerTextField
@property (nonatomic, weak) id<VExpirationDatePickerDelegate>   delegate;
@end
