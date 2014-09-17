//
//  VExpirationDatePicker.m
//  victorious
//
//  Created by Gary Philipp on 3/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExpirationDatePicker.h"

@interface      VExpirationDatePicker ()

@property (nonatomic, strong)   UIDatePicker*   datePicker;

@end

@implementation VExpirationDatePicker

- (UIView *)createInputView
{
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.date = [NSDate date];
    
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.datePicker.backgroundColor = [UIColor whiteColor];
    
    return self.datePicker;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(datePicker:didSelectExpirationDate:)])
    {
        [self.delegate datePicker:self didSelectExpirationDate:self.datePicker.date];
    }
}

- (IBAction)clear:(id)sender
{
    [self resignFirstResponder];
}

@end
