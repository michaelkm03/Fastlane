//
//  VCameraPublishViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;
@import AssetsLibrary;

#import "VAnalyticsRecorder.h"
#import "VCameraPublishViewController.h"
#import "VContentInputAccessoryView.h"
#import "VSetExpirationViewController.h"
#import "UIImage+ImageEffects.h"
#import "VObjectManager+ContentCreation.h"
#import "VObjectManager+Users.h"
#import "VConstants.h"
#import "NSString+VParseHelp.h"
#import "VThemeManager.h"
#import "TTTAttributedLabel.h"

#import "VShareView.h"

#import "UIImage+ImageCreation.h"
#import "UIActionSheet+VBlocks.h"

#import "VCompositeSnapshotController.h"
#import "VSettingManager.h"

#import "VFacebookManager.h"
#import "VUserManager.h"

#import "NSURL+MediaType.h"

static NSString* kVSaveToCameraRollDisabledKey = @"saveToCameraKey";
static NSString* kVShareToFacebookDisabledKey  = @"shareToFBKey";
static NSString* kVShareToTwitterDisabledKey = @"shareToTwtrKey";

@interface VCameraPublishViewController () <UITextViewDelegate, VSetExpirationDelegate>
@property (nonatomic, weak) IBOutlet    UIImageView*    previewImageView;

@property (nonatomic, weak) IBOutlet    UIButton*       publishButton;

@property (nonatomic, weak) IBOutlet    UIButton*       durationButton;
@property (nonatomic, weak) IBOutlet    UILabel*        expiresOnLabel;

@property (nonatomic, weak) IBOutlet    UILabel*        shareToLabel;

@property (nonatomic, weak) IBOutlet    UISwitch*       twitterButton;
@property (nonatomic, weak) IBOutlet    UISwitch*       facebookButton;

@property (nonatomic, weak) IBOutlet    TTTAttributedLabel* captionPlaceholderLabel;

@property (nonatomic, weak) IBOutlet    UIView*         sharesSuperview;

@property (nonatomic, strong) IBOutlet  NSLayoutConstraint* originalTextViewYConstraint;//This is intentionally strong
@property (nonatomic, strong)           NSLayoutConstraint* quoteTextViewYConstraint;
@property (nonatomic, strong)           NSLayoutConstraint* memeTextViewYConstraint;

@property (nonatomic, weak) IBOutlet    NSLayoutConstraint* captionViewHeightConstraint;

@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *captionButtons;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *captionLabels;

@property (nonatomic, strong) NSMutableDictionary* typingAttributes;

@property (nonatomic, weak) IBOutlet UIButton* captionButton;
@property (nonatomic, weak) IBOutlet UIButton* memeButton;
@property (nonatomic, weak) IBOutlet UIButton* quoteButton;

@property (nonatomic, strong) VShareView* saveToCameraView;
@property (nonatomic, strong) VShareView* shareToTwitterView;
@property (nonatomic, strong) VShareView* shareToFacebookView;

@property (nonatomic, strong) VCompositeSnapshotController* snapshotController;

@end

static NSString* kQuoteFont = @"PTSans-Narrow";
static NSString* kMemeFont = @"Impact";

static const CGFloat kShareMargin = 34.0f;

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
    
    VContentInputAccessoryView *contentInputAccessory = [[VContentInputAccessoryView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f)];
    contentInputAccessory.textInputView = self.textView;
    contentInputAccessory.tintColor = [UIColor colorWithRed:0.85f green:0.86f blue:0.87f alpha:1.0f];
    self.textView.inputAccessoryView = contentInputAccessory;
    
    self.snapshotController = [[VCompositeSnapshotController alloc] init];
    
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
    
    [self setDefaultCaptionText];
    
    self.quoteTextViewYConstraint = [NSLayoutConstraint constraintWithItem:self.textView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.previewImageView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.0];
    
    self.memeTextViewYConstraint = [NSLayoutConstraint constraintWithItem:self.originalTextViewYConstraint.firstItem
                                                                attribute:self.originalTextViewYConstraint.firstAttribute
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.originalTextViewYConstraint.secondItem
                                                                attribute:self.originalTextViewYConstraint.secondAttribute
                                                               multiplier:self.originalTextViewYConstraint.multiplier
                                                                 constant:self.originalTextViewYConstraint.constant];

    [self initShareViews];
}

- (void)setCaptionType:(VCaptionType)captionType
{
    _captionType = captionType;
    
    if (captionType == VCaptionTypeMeme)
    {
        [self.view removeConstraint:self.quoteTextViewYConstraint];
        [self.view removeConstraint:self.originalTextViewYConstraint];
        [self.view addConstraint:self.memeTextViewYConstraint];
        
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment                = NSTextAlignmentCenter;
        self.typingAttributes = [@{
                                   NSParagraphStyleAttributeName : paragraphStyle,
                                   NSFontAttributeName : [UIFont fontWithName:kMemeFont size:self.textView.frame.size.height],
                                   NSForegroundColorAttributeName : [UIColor whiteColor],
                                   NSStrokeColorAttributeName : [UIColor blackColor],
                                   NSStrokeWidthAttributeName : @(-5.0)
                                   } mutableCopy];
    }
    else if (captionType == VCaptionTypeQuote)
    {
        [self.view removeConstraint:self.originalTextViewYConstraint];
        [self.view removeConstraint:self.memeTextViewYConstraint];
        [self.view addConstraint:self.quoteTextViewYConstraint];
        
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment                = NSTextAlignmentCenter;
        self.typingAttributes = [@{
                                   NSParagraphStyleAttributeName : paragraphStyle,
                                   NSFontAttributeName : [UIFont fontWithName:kQuoteFont size:20],
                                   NSForegroundColorAttributeName : [UIColor whiteColor],
                                   NSStrokeColorAttributeName : [UIColor whiteColor],
                                   NSStrokeWidthAttributeName : @(0)
                                   } mutableCopy];

    }
    else if (captionType == VCaptionTypeNormal)
    {
        [self.view removeConstraint:self.quoteTextViewYConstraint];
        [self.view removeConstraint:self.memeTextViewYConstraint];
        [self.view addConstraint:self.originalTextViewYConstraint];
        
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment                = NSTextAlignmentLeft;
        self.typingAttributes = [@{
                                   NSParagraphStyleAttributeName : paragraphStyle,
                                   NSFontAttributeName : [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font],
                                   NSForegroundColorAttributeName : [UIColor whiteColor],
                                   NSStrokeColorAttributeName : [UIColor whiteColor],
                                   NSStrokeWidthAttributeName : @(0)
                                   } mutableCopy];
    }
    //This is a hack.  In the event that self.textView.text is an empty string, the attributes of the string won't change.
    //So we add a non empty string with the attributes first so we are sure to clear the old attribute values, then add the real string.
    NSString* originalText = self.textView.text;
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:@"This is going to be replaced" attributes:self.typingAttributes];
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:originalText attributes:self.typingAttributes];
    
    self.textView.font = self.typingAttributes[NSFontAttributeName];
    [self textViewDidChange:self.textView];
    
    self.captionPlaceholderLabel.font = self.textView.font;
    self.captionPlaceholderLabel.textAlignment = self.textView.textAlignment;
    
    [self setDefaultCaptionText];
}

- (void)initShareViews
{
//SETUP FACEBOOK SHARE
    self.shareToFacebookView = [[VShareView alloc] initWithTitle:NSLocalizedString(@"facebook", nil)
                                                          image:[UIImage imageNamed:@"share-btn-fb"]];
    self.shareToFacebookView.selectedColor = [UIColor colorWithRed:.23f green:.35f blue:.6f alpha:1.0f];
    if ([[VFacebookManager sharedFacebookManager] isSessionValid])
        self.shareToFacebookView.selected = ![[NSUserDefaults standardUserDefaults] boolForKey:kVShareToFacebookDisabledKey] && [[VFacebookManager sharedFacebookManager] isSessionValid];
//    else if (![[VFacebookManager sharedFacebookManager] isSessionValid])
//    {
//        self.shareToFacebookView.selected = NO;
//        __weak VShareView* weakFBShare = self.shareToFacebookView;
//        
//        self.shareToFacebookView.selectionBlock = ^()
//        {
//            __block BOOL loggedIn = NO;
//            [[VFacebookManager sharedFacebookManager] loginWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView
//                                                              onSuccess:^
//             {
//                 [[VObjectManager sharedManager] attachAccountToFacebookWithToken:[[VFacebookManager sharedFacebookManager] accessToken]
//                                                               forceAccountUpdate:YES
//                                                                 withSuccessBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
//                 {
//                     loggedIn = YES;
//                     weakFBShare.selectionBlock = nil;
//                 }
//                                                                        failBlock:^(NSOperation* operation, NSError* error)
//                 {
//                     loggedIn = NO;
//                 }];
//             }
//                                                              onFailure:^(NSError *error)
//             {
//                 loggedIn = NO;
//             }];
//            return loggedIn;
//        };
//    }

//SETUP TWITTER SHARE
    self.shareToTwitterView = [[VShareView alloc] initWithTitle:NSLocalizedString(@"twitter", nil)
                                                          image:[UIImage imageNamed:@"share-btn-twitter"]];
    self.shareToTwitterView.selectedColor = [UIColor colorWithRed:.1f green:.7f blue:.91f alpha:1.0f];
    self.shareToTwitterView.selected = ![[NSUserDefaults standardUserDefaults] boolForKey:kVShareToTwitterDisabledKey];
    
//SETUP SAVE TO CAMERA
    self.saveToCameraView = [[VShareView alloc] initWithTitle:NSLocalizedString(@"saveToLibrary", nil)
                                                          image:[UIImage imageNamed:@"share-btn-library"]];
    self.saveToCameraView.selectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.saveToCameraView.selected = ![[NSUserDefaults standardUserDefaults] boolForKey:kVSaveToCameraRollDisabledKey];
    
//LAYOUT SHARE VIEWS
    NSArray* shareViews = @[self.shareToFacebookView, self.shareToTwitterView, self.saveToCameraView];
    for (int i=0; i<shareViews.count;i++)
    {
        UIView* shareView = shareViews[i];
        
        CGFloat shareViewWidth = shareView.frame.size.width;
        CGFloat widthOfShareViews = (shareViews.count * shareViewWidth) + ((shareViews.count - 1) * kShareMargin);
        CGFloat superviewMargin = (self.sharesSuperview.frame.size.width - widthOfShareViews) / 2;
        CGFloat xCenter = superviewMargin + (shareViewWidth / 2) + (i * shareViewWidth) + (i * kShareMargin);
        
        shareView.center = CGPointMake(xCenter, self.sharesSuperview.frame.size.height / 2);
        
        [self.sharesSuperview addSubview:shareView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.previewImageView.image = self.previewImage;
    if (self.previewImage)
    {
        self.previewImageView.image = [self.previewImage applyBlurWithRadius:0 tintColor:[UIColor colorWithWhite:0.11 alpha:0.73] saturationDeltaFactor:1.8 maskImage:nil];
    }

    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;

    UIImage*    cancelButtonImage = [[UIImage imageNamed:@"cameraButtonClose"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    cancelButtonImage = [cancelButtonImage scaleToSize:CGSizeMake(17, 17)];
    UIBarButtonItem*    cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = cancelButton;

    self.memeButton.selected = self.captionType == VCaptionTypeMeme;
    self.captionButton.selected = self.captionType == VCaptionTypeNormal;
    self.quoteButton.selected = self.captionType == VCaptionTypeQuote;
    
    if ( ![[VSettingManager sharedManager] settingEnabledForKey:kVMemeAndQuoteEnabled]
        || [self.mediaURL v_hasVideoExtension])
        self.captionViewHeightConstraint.constant = 0;
    
    self.textView.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
}

- (void)setDefaultCaptionText
{
    if (self.captionType == VCaptionTypeNormal)
    {
        [self.captionPlaceholderLabel setText:NSLocalizedString(@"AddDescription", @"") afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            NSRange hashtagRange = [[mutableAttributedString string] rangeOfString:NSLocalizedString(@"AddDescriptionAnchor", @"")];
            
            UIFont* headerFont = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)headerFont.fontName, headerFont.pointSize, NULL);
            
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:NSMakeRange(0, [mutableAttributedString length])];
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:[[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor] range:hashtagRange];
            
            return mutableAttributedString;
        }];
        return;
    }

    NSMutableDictionary* placeholderAttributes = [self.typingAttributes mutableCopy];
    if (self.captionType == VCaptionTypeMeme)
    {
        placeholderAttributes[NSFontAttributeName] = [placeholderAttributes[NSFontAttributeName] fontWithSize:24];
    }
    
    self.captionPlaceholderLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"InsertTextHere", nil)
                                                                                  attributes:placeholderAttributes];
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
    [[NSUserDefaults standardUserDefaults] setBool:!self.shareToTwitterView.selected forKey:kVShareToTwitterDisabledKey];
    [[NSUserDefaults standardUserDefaults] setBool:!self.shareToFacebookView.selected forKey:kVShareToFacebookDisabledKey];
    [[NSUserDefaults standardUserDefaults] setBool:!self.saveToCameraView.selected forKey:kVSaveToCameraRollDisabledKey];
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

- (IBAction)changeCaptionType:(id)sender
{
    for (UIButton* button in self.captionButtons)
    {
        button.selected = (button == (UIButton*)sender);
    }
    
    if ((UIButton*)sender == self.memeButton)
    {
        self.captionType = VCaptionTypeMeme;
    }
    else if ((UIButton*)sender == self.quoteButton)
    {
        self.captionType = VCaptionTypeQuote;
    }
    else if ((UIButton*)sender == self.captionButton)
    {
        self.captionType = VCaptionTypeNormal;
    }
    [self.textView becomeFirstResponder];
}

- (IBAction)goBack:(id)sender
{
    if (self.completion)
    {
        self.completion(NO);
    }
}

- (IBAction)cancel:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"contentIsntPublished", nil)
                                                    cancelButtonTitle:NSLocalizedString(@"CancelButton", nil)
                                                       onCancelButton:nil
                                               destructiveButtonTitle:NSLocalizedString(@"Exit", nil)
                                                  onDestructiveButton:^(void)
                                  {
                                      [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation
                                                                                                   action:@"Camera Publish Cancelled"
                                                                                                    label:nil
                                                                                                    value:nil];
                                      if (self.completion)
                                      {
                                          self.completion(YES);
                                      }
                                  }
                                           otherButtonTitlesAndBlocks:nil];
    [actionSheet showInView:self.view];
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
  
    if (self.captionType == VCaptionTypeMeme || self.captionType == VCaptionTypeQuote)
    {
        UIImage* image = [self.snapshotController snapshotOfMainView:self.previewImageView subViews:@[self.textView]];
        
        NSURL *originalMediaURL = self.mediaURL;
        NSData *filteredImageData = UIImageJPEGRepresentation(image, VConstantJPEGCompressionQuality);
        NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
        if ([filteredImageData writeToURL:tempFile atomically:NO])
        {
            self.mediaURL = tempFile;
            [[NSFileManager defaultManager] removeItemAtURL:originalMediaURL error:nil];
        }
    }
    
    VShareOptions shareOptions = self.shareToFacebookView.selected ? VShareToFacebook : VShareNone;
    shareOptions = self.shareToTwitterView.selected ? shareOptions | VShareToTwitter : shareOptions;
    
    CGFloat playbackSpeed;
    if (self.playBackSpeed == VPlaybackNormalSpeed)
        playbackSpeed = 1.0;
    else if (self.playBackSpeed == VPlaybackDoubleSpeed)
        playbackSpeed = 2.0;
    else
        playbackSpeed = 0.5;
    
    [[VObjectManager sharedManager] uploadMediaWithName:self.textView.text
                                            description:self.textView.text
                                            captionType:self.captionType
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
    }];
    
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryInteraction action:@"Post Content" label:self.textView.text value:nil];
    
    if (self.saveToCameraView.selected && !self.didSelectAssetFromLibrary)
    {
        if ([self.mediaURL v_hasVideoExtension])
        {
            UISaveVideoAtPathToSavedPhotosAlbum([self.mediaURL path], nil, nil, nil);
        }
        else if ([self.mediaURL v_hasImageExtension])
        {
            UIImage*    photo = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.mediaURL]];
            UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil);
        }
    }
    
    if (self.completion)
    {
        self.completion(YES);
    }
}

#pragma mark - Delegates

- (void)setExpirationViewController:(VSetExpirationViewController *)viewController didSelectDate:(NSDate *)expirationDate
{
    self.expirationDateString = [self stringForRFC2822Date:expirationDate];
    self.expiresOnLabel.text = [NSString stringWithFormat:NSLocalizedString(@"ExpiresOn", @""), [NSDateFormatter localizedStringFromDate:expirationDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle]];
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

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.captionPlaceholderLabel.hidden = YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.captionType == VCaptionTypeMeme)
    {
        self.textView.font = [self.typingAttributes[NSFontAttributeName] fontWithSize:self.textView.frame.size.height];
        
        CGFloat realHeight = ((CGSize) [self.textView sizeThatFits:self.textView.frame.size]).height;
        while (realHeight > self.textView.frame.size.height)
        {
            CGFloat newFontSize = self.textView.font.pointSize-2;
            
            if (newFontSize < self.textView.frame.size.height/5)
                break;
            
            self.textView.font = [self.textView.font fontWithSize:newFontSize];;
            realHeight = ((CGSize) [self.textView sizeThatFits:self.textView.frame.size]).height;
        }
        self.typingAttributes[NSFontAttributeName] = self.textView.font;
        self.captionPlaceholderLabel.attributedText = [[NSAttributedString alloc] initWithString:self.captionPlaceholderLabel.attributedText.string
                                                                                      attributes:self.typingAttributes];
        
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.textView.text attributes:self.typingAttributes];
        self.textView.attributedText = str;
        
        self.memeTextViewYConstraint.constant = self.originalTextViewYConstraint.constant - self.textView.frame.size.height + realHeight;
    }
    else if (self.captionType == VCaptionTypeQuote)
    {
        CGFloat realHeight = ((CGSize) [self.textView sizeThatFits:self.textView.frame.size]).height;
        
        self.quoteTextViewYConstraint.constant = (self.textView.frame.size.height - realHeight) / 2;
    }
    else
    {
        self.captionPlaceholderLabel.hidden = ([textView.text length] > 0);
    }
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
    self.captionPlaceholderLabel.hidden = ([textView.text length] > 0);
    
    [self setDefaultCaptionText];
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
