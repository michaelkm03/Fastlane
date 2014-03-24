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
#import "UIImage+ImageEffects.h"
#import "VObjectManager+Sequence.h"
#import "VConstants.h"
#import "NSString+VParseHelp.h"
#import "VThemeManager.h"

@interface VCameraPublishViewController () <UITextViewDelegate, VSetExpirationDelegate>
@property (nonatomic, weak) IBOutlet    UIImageView*    previewImage;

@property (nonatomic, weak) IBOutlet    UIButton*       durationButton;
@property (nonatomic, weak) IBOutlet    UILabel*        expiresOnLabel;

@property (nonatomic, weak) IBOutlet    UISwitch*       twitterButton;
@property (nonatomic, weak) IBOutlet    UISwitch*       facebookButton;

@property (nonatomic, weak) IBOutlet    UITextView*     textView;

@property (nonatomic, strong) IBOutlet    UIBarButtonItem*    countDownLabel;

@property (nonatomic, weak) IBOutlet    UILabel*        textViewPlaceholderLabel;

@property (nonatomic, strong)   NSString*     expirationDateString;

@property (nonatomic)           BOOL          useTwitter;
@property (nonatomic)           BOOL          useFacebook;

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
        self.previewImage.image = [self.photo applyDarkEffect];
    }
    else if (self.videoURL)
    {
        AVAsset*    asset = [AVAsset assetWithURL:self.videoURL];
        AVAssetImageGenerator*  assetGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        
        CGImageRef  imageRef    =   [assetGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:NULL];
        self.previewImage.image = [[UIImage imageWithCGImage:imageRef] applyDarkEffect];
    }

    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
}

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)hashButtonClicked:(id)sender
{
    self.textView.text = [self.textView.text stringByAppendingString:@"#"];
}

- (IBAction)publish:(id)sender
{
    VLog (@"Publishing");
    
    VShareOptions shareOptions = self.useFacebook ? VShareToFacebook : VShareNone;
    shareOptions = self.useTwitter ? shareOptions | VShareToTwitter : shareOptions;
    
    NSData* mediaData;
    NSString* mediaType;
    if (self.videoURL)
    {
        mediaData = [NSData dataWithContentsOfURL:self.videoURL];
        mediaType = VConstantMediaExtensionMOV;
    }
    else if (self.photo)
    {
        mediaData = UIImagePNGRepresentation(self.photo);
        mediaType = VConstantMediaExtensionPNG;
    }
    else
    {
        return;
    }
    if ([self.textView.text isEmpty])
    {
        return;
    }

    [[VObjectManager sharedManager] uploadMediaWithName:self.textView.text
                                            description:self.textView.text
                                              expiresAt:self.expirationDateString
                                           parentNodeId:nil
                                               loopType:VLoopOnce
                                           shareOptions:shareOptions
                                              mediaData:mediaData
                                              extension:mediaType
                                               mediaUrl:nil
                                           successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        VLog(@"Succeeded with objects: %@", resultObjects);
    }
                                              failBlock:^(NSOperation* operation, NSError* error)
    {
        VLog(@"Failed with error: %@", error);
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)twitterClicked:(id)sender
{
    self.useTwitter = self.twitterButton.on;
}

- (IBAction)facebookClicked:(id)sender
{
    self.useFacebook = self.facebookButton.on;
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
    self.textViewPlaceholderLabel.hidden = ([textView.text length] > 0);
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

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.textViewPlaceholderLabel.hidden = ([textView.text length] > 0);
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setExpiration"])
    {
        VSetExpirationViewController*   viewController = (VSetExpirationViewController *)segue.destinationViewController;
        viewController.delegate = self;
        viewController.previewImage = self.previewImage.image;
    }
}

@end
