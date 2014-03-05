//
//  VCameraPublishViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VCameraPublishViewController.h"
#import "VSetExpirationViewController.h"

@interface VCameraPublishViewController () <UITextViewDelegate, VSetExpirationDelegate>
@property (nonatomic, weak) IBOutlet    UIImageView*    previewImage;

@property (nonatomic, weak) IBOutlet    UIButton*       durationButton;
@property (nonatomic, weak) IBOutlet    UILabel*        expiresOnLabel;

@property (nonatomic, weak) IBOutlet    UISwitch*       twitterButton;
@property (nonatomic, weak) IBOutlet    UISwitch*       facebookButton;

@property (nonatomic, weak) IBOutlet    UITextView*     textView;

@property (nonatomic, strong) IBOutlet    UIBarButtonItem*    countDownLabel;

@property (nonatomic, strong)   NSString*     expirationDateString;

@end

@implementation VCameraPublishViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createInputAccessoryView];
    
    self.textView.delegate = self;
}

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

    self.view.backgroundColor = [[UIColor alloc] initWithRed:280.0 green:248.0 blue:248.0 alpha:1.0];
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
}

#pragma mark - Actions

- (IBAction)hashButtonClicked:(id)sender
{
    self.textView.text = [self.textView.text stringByAppendingString:@"#"];
}

- (IBAction)publish:(id)sender
{
    VLog (@"Publishing");
    
    //  Twitter State
    //  Facebook State
    //  Expiration Date
    //  Media URL
    //  Media Type
}

#pragma mark - Delegates

- (void)setExpirationViewController:(VSetExpirationViewController *)viewController didSelectDate:(NSDate *)expirationDate
{
    self.expirationDateString = [self stringForRFC2822Date:expirationDate];
    self.expiresOnLabel.text = [NSString stringWithFormat:@"Expires on %@", [NSDateFormatter localizedStringFromDate:expirationDate
                                                                                                           dateStyle:NSDateFormatterLongStyle
                                                                                                           timeStyle:NSDateFormatterShortStyle]];
}

#pragma mark - Support

- (NSString *)stringForRFC2822Date:(NSDate *)date
{
    static NSDateFormatter *sRFC2822DateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sRFC2822DateFormatter = [[NSDateFormatter alloc] init];
        sRFC2822DateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z"; //RFC2822-Format
        
        [sRFC2822DateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    });
    
    return[sRFC2822DateFormatter stringFromDate:date];
}

- (void)createInputAccessoryView
{
    UIToolbar*  toolbar =   [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    
    UIBarButtonItem*    hashButton  =   [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraButtonHashTagAdd"]
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(hashButtonClicked:)];
    UIBarButtonItem*    flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil
                                                                                      action:nil];
    
    self.countDownLabel = [[UIBarButtonItem alloc] initWithTitle:@"140"
                                                           style:UIBarButtonItemStyleBordered
                                                            target:nil
                                                          action:nil];
    
    toolbar.items = @[hashButton, flexibleSpace, self.countDownLabel];
    self.textView.inputAccessoryView = toolbar;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.countDownLabel.title = [NSNumberFormatter localizedStringFromNumber:@(140.0 - self.textView.text.length)
                                                                 numberStyle:NSNumberFormatterDecimalStyle];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setExpiration"])
    {
        VSetExpirationViewController*   viewController = (VSetExpirationViewController *)segue.destinationViewController;
        viewController.delegate = self;
        viewController.previewImage = self.photo;
    }
}

@end
