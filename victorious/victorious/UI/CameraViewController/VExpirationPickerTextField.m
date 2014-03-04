//
//  VExpirationPickerTextField.m
//  victorious
//
//  Created by Gary Philipp on 2/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExpirationPickerTextField.h"

@interface VExpirationPickerTextField   ()
@property   (nonatomic, strong) NSArray*        numbers;
@property   (nonatomic, strong) NSArray*        units;
@property   (nonatomic, strong) NSArray*        unitsPlural;

@property   (nonatomic)         NSInteger       selectedValue;
@property   (nonatomic)         NSInteger       selectedCalendarUnit;
@end

@implementation VExpirationPickerTextField

- (id)initWithFrame:(CGRect)aRect
{
    if (self = [super initWithFrame:aRect])
    {
        _numbers = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
        _units = @[@"Minute", @"Hour", @"Day", @"Week", @"Month"];
        _unitsPlural = @[@"Minutes", @"Hours", @"Days", @"Weeks", @"Months"];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _numbers = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
        _units = @[@"Minute(s)", @"Hour(s)", @"Day(s)", @"Week(s)", @"Month(s)"];
        _unitsPlural = @[@"Minutes", @"Hours", @"Days", @"Weeks", @"Months"];
    }
    
    return self;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (0 == component)
        return self.numbers.count;
    else
        return self.units.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (0 == component)
        return self.numbers[row];
    else
    {
        if (1 == [self.numbers[row] integerValue])
            return self.units[row];
        else
            return self.unitsPlural[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([self.pickerDelegate respondsToSelector:@selector(pickerTextField:didSelectRow:inComponent:)])
        [self.pickerDelegate pickerTextField:self didSelectRow:row inComponent:component];
    
    if (0 == component)
        self.selectedValue = [self.numbers[row] integerValue];
    else
        self.selectedCalendarUnit = row;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self resignFirstResponder];
    
    NSCalendar*         calendar    =   [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents*   components  =   [[NSDateComponents alloc] init];
    if (self.selectedCalendarUnit == 0)
        components.minute = self.selectedValue;
    else if (self.selectedCalendarUnit == 1)
        components.hour = self.selectedValue;
    else if (self.selectedCalendarUnit == 2)
        components.day = self.selectedValue;
    else if (self.selectedCalendarUnit == 3)
        components.week = self.selectedValue;
    else if (self.selectedCalendarUnit == 4)
        components.month = self.selectedValue;
    
    NSDate*             targetDate  =   [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];

    if ([self.pickerDelegate respondsToSelector:@selector(pickerTextField:didSelectExpirationDate:)])
        [self.pickerDelegate pickerTextField:self didSelectExpirationDate:targetDate];
}

@end











// The best way I have found to do this is by attaching the UIPickerView to a (hidden)UITextField as the input view like:
//
// _myPicker = [[UIPickerView alloc] init];
// _myPicker.delegate = self;
// _myPicker.showsSelectionIndicator = YES;
// myTextField.inputView = _myPicker;
// You can always hide the text field if desired. Then you can show/hide the UIPickerView by activating the textfield as first responder like:
//
// [myTextField becomeFirstResponder];
// [myTextField resignFirstResponder];
// I have verified this works on iOS 7 and I have had it working as far back as iOS 5.
