//
//  VCameraPublishViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VCameraPublishViewController.h"
#import "VExpirationPickerTextField.h"
#import "VExpirationDatePicker.h"

@interface VCameraPublishViewController () <VExpirationPickerTextFieldDelegate, VExpirationDatePickerDelegate>
@property (nonatomic, weak) IBOutlet    UIImageView*    previewImage;

@property (nonatomic, weak) IBOutlet    UIButton*       durationButton;

@property (nonatomic, weak) IBOutlet    UISwitch*       twitterButton;
@property (nonatomic, weak) IBOutlet    UISwitch*       facebookButton;

@property (nonatomic, weak) IBOutlet    VExpirationPickerTextField* expirationPickerField;
@property (nonatomic, weak) IBOutlet    VExpirationDatePicker* datePickerField;
@property (nonatomic, weak) IBOutlet    UITextView*     textView;
@end

@implementation VCameraPublishViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.photo)
    {
        self.previewImage.image = self.photo;
    }
    else if (self.videoURL)
    {
        AVAsset*    asset = [AVAsset assetWithURL:self.videoURL];
        AVAssetImageGenerator*  assetGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        
        CGImageRef  imageRef    =   [assetGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:NULL];
        self.previewImage.image = [UIImage imageWithCGImage:imageRef];
    }

    self.view.backgroundColor = [UIColor lightGrayColor];
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
}

#pragma mark - Actions

- (IBAction)expirationButtonClicked:(id)sender
{
    
}

#pragma mark - 

- (void)pickerTextField:(VPickerTextField *)pickerTextField didSelectExpirationDate:(NSDate *)expirationDate
{
    NSString*   expirationDateString = [self stringForRFC2822Date:expirationDate];
}

- (void)pickerTextField:(VPickerTextField *)pickerTextField didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //  Ignore
}

- (void)datePicker:(VExpirationDatePicker *)datePicker didSelectExpirationDate:(NSDate *)expirationDate
{
    NSString*   expirationDateString = [self stringForRFC2822Date:expirationDate];
}

#pragma mark - Support

- (NSString *)stringForRFC2822Date:(NSDate *)date
{
    static NSDateFormatter *sRFC2822DateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sRFC2822DateFormatter = [[NSDateFormatter alloc] init];
        sRFC2822DateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z"; //RFC2822-Format
        
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [sRFC2822DateFormatter setTimeZone:gmt];
    });
    
    return[sRFC2822DateFormatter stringFromDate:date];
}

@end
