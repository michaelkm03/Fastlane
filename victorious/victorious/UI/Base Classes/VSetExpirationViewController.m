//
//  VSetExpirationViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSetExpirationViewController.h"
#import "VExpirationPickerTextField.h"
#import "VExpirationDatePicker.h"
#import "UIImage+ImageEffects.h"

@interface VSetExpirationViewController ()  <VExpirationPickerTextFieldDelegate, VExpirationDatePickerDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet    VExpirationPickerTextField*     expirationPicker;
@property (nonatomic, weak) IBOutlet    VExpirationDatePicker*          expirationDatePicker;

@property (nonatomic, weak) IBOutlet    UIButton*                       afterButton;
@property (nonatomic, weak) IBOutlet    UIButton*                       onButton;
@property (nonatomic, weak) IBOutlet    UILabel*                        videoWillExpireLabel;
@property (nonatomic, weak) IBOutlet    UIButton*                       setExpirationButton;
@property (nonatomic, weak) IBOutlet    UIImageView*                    previewImageView;

@property (nonatomic, weak) IBOutlet    UIButton*                       doneButton;

@property (nonatomic)                   BOOL                            useAfterMode;
@property (nonatomic, strong)           NSDate*                         expirationDate;

@property (nonatomic, strong)           NSArray*                        toolbarWithReset;
@property (nonatomic, strong)           NSArray*                        toolbarWithoutReset;
@property (nonatomic, weak) IBOutlet    UIToolbar*                      toolbar;

@end

@implementation VSetExpirationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.expirationPicker.pickerDelegate = self;
    self.expirationDatePicker.delegate = self;
    
    UIBarButtonItem*    cancelButton    =   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem*    flex            =   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem*    resetButton     =   [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStyleBordered target:self action:@selector(reset:)];
    
    self.toolbarWithReset = @[cancelButton, flex, resetButton];
    self.toolbarWithoutReset = @[cancelButton, flex];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.toolbar setItems:self.toolbarWithoutReset animated:YES];
    [self.doneButton setTitle:@"Cancel" forState:UIControlStateNormal];
    
    self.previewImageView.image = self.previewImage;

    self.expirationDate = nil;
    self.useAfterMode = YES;
    
    [self.toolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.toolbar setShadowImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny];
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    if (self.expirationDate)
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Cancel Expiration?"
                                                               message:@"Are you sure you want to cancel out of setting an expiration date?"
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@"No", @"Yes", nil];
        [alert show];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.firstOtherButtonIndex != buttonIndex)
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)reset:(id)sender
{
    [self.toolbar setItems:self.toolbarWithoutReset animated:YES];
    [self.setExpirationButton setTitle:@"Set An Expiration" forState:UIControlStateNormal];
    self.expirationDate = nil;
}

- (IBAction)afterButtonClicked:(id)sender
{
    [self.afterButton setImage:[UIImage imageNamed:@"cameraButtonAfterOn"] forState:UIControlStateNormal];
    [self.onButton setImage:[UIImage imageNamed:@"cameraButtonOnOff"] forState:UIControlStateNormal];
    
    self.useAfterMode = YES;
}

- (IBAction)onButtonClicked:(id)sender
{
    [self.afterButton setImage:[UIImage imageNamed:@"cameraButtonAfterOff"] forState:UIControlStateNormal];
    [self.onButton setImage:[UIImage imageNamed:@"cameraButtonOnOn"] forState:UIControlStateNormal];
    
    self.useAfterMode = NO;
}

- (IBAction)doneClicked:(id)sender
{
    if (nil != self.expirationDate)
    {
        [self.delegate setExpirationViewController:self didSelectDate:self.expirationDate];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)setExpirationClicked:(id)sender
{
    if (self.useAfterMode)
        [self.expirationPicker becomeFirstResponder];
    else
        [self.expirationDatePicker becomeFirstResponder];
}

#pragma mark - Delegates

- (void)pickerTextField:(VPickerTextField *)pickerTextField didSelectExpirationDate:(NSDate *)expirationDate
{
    [self.setExpirationButton setTitle:[NSDateFormatter localizedStringFromDate:expirationDate
                                                                      dateStyle:NSDateFormatterLongStyle
                                                                      timeStyle:NSDateFormatterShortStyle]
                              forState:UIControlStateNormal];
    self.expirationDate = expirationDate;
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.toolbar setItems:self.toolbarWithReset animated:YES];
}

- (void)pickerTextField:(VPickerTextField *)pickerTextField didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //  Ignore
}

- (void)datePicker:(VExpirationDatePicker *)datePicker didSelectExpirationDate:(NSDate *)expirationDate
{
    [self.setExpirationButton setTitle:[NSDateFormatter localizedStringFromDate:expirationDate
                                                                      dateStyle:NSDateFormatterLongStyle
                                                                      timeStyle:NSDateFormatterShortStyle]
                              forState:UIControlStateNormal];
    self.expirationDate = expirationDate;
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.toolbar setItems:self.toolbarWithReset animated:YES];
}

@end
