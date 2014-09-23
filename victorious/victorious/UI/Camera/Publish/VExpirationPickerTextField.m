//
//  VExpirationPickerTextField.m
//  victorious
//
//  Created by Gary Philipp on 2/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExpirationPickerTextField.h"

@interface VExpirationPickerTextField   ()

@property   (nonatomic, strong) NSArray        *numbers;
@property   (nonatomic, strong) NSArray        *units;
@property   (nonatomic, strong) NSArray        *unitsPlural;

@property   (nonatomic)         NSInteger       selectedValue;
@property   (nonatomic)         NSInteger       selectedCalendarUnit;

@end

@implementation VExpirationPickerTextField

- (instancetype)initWithFrame:(CGRect)aRect
{
    if (self = [super initWithFrame:aRect])
    {
        [self createNumbersComponent];
        [self createUnitsComponents];
        
        _selectedValue = 1;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self createNumbersComponent];
        [self createUnitsComponents];
        
        _selectedValue = 1;
    }
    
    return self;
}

- (void)createNumbersComponent
{
    NSMutableArray     *numbers = [[NSMutableArray alloc] initWithCapacity:365];
    
    for (NSUInteger num = 1; num < 365; num++)
    {
        [numbers addObject:[NSNumberFormatter localizedStringFromNumber:@(num) numberStyle:NSNumberFormatterDecimalStyle]];
    }
 
    self.numbers = numbers;
}

- (void)createUnitsComponents
{
    self.units = @[
                   NSLocalizedString(@"Minute", @"Minute"),
                   NSLocalizedString(@"Hour", @"Hour"),
                   NSLocalizedString(@"Day", @"Day"),
                   NSLocalizedString(@"Week", @"Week"),
                   NSLocalizedString(@"Month", @"Month")
                   ];

    self.unitsPlural = @[
                         NSLocalizedString(@"Minutes", @"Minutes"),
                         NSLocalizedString(@"Hours", @"Hours"),
                         NSLocalizedString(@"Days", @"Days"),
                         NSLocalizedString(@"Weeks", @"Weeks"),
                         NSLocalizedString(@"Months", @"Months")
                         ];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (0 == component)
    {
        return self.numbers.count;
    }
    else
    {
        return self.units.count;
    }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (0 == component)
    {
        return self.numbers[row];
    }
    else
    {
        if (1 == self.selectedValue)
        {
            return self.units[row];
        }
        else
        {
            return self.unitsPlural[row];
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([self.pickerDelegate respondsToSelector:@selector(pickerTextField:didSelectRow:inComponent:)])
    {
        [self.pickerDelegate pickerTextField:self didSelectRow:row inComponent:component];
    }
    
    if (0 == component)
    {
        self.selectedValue = [self.numbers[row] integerValue];
        [pickerView reloadComponent:1];
    }
    else
    {
        self.selectedCalendarUnit = row;
    }
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self resignFirstResponder];
    
    NSCalendar         *calendar    =   [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents   *components  =   [[NSDateComponents alloc] init];
    if (self.selectedCalendarUnit == 0)
    {
        components.minute = self.selectedValue;
    }
    else if (self.selectedCalendarUnit == 1)
    {
        components.hour = self.selectedValue;
    }
    else if (self.selectedCalendarUnit == 2)
    {
        components.day = self.selectedValue;
    }
    else if (self.selectedCalendarUnit == 3)
    {
        components.week = self.selectedValue;
    }
    else if (self.selectedCalendarUnit == 4)
    {
        components.month = self.selectedValue;
    }
    
    NSDate *targetDate = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];

    if ([self.pickerDelegate respondsToSelector:@selector(pickerTextField:didSelectExpirationDate:)])
    {
        [self.pickerDelegate pickerTextField:self didSelectExpirationDate:targetDate];
    }
}

@end
