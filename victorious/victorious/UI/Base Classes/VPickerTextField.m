//
//  VPickerTextField.m
//  HIFramework-iOS
//
//  Created by Gary Philipp on 1/28/14.
//  Copyright (c) 2014 Gary Philipp. All rights reserved.
//

#import "VPickerTextField.h"

@interface      VPickerTextField () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) UIToolbar *toolbar;
@end

@implementation VPickerTextField

- (instancetype)initWithFrame:(CGRect)aRect
{
    if (self = [super initWithFrame:aRect])
    {
        self.inputView = [self createInputView];
        self.inputAccessoryView = [self createInputAccessoryView];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.inputView = [self createInputView];
        self.inputAccessoryView = [self createInputAccessoryView];
    }
    
    return self;
}

- (UIView *)createInputView
{
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.picker.showsSelectionIndicator = YES;
    self.picker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.picker.dataSource = self;
    self.picker.delegate = self;
    self.picker.backgroundColor = [UIColor whiteColor];
    
    return self.picker;
}

- (UIView *)createInputAccessoryView
{
    if (!self.toolbar)
    {
        self.toolbar = [[UIToolbar alloc] init];
        self.toolbar.barStyle = UIBarStyleDefault;
        self.toolbar.translucent = YES;
        self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.toolbar sizeToFit];
        
        CGRect frame = self.toolbar.frame;
        frame.size.height = 44.0f;
        self.toolbar.frame = frame;

        UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(clear:)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        [self.toolbar setItems:@[clearButton, flexibleSpace, doneButton]];
    }
    
    return self.toolbar;
}

- (void)deviceDidRotate:(NSNotification*)notification
{
    [self.picker setNeedsLayout];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerData.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([self.pickerDelegate respondsToSelector:@selector(pickerTextField:didSelectRow:inComponent:)])
        [self.pickerDelegate pickerTextField:self didSelectRow:row inComponent:component];
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self resignFirstResponder];
}

- (IBAction)clear:(id)sender
{
    if ([self.pickerDelegate respondsToSelector:@selector(pickerTextFieldDidClear:)])
        [self.pickerDelegate pickerTextFieldDidClear:self];

    [self resignFirstResponder];
}

@end
