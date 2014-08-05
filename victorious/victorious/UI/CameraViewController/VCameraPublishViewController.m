//
//  VCameraPublishViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VAnalyticsRecorder.h"
#import "VCameraPublishViewController.h"
#import "VContentInputAccessoryView.h"
#import "VSetExpirationViewController.h"
#import "UIImage+ImageEffects.h"
#import "VObjectManager+ContentCreation.h"
#import "VConstants.h"
#import "NSString+VParseHelp.h"
#import "VThemeManager.h"
#import "TTTAttributedLabel.h"

#import "VShareView.h"

#import "UIImage+ImageCreation.h"
#import "UIAlertView+VBlocks.h"

@interface VCameraPublishViewController () <UITextViewDelegate, VSetExpirationDelegate>
@property (nonatomic, weak) IBOutlet    UIImageView*    previewImageView;

@property (nonatomic, weak) IBOutlet    UIButton*       publishButton;

@property (nonatomic, weak) IBOutlet    UIButton*       durationButton;
@property (nonatomic, weak) IBOutlet    UILabel*        expiresOnLabel;

@property (nonatomic, weak) IBOutlet    UILabel*        shareToLabel;

@property (nonatomic, weak) IBOutlet    UISwitch*       twitterButton;
@property (nonatomic, weak) IBOutlet    UISwitch*       facebookButton;

@property (nonatomic, weak) IBOutlet    TTTAttributedLabel* textViewPlaceholderLabel;

@property (nonatomic, weak) IBOutlet    UIView*         sharesSuperview;

@property (nonatomic, weak) IBOutlet    NSLayoutConstraint* captionViewHeightConstraint;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *captionButtons;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *captionLabels;

@property (nonatomic, weak) IBOutlet    UILabel*        captionLabel;
@property (nonatomic, weak) IBOutlet    UILabel*        memeLabel;
@property (nonatomic, weak) IBOutlet    UILabel*        secretLabel;

@end

static NSString* kSecretFont = @"PT_Sans-Narrow-Web-Regular";
static NSString* kMemeFont = @"Impact";

static const CGFloat kShareMargin = 6.0f;

@implementation VCameraPublishViewController

+ (VCameraPublishViewController *)cameraPublishViewController
{
    return [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *previewImageView = self.previewImageView;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[previewImageView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(previewImageView)]];
    
    VContentInputAccessoryView *contentInputAccessory = [[VContentInputAccessoryView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    contentInputAccessory.textInputView = self.textView;
    contentInputAccessory.tintColor = [UIColor colorWithRed:0.85f green:0.86f blue:0.87f alpha:1.0f];
    self.textView.inputAccessoryView = contentInputAccessory;
    
    self.publishButton.titleLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.publishButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.publishButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton1Font];
    self.publishButton.titleLabel.text = NSLocalizedString(@"Publish", nil);
    
    self.shareToLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
    self.shareToLabel.textColor = [UIColor colorWithRed:.6f green:.6f blue:.6f alpha:1.0f];
    
    UIImage* selectedImage = [UIImage resizeableImageWithColor:[UIColor colorWithRed:.9 green:.91 blue:.92 alpha:1]];
    UIImage* unselectedImage = [UIImage resizeableImageWithColor:[UIColor colorWithRed:.96 green:.97 blue:.98 alpha:1]];
    for (UIButton* button in self.captionButtons)
    {
        button.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
        [button.titleLabel setFont:[[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font]];
        [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
        [button setBackgroundImage:unselectedImage forState:UIControlStateNormal];
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor colorWithRed:.8 green:.82 blue:.85 alpha:1].CGColor;
    }
    
    self.captionLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
    self.secretLabel.font = [UIFont fontWithName:kSecretFont size:20];
    self.memeLabel.font = [UIFont fontWithName:kMemeFont size:24];
    
    [self initShareViews];
}

- (void)initShareViews
{
    NSArray* shareNames = @[NSLocalizedString(@"facebook", nil),
                             NSLocalizedString(@"twitter", nil),
//                             NSLocalizedString(@"tumblr", nil),
                             NSLocalizedString(@"saveToLibrary", nil)];
    
    NSArray* shareImages = @[[UIImage imageNamed:@"share-btn-fb"],
                             [UIImage imageNamed:@"share-btn-twitter"],
//                             [UIImage imageNamed:@"share-btn-tumblr"],
                             [UIImage imageNamed:@"share-btn-library"]];
    
    NSArray* shareColors = @[[UIColor colorWithRed:.23f green:.35f blue:.6f alpha:1.0f],
                             [UIColor colorWithRed:.1f green:.7f blue:.91f alpha:1.0f],
//                             [UIColor colorWithRed:.17f green:.28f blue:.38f alpha:1],
                             [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]];
    
    NSAssert(shareNames.count == shareImages.count && shareImages.count == shareColors.count, @"There should be an equal number of these...");
    
    NSMutableArray* shareViews = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[shareNames count];i++)
    {
        VShareView* shareView = [[VShareView alloc] initWithTitle:shareNames[i] image:shareImages[i]];
        shareView.selectedColor = shareColors[i];
        
        CGFloat shareViewWidth = shareView.frame.size.width;
        CGFloat widthOfShareViews = (shareNames.count * shareViewWidth) + ((shareNames.count - 1) * kShareMargin);
        CGFloat superviewMargin = (self.sharesSuperview.frame.size.width - widthOfShareViews) / 2;
        CGFloat xCenter = superviewMargin + (shareViewWidth / 2) + (i * shareViewWidth) + (i * kShareMargin);
        
        shareView.center = CGPointMake(xCenter, self.sharesSuperview.frame.size.height / 2);
        
        [shareViews addObject:shareView];
        [self.sharesSuperview addSubview:shareView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.previewImage)
    {
        self.previewImageView.image = [self.previewImage applyDarkEffect];
    }

    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;

    UIImage*    cancelButtonImage = [[UIImage imageNamed:@"cameraButtonClose"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem*    cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    NSString* mediaExtension = [[self.mediaURL absoluteString] pathExtension];
    if ([mediaExtension isEqualToString:VConstantMediaExtensionMOV]
        || [mediaExtension isEqualToString:VConstantMediaExtensionMP4])
        self.captionViewHeightConstraint.constant = 0;
    
    [self.textViewPlaceholderLabel setText:NSLocalizedString(@"AddDescription", @"") afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange hashtagRange = [[mutableAttributedString string] rangeOfString:NSLocalizedString(@"AddDescriptionAnchor", @"")];
        
        UIFont* headerFont = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)headerFont.fontName, headerFont.pointSize, NULL);
        
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:NSMakeRange(0, [mutableAttributedString length])];
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:[[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor] range:hashtagRange];
        
        return mutableAttributedString;
    }];
    
    self.textView.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
//    [self.textView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Camera Publish"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
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

- (IBAction)goBack:(id)sender
{
    if (self.completion)
    {
        self.completion(NO);
    }
}

- (IBAction)cancel:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"areYouSure", nil)
                                                    message:NSLocalizedString(@"contentIsntPublished", nil)
                                          cancelButtonTitle:NSLocalizedString(@"CancelButton", nil)
                                             onCancelButton:nil
                                 otherButtonTitlesAndBlocks:NSLocalizedString(@"Exit", nil), ^(void)
                          {
                              [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation
                                                                                           action:@"Camera Publish Cancelled"
                                                                                            label:nil
                                                                                            value:nil];
                              if (self.completion)
                              {
                                  self.completion(YES);
                              }
                          },
                          
                          nil];
    
    [alert show];
}

- (IBAction)hashButtonClicked:(id)sender
{
    self.textView.text = [self.textView.text stringByAppendingString:@"#"];
    if ([self respondsToSelector:@selector(textViewDidChange:)])
    {
        [self textViewDidChange:self.textView];
    }
}

- (IBAction)publish:(id)sender
{
    VLog (@"Publishing");
    
    if ([self.textView.text isEmpty])
    {
        UIAlertView*    alert   = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PublishDescriptionRequired", @"")
                                                             message:NSLocalizedString(@"PublishDescription", @"")
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
        [alert show];
        return;
    }
    
    VShareOptions shareOptions = self.useFacebook ? kVShareToFacebook : kVShareNone;
    shareOptions = self.useTwitter ? shareOptions | kVShareToTwitter : shareOptions;
    
    CGFloat playbackSpeed;
    if (self.playBackSpeed == kVPlaybackNormalSpeed)
        playbackSpeed = 1.0;
    else if (self.playBackSpeed == kVPlaybackDoubleSpeed)
        playbackSpeed = 2.0;
    else
        playbackSpeed = 0.5;
    
    [[VObjectManager sharedManager] uploadMediaWithName:self.textView.text
                                            description:self.textView.text
                                              expiresAt:self.expirationDateString
                                           parentNodeId:@(self.parentID)
                                                  speed:playbackSpeed
                                               loopType:self.playbackLooping
                                           shareOptions:shareOptions
                                               mediaURL:self.mediaURL
                                           successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        UIAlertView*    alert   = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PublishSucceeded", @"")
                                                             message:NSLocalizedString(@"PublishSucceededDetail", @"")
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
        [alert show];
    }
                                              failBlock:^(NSOperation* operation, NSError* error)
    {
        VLog(@"Failed with error: %@", error);
        
        if (kVStillTranscodingError == error.code)
        {
            UIAlertView*    alert   = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TranscodingMediaTitle", @"")
                                                                 message:NSLocalizedString(@"TranscodingMediaBody", @"")
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
            [alert show];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UploadFailedTitle", @"")
                                                            message:NSLocalizedString(@"UploadErrorBody", @"")
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
            [alert show];
        }
    }
                                      shouldRemoveMedia:YES];
    
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryInteraction action:@"Post Content" label:self.textView.text value:nil];
    
    if (self.completion)
    {
        self.completion(YES);
    }
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
    self.expiresOnLabel.text = [NSString stringWithFormat:NSLocalizedString(@"ExpiresOn", @""), [NSDateFormatter localizedStringFromDate:expirationDate
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
    
    return [sRFC2822DateFormatter stringFromDate:date];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.textViewPlaceholderLabel.hidden = ([textView.text length] > 0);
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
        viewController.previewImage = self.previewImageView.image;
    }
}

@end
