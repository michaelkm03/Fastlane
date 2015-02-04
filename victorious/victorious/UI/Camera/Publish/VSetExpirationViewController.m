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
#import "VThemeManager.h"

@interface VSetExpirationViewController ()  <VExpirationPickerTextFieldDelegate, VExpirationDatePickerDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet    VExpirationPickerTextField     *expirationPicker;
@property (nonatomic, weak) IBOutlet    VExpirationDatePicker          *expirationDatePicker;

@property (nonatomic, weak) IBOutlet    UIButton                       *afterButton;
@property (nonatomic, weak) IBOutlet    UIButton                       *onButton;
@property (nonatomic, weak) IBOutlet    UILabel                        *videoWillExpireLabel;
@property (nonatomic, weak) IBOutlet    UIImageView                    *previewImageView;

@property (nonatomic, weak) IBOutlet    UIView                         *setExpirationView;
@property (nonatomic, weak) IBOutlet    UILabel                        *setExpirationTextField;
@property (nonatomic, weak) IBOutlet    UILabel                        *expirationLine1Label;
@property (nonatomic, weak) IBOutlet    UILabel                        *expirationLine2Label;

@property (nonatomic, weak) IBOutlet    UIButton                       *doneButton;

@property (nonatomic)                   BOOL                            useAfterMode;
@property (nonatomic, strong)           NSDate                         *expirationDate;

@property (nonatomic, strong)           NSArray                        *toolbarWithReset;
@property (nonatomic, strong)           NSArray                        *toolbarWithoutReset;
@property (nonatomic, weak) IBOutlet    UIToolbar                      *toolbar;

@end

@implementation VSetExpirationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.expirationPicker.pickerDelegate = self;
    self.expirationDatePicker.delegate = self;
    
    UIBarButtonItem    *cancelButton    =   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem    *flex            =   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem    *resetButton     =   [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ResetButton", @"") style:UIBarButtonItemStylePlain target:self action:@selector(reset:)];
    
    self.toolbarWithReset = @[cancelButton, flex, resetButton];
    self.toolbarWithoutReset = @[cancelButton, flex];
    
    self.videoWillExpireLabel.text = NSLocalizedString(@"PostWillExpire", @"");
    [self.setExpirationView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSetExpirationTapGesture:)]];
    self.setExpirationView.userInteractionEnabled = YES;
    
    self.setExpirationTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    
    self.afterButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.afterButton.backgroundColor = [UIColor colorWithWhite:0.97f alpha:1.0f];
    [self.afterButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    self.onButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.onButton.backgroundColor = [UIColor colorWithWhite:0.56f alpha:1.0f];
    [self.onButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.doneButton.backgroundColor = [UIColor colorWithWhite:0.56f alpha:1.0f];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.toolbar setItems:self.toolbarWithoutReset animated:YES];
    [self.doneButton setTitle:@"Cancel" forState:UIControlStateNormal];
    
    self.previewImageView.image = self.previewImage;

    self.expirationDate = nil;
    self.useAfterMode = YES;
    
    self.setExpirationView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    [self.toolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.toolbar setShadowImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventSetExpirationDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:VTrackingEventSetExpirationDidAppear];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    if (self.expirationDate)
    {
        UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CancelExpiration", @"")
                                                               message:NSLocalizedString(@"CancelExirationConfirm", @"")
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:NSLocalizedString(@"NoButton", @""), NSLocalizedString(@"YesButton", @""), nil];
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
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)reset:(id)sender
{
    [self.toolbar setItems:self.toolbarWithoutReset animated:YES];

    self.expirationDate = nil;
}

- (IBAction)afterButtonClicked:(id)sender
{
    self.afterButton.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self.afterButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    self.onButton.backgroundColor = [UIColor colorWithWhite:0.56 alpha:1.0];
    [self.onButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.useAfterMode = YES;
}

- (IBAction)onButtonClicked:(id)sender
{
    self.afterButton.backgroundColor = [UIColor colorWithWhite:0.56 alpha:1.0];
    [self.afterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.onButton.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self.onButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    
    self.useAfterMode = NO;
}

- (IBAction)doneClicked:(id)sender
{
    if (nil != self.expirationDate)
    {
        if ([self.delegate respondsToSelector:@selector(setExpirationViewController:didSelectDate:)])
        {
            [self.delegate setExpirationViewController:self didSelectDate:self.expirationDate];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleSetExpirationTapGesture:(id)sender
{
    self.afterButton.userInteractionEnabled = NO;
    self.onButton.userInteractionEnabled = NO;

    if (self.useAfterMode)
    {
        [self.expirationPicker becomeFirstResponder];
    }
    else
    {
        [self.expirationDatePicker becomeFirstResponder];
    }
}

- (void)setExpirationDate:(NSDate *)expirationDate
{
    if ([expirationDate isEqualToDate:_expirationDate])
    {
        return;
    }
    
    _expirationDate = expirationDate;
    
    if (expirationDate)
    {
        [UIView animateWithDuration:0.6 animations:
         ^{
            self.setExpirationTextField.alpha = 0.0;
            self.expirationLine1Label.alpha = 1.0;
            self.expirationLine2Label.alpha = 1.0;
        }];
        
        self.expirationLine1Label.text = [NSDateFormatter localizedStringFromDate:expirationDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
        self.expirationLine2Label.text = [NSDateFormatter localizedStringFromDate:expirationDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        
        [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.toolbar setItems:self.toolbarWithReset animated:YES];
        
        self.afterButton.userInteractionEnabled = YES;
        self.onButton.userInteractionEnabled = YES;
    }
    else
    {
        [UIView animateWithDuration:0.6 animations:
         ^{
            self.setExpirationTextField.alpha = 1.0;
            self.expirationLine1Label.alpha = 0.0;
            self.expirationLine2Label.alpha = 0.0;
        }];
    }
    
}

#pragma mark - Delegates

- (void)pickerTextField:(VPickerTextField *)pickerTextField didSelectExpirationDate:(NSDate *)expirationDate
{
    self.expirationDate = expirationDate;
}

- (void)pickerTextField:(VPickerTextField *)pickerTextField didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //  Ignore
}

- (void)datePicker:(VExpirationDatePicker *)datePicker didSelectExpirationDate:(NSDate *)expirationDate
{
    self.expirationDate = expirationDate;
}

@end
