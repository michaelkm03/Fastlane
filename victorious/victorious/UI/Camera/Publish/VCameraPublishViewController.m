//
//  VCameraPublishViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

// Analytics
#import "VAnalyticsRecorder.h"

// Model
#import "VObjectManager+ContentCreation.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Sequence.h"
// Managers
#import "VSettingManager.h"
#import "VTwitterManager.h"
#import "VFacebookManager.h"

// Theme
#import "VThemeManager.h"

// Views
#import "VPublishShareView.h"
#import "TTTAttributedLabel.h"
#import "VContentInputAccessoryView.h"

// Utility Categories
#import "UIImage+ImageCreation.h"
#import "UIActionSheet+VBlocks.h"
#import "NSString+VParseHelp.h"
#import "UIImage+ImageEffects.h"
#import "NSURL+MediaType.h"
#import "NSString+RFC2822Date.h"

// Controllers
#import "VCompositeSnapshotController.h"
#import "VTwitterPublishShareController.h"
#import "VCameraRollPublishShareController.h"
#import "VFacebookPublishShareController.h"
#import "VCameraPublishViewController.h"
#import "VSetExpirationViewController.h"

static const CGFloat kPublishKeyboardOffset = 106.0f;

@interface VCameraPublishViewController () <UITextViewDelegate, NSLayoutManagerDelegate, VSetExpirationDelegate, VContentInputAccessoryViewDelegate>

// Canvas
@property (nonatomic, weak) IBOutlet    UIView                  *canvasView;
@property (nonatomic, weak) IBOutlet    UIImageView             *previewImageView;
@property (nonatomic, weak) IBOutlet    UIView                  *blackBackgroundView;

// Text Drawing
@property (nonatomic, weak) IBOutlet    TTTAttributedLabel      *captionPlaceholderLabel;
@property (nonatomic, weak) IBOutlet    TTTAttributedLabel      *memePlaceholderLabel;
@property (nonatomic, weak) IBOutlet    TTTAttributedLabel      *quotePlaceholderLabel;
@property (nonatomic, weak) IBOutlet    UITextView              *captionTextView;
@property (nonatomic, weak) IBOutlet    UITextView              *memeTextView;
@property (nonatomic, weak) IBOutlet    UITextView              *quoteTextView;
@property (nonatomic)                   CGFloat                 currentMemeFontSize;

// Caption Buttons
@property (nonatomic, retain)           IBOutletCollection(UIButton) NSArray *captionButtons;
@property (nonatomic, weak) IBOutlet    UIButton                *captionButton;
@property (nonatomic, weak) IBOutlet    UIButton                *memeButton;
@property (nonatomic, weak) IBOutlet    UIButton                *quoteButton;

// Sharing
@property (nonatomic, weak) IBOutlet    UILabel                 *shareToLabel;
@property (nonatomic, weak) IBOutlet    UIView                  *sharesSuperview;

// Publish
@property (nonatomic, weak) IBOutlet    UIButton                *publishButton;

// Constraints
@property (nonatomic, weak) IBOutlet    NSLayoutConstraint      *topOfCanvasToContainerConstraint;
@property (nonatomic, weak) IBOutlet    NSLayoutConstraint      *bottomVerticalSpaceShareButtonsToContainer;
@property (nonatomic, weak) IBOutlet    NSLayoutConstraint      *shareViewHeightConstraint;
@property (nonatomic, weak) IBOutlet    NSLayoutConstraint      *captionViewHeightConstraint;
@property (nonatomic, weak) IBOutlet    NSLayoutConstraint      *bottomVerticalSpacePlaceholderLabelToContainer;
@property (nonatomic, weak) IBOutlet    NSLayoutConstraint      *centerYAlignmentPlaceholderLabelToContainer;

// Input Accessories
@property (nonatomic, weak)             VContentInputAccessoryView      *captionInputAccessoryView;
@property (nonatomic, weak)             VContentInputAccessoryView      *memeInputAccessoryView;
@property (nonatomic, weak)             VContentInputAccessoryView      *quoteInputAccessoryView;

// Snapshotter
@property (nonatomic, strong)           VCompositeSnapshotController    *snapshotController;

// To preserve user's original text
@property (nonatomic, strong)           NSString                        *userEnteredText;

// Share Controllers
@property (nonatomic, strong)           VPublishShareController         *saveToCameraController;
@property (nonatomic, strong)           VPublishShareController         *shareToTwitterController;
@property (nonatomic, strong)           VPublishShareController         *shareToFacebookController;

@end

static NSString* kQuoteFont = @"PTSans-Narrow";
static NSString* kMemeFont = @"Impact";

static const CGFloat kShareMargin = 34.0f;

@implementation VCameraPublishViewController

#pragma mark - Factory Methods

+ (VCameraPublishViewController *)cameraPublishViewController
{
    return [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.snapshotController = [[VCompositeSnapshotController alloc] init];

    self.userEnteredText = @"";

    [self setDefaultCaptionText];
    
    // Configure UI
    self.captionPlaceholderLabel.userInteractionEnabled = NO;
    [self configureInputAccessoryViews];
    [self configurePublishButton];
    [self configureShareLabel];
    [self configureCaptionButtons];
    [self configureShareViews];
    [self configureCloseButton];
    [self configureNavigationBar];
    
    // iPhone 4 special cases
    if (CGRectGetHeight(self.view.bounds) <= 480)
    {
        self.bottomVerticalSpaceShareButtonsToContainer.constant = 6.0f;
        self.shareViewHeightConstraint.constant = 79.0f;
        self.captionViewHeightConstraint.constant = 40.0f;
        self.topOfCanvasToContainerConstraint.constant = self.topOfCanvasToContainerConstraint.constant - 20.0f;
    }
    
    //TODO: REMOVE THESE?
    self.captionTextView.layoutManager.delegate = self;
    self.memeTextView.layoutManager.delegate = self;
    self.quoteTextView.layoutManager.delegate = self;
    
    [self.view layoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.previewImageView.image = self.previewImage;
    
    self.memeButton.selected = self.captionType == VCaptionTypeMeme;
    self.captionButton.selected = self.captionType == VCaptionTypeNormal;
    self.quoteButton.selected = self.captionType == VCaptionTypeQuote;
    
    if (![[VSettingManager sharedManager] settingEnabledForKey:kVMemeAndQuoteEnabled] || [self.mediaURL v_hasVideoExtension])
    {
        self.captionViewHeightConstraint.constant = 0;
    }
    
    // Register
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setExpiration"])
    {
        VSetExpirationViewController*   viewController = (VSetExpirationViewController *)segue.destinationViewController;
        viewController.delegate = self;
        viewController.previewImage = self.previewImageView.image;
    }
}

#pragma mark - Property Accessors

- (void)setCaptionType:(VCaptionType)captionType
{
    _captionType = captionType;
    
    // Adjust placeholder label
    switch (captionType) {
        case VCaptionTypeNormal:
            self.bottomVerticalSpacePlaceholderLabelToContainer.priority = UILayoutPriorityDefaultHigh;
            self.centerYAlignmentPlaceholderLabelToContainer.priority = UILayoutPriorityDefaultLow;
            break;
        case VCaptionTypeMeme:
            self.bottomVerticalSpacePlaceholderLabelToContainer.priority = UILayoutPriorityDefaultHigh;
            self.centerYAlignmentPlaceholderLabelToContainer.priority = UILayoutPriorityDefaultLow;
            break;
        case VCaptionTypeQuote:
            self.bottomVerticalSpacePlaceholderLabelToContainer.priority = UILayoutPriorityDefaultLow;
            self.centerYAlignmentPlaceholderLabelToContainer.priority = UILayoutPriorityDefaultHigh;
            break;
    }
    
    [self setDefaultCaptionText];
    
    [self.view layoutIfNeeded];
}

#pragma mark - Internal Methods

- (NSDictionary *)captionAttributes
{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentLeft;
    return @{
             NSParagraphStyleAttributeName : paragraphStyle,
             NSFontAttributeName : [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font],
             NSForegroundColorAttributeName : [UIColor whiteColor],
             NSStrokeColorAttributeName : [UIColor whiteColor],
             NSStrokeWidthAttributeName : @(0)
             };
}

- (NSDictionary *)memeAttributesForDesiredSize:(CGFloat)desiredSize
{
    if (desiredSize < 30.0f)
    {
        desiredSize = 30.0f;
    }
    else if (desiredSize > 50.0f)
    {
        desiredSize = 50.0f;
    }
    
    self.currentMemeFontSize = desiredSize;
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    return @{
             NSParagraphStyleAttributeName : paragraphStyle,
             NSFontAttributeName : [UIFont fontWithName:kMemeFont size:desiredSize],
             NSForegroundColorAttributeName : [UIColor whiteColor],
             NSStrokeColorAttributeName : [UIColor blackColor],
             NSStrokeWidthAttributeName : @(-5.0)
             };
}

- (NSDictionary *)quoteAttributes
{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    
    return @{
             NSParagraphStyleAttributeName : paragraphStyle,
             NSFontAttributeName : [UIFont fontWithName:kQuoteFont size:20],
             NSForegroundColorAttributeName : [UIColor whiteColor],
             NSStrokeColorAttributeName : [UIColor whiteColor],
             NSStrokeWidthAttributeName : @(0)
             };
}

- (void)setDefaultCaptionText
{
    if (self.captionType == VCaptionTypeNormal)
    {
        [self.captionPlaceholderLabel setText:NSLocalizedString(@"AddDescription", @"") afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            NSRange hashtagRange = [[mutableAttributedString string] rangeOfString:NSLocalizedString(@"AddDescriptionAnchor", @"")];
            
            UIFont *headerFont = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
            [mutableAttributedString addAttribute:NSFontAttributeName value:headerFont range:NSMakeRange(0, [mutableAttributedString length])];
            [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor] range:hashtagRange];
            
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

- (void)configureShareLabel
{
    self.shareToLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
    self.shareToLabel.textColor = [UIColor colorWithRed:.6f green:.6f blue:.6f alpha:1.0f];
}

- (void)configurePublishButton
{
    self.publishButton.titleLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.publishButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.publishButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton1Font];
    self.publishButton.titleLabel.text = NSLocalizedString(@"Publish", nil);
}

- (void)configureInputAccessoryViews
{
    // Input Accessory Views
    VContentInputAccessoryView* captionInputAccessory = [[VContentInputAccessoryView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f)];
    captionInputAccessory.maxCharacterLength = 70;
    captionInputAccessory.textInputView = self.captionTextView;
    captionInputAccessory.tintColor = [UIColor colorWithRed:0.85f green:0.86f blue:0.87f alpha:1.0f];
    captionInputAccessory.delegate = self;
    self.captionInputAccessoryView = captionInputAccessory;
    self.captionTextView.inputAccessoryView = captionInputAccessory;
    
    VContentInputAccessoryView* memeInputAccessory = [[VContentInputAccessoryView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f)];
    memeInputAccessory.maxCharacterLength = 70;
    memeInputAccessory.textInputView = self.memeTextView;
    memeInputAccessory.tintColor = [UIColor colorWithRed:0.85f green:0.86f blue:0.87f alpha:1.0f];
    memeInputAccessory.delegate = self;
    self.memeInputAccessoryView = memeInputAccessory;
    self.memeTextView.inputAccessoryView = memeInputAccessory;
    
    VContentInputAccessoryView* quoteInputAccessory = [[VContentInputAccessoryView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f)];
    quoteInputAccessory.maxCharacterLength = 70;
    quoteInputAccessory.textInputView = self.quoteTextView;
    quoteInputAccessory.tintColor = [UIColor colorWithRed:0.85f green:0.86f blue:0.87f alpha:1.0f];
    quoteInputAccessory.delegate = self;
    self.quoteInputAccessoryView = quoteInputAccessory;
    self.quoteTextView.inputAccessoryView = quoteInputAccessory;
}

- (void)configureCaptionButtons
{
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
}

- (void)configureShareViews
{
    self.shareToFacebookController = [[VFacebookPublishShareController alloc] init];
    self.shareToTwitterController = [[VTwitterPublishShareController alloc] init];
    self.saveToCameraController = [[VCameraRollPublishShareController alloc] init];
    
    NSArray* shareControllers = @[self.shareToFacebookController, self.shareToTwitterController, self.saveToCameraController];
    for (NSInteger i = 0; i < shareControllers.count; i++)
    {
        VPublishShareController *shareController = shareControllers[i];
        
        CGFloat shareViewWidth = CGRectGetWidth(shareController.shareView.frame);
        CGFloat widthOfShareViews = (shareControllers.count * shareViewWidth) + ((shareControllers.count - 1) * kShareMargin);
        CGFloat superviewMargin = (self.sharesSuperview.frame.size.width - widthOfShareViews) / 2;
        CGFloat xCenter = superviewMargin + (shareViewWidth / 2) + (i * shareViewWidth) + (i * kShareMargin);
        
        shareController.shareView.center = CGPointMake(xCenter, CGRectGetHeight(self.sharesSuperview.frame) / 2);
        
        [self.sharesSuperview addSubview:shareController.shareView];
    }
}

- (void)configureCloseButton
{
    UIImage*    cancelButtonImage = [[UIImage imageNamed:@"cameraButtonClose"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    cancelButtonImage = [cancelButtonImage scaleToSize:CGSizeMake(17, 17)];
    UIBarButtonItem*    cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)configureNavigationBar
{
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
}

#pragma mark - Actions

- (void)cancel:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"contentIsntPublished", nil)
                                                    cancelButtonTitle:NSLocalizedString(@"Stay", @"")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:NSLocalizedString(@"Close", @"")
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

#pragma mark IBAction

- (IBAction)changeCaptionType:(UIButton *)sender
{
    for (UIButton* button in self.captionButtons)
    {
        button.selected = (button == (UIButton*)sender);
    }
    
    if (sender == self.memeButton)
    {
        self.captionType = VCaptionTypeMeme;
        self.contentInputAccessoryView.hashtagButton.enabled = NO;
    }
    else if (sender == self.quoteButton)
    {
        self.captionType = VCaptionTypeQuote;
        self.contentInputAccessoryView.hashtagButton.enabled = NO;
    }
    else if (sender == self.captionButton)
    {
        self.captionType = VCaptionTypeNormal;
        self.contentInputAccessoryView.hashtagButton.enabled = YES;
    }
}

- (IBAction)goBack:(id)sender
{
    if (self.completion)
    {
        self.completion(NO);
    }
}

- (IBAction)startEditing:(id)sender
{
    [self.textView becomeFirstResponder];
}

- (IBAction)publish:(id)sender
{
    if (self.textView.text.length < 2)
    {
        UIAlertView*    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PublishDescriptionRequired", @"")
                                                           message:NSLocalizedString(@"PublishDescriptionMinCharacters", @"")
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil] ;
        [alert show];
        return;
    }

    // Clear out any auto-correct dots
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    NSString *currentText = self.textView.text;
    self.textView.text = @"";
    self.textView.text = currentText;

    UIImage* snapshot;
    if (self.captionType == VCaptionTypeMeme)
    {
        snapshot = [self.snapshotController snapshotOfMainView:self.previewImageView subViews:@[self.textView]];
    }
    else if (self.captionType == VCaptionTypeQuote)
    {
        snapshot = [self.snapshotController snapshotOfMainView:self.previewImageView subViews:@[self.blackBackgroundView, self.textView]];
    }
    if (snapshot)
    {
        NSURL *originalMediaURL = self.mediaURL;
        NSData *filteredImageData = UIImageJPEGRepresentation(snapshot, VConstantJPEGCompressionQuality);
        NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
        if ([filteredImageData writeToURL:tempFile atomically:NO])
        {
            self.mediaURL = tempFile;
            [[NSFileManager defaultManager] removeItemAtURL:originalMediaURL error:nil];
        }
    }
    
    CGFloat playbackSpeed;
    if (self.playBackSpeed == VPlaybackNormalSpeed)
    {
        playbackSpeed = 1.0;
    }
    else if (self.playBackSpeed == VPlaybackDoubleSpeed)
    {
        playbackSpeed = 2.0;
    }
    else
    {
        playbackSpeed = 0.5;
    }
    
    BOOL facebookSelected = self.shareToFacebookController.selected;
    BOOL twitterSelected = self.shareToTwitterController.selected;
    
    [[VObjectManager sharedManager] uploadMediaWithName:self.textView.text
                                            description:self.textView.text
                                            captionType:self.captionType
                                              expiresAt:self.expirationDateString
                                           parentNodeId:@(self.parentID)
                                                  speed:playbackSpeed
                                               loopType:self.playbackLooping
                                               mediaURL:self.mediaURL
                                           successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        UIAlertView*    alert   = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PublishSucceeded", @"")
                                                             message:NSLocalizedString(@"PublishSucceededDetail", @"")
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
        [alert show];
        
        NSString  *analyticsString;
        if ([self.mediaURL v_hasVideoExtension])
        {
            analyticsString = [NSString stringWithFormat:@"Published video via"];
        }
        else
        {
            switch (self.captionType)
            {
                case VCaptionTypeNormal:
                    analyticsString = [NSString stringWithFormat:@"Published image with caption type: %@ via", @"normal"];
                    break;
                case VCaptionTypeMeme:
                    analyticsString = [NSString stringWithFormat:@"Published image with caption type: %@ via", @"meme"];
                    break;
                case VCaptionTypeQuote:
                    analyticsString = [NSString stringWithFormat:@"Published image with caption type: %@ via", @"quote"];
                    break;
            }
            
        }
        
        if (facebookSelected)
        {
            NSInteger sequenceId = ((NSString*)fullResponse[kVPayloadKey][@"sequence_id"]).integerValue;
            [[VObjectManager sharedManager] facebookShareSequenceId:sequenceId
                                                        accessToken:[[VFacebookManager sharedFacebookManager] accessToken]
                                                       successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
             {
             }
                                                          failBlock:^(NSOperation* operation, NSError* error)
             {
                 VLog(@"Failed with error: %@", error);
             }];

            [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:[NSString stringWithFormat:@"%@ facebook", analyticsString]
                                                                         action:nil
                                                                          label:nil
                                                                          value:nil];
        }
        
        if (twitterSelected)
        {
            NSInteger sequenceId = ((NSString*)fullResponse[kVPayloadKey][@"sequence_id"]).integerValue;
            [[VObjectManager sharedManager] twittterShareSequenceId:sequenceId
                                                        accessToken:[VTwitterManager sharedManager].oauthToken
                                                             secret:[VTwitterManager sharedManager].secret
                                                       successBlock:nil
                                                          failBlock:nil];
            
            [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:[NSString stringWithFormat:@"%@ twitter", analyticsString]
                                                                         action:nil
                                                                          label:nil
                                                                          value:nil];
        }
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
        else if (error.code == kVMediaAlreadyCreatedError)
        {
            UIAlertView*    alert   = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DuplicateVideoTitle", @"")
                                                                 message:NSLocalizedString(@"DuplicateVideoBody", @"")
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
            [alert show];
        }
        else
        {
            UIAlertView*    alert   = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UploadFailedTitle", @"")
                                                                 message:NSLocalizedString(@"UploadErrorBody", @"")
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
            [alert show];
        }
    }];
    
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryInteraction action:@"Post Content" label:self.textView.text value:nil];
    
    if (self.saveToCameraController.selected && !self.didSelectAssetFromLibrary)
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

#pragma mark - VSetExpirationDelegate

- (void)setExpirationViewController:(VSetExpirationViewController *)viewController didSelectDate:(NSDate *)expirationDate
{
    self.expirationDateString = [self stringForRFC2822Date:expirationDate];
    self.expiresOnLabel.text = [NSString stringWithFormat:NSLocalizedString(@"ExpiresOn", @""), [NSDateFormatter localizedStringFromDate:expirationDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle]];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.captionPlaceholderLabel.hidden = YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
// TODO: proper resizing of content based on spec
    
    if (self.captionType == VCaptionTypeMeme)
    {
        self.textView.attributedText = [[NSAttributedString alloc] initWithString:self.userEnteredText ? [self.userEnteredText uppercaseString]: @""
                                                                       attributes:self.typingAttributes];
    }
    else if ((self.captionType == VCaptionTypeQuote) || (self.captionType == VCaptionTypeNormal))
    {
        self.textView.text = self.userEnteredText;
    }
    else
    {
        self.captionPlaceholderLabel.hidden = (([textView.text length] > 0) || [self.textView isFirstResponder]);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newString = [self.userEnteredText stringByReplacingCharactersInRange:range
                                                                        withString:text];

    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    if (newString.length > self.contentInputAccessoryView.maxCharacterLength)
    {
        return NO;
    }
    
    self.userEnteredText = newString;

    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.captionPlaceholderLabel.hidden = ([textView.text length] > 0);
    
    [self setDefaultCaptionText];
}

#pragma mark - Notification Handlers

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (CGRectGetHeight(self.view.bounds) > 480.0f)
    {
        return;
    }
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    NSDictionary *userInfo = [notification userInfo];
    
    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];

    [UIView animateWithDuration:animationDuration
                          delay:0.0f
                        options:(animationCurve << 16)
                     animations:^
     {
         self.topOfCanvasToContainerConstraint.constant = -44 - kPublishKeyboardOffset - ((CGRectGetHeight(self.view.bounds) <= 480.0f) ? 0.0f : 20.0f);
         [self.view layoutIfNeeded];
     }
                     completion:nil];

}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (CGRectGetHeight(self.view.bounds) > 480.0f)
    {
        return;
    }
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    NSDictionary *userInfo = [notification userInfo];
    
    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration delay:0
                        options:(animationCurve << 16) animations:^
     {
         self.topOfCanvasToContainerConstraint.constant = -64 - ((self.view.frame.size.height <= 480.0f) ? 0.0f : 20.0f);
         [self.view layoutIfNeeded];
     }
                     completion:nil];
}

#pragma mark - VContentInputAccessoryViewDelegate

- (void)hashTagButtonTappedOnInputAccessoryView:(VContentInputAccessoryView *)inputAccessoryView
{
    if (self.captionType == VCaptionTypeNormal)
    {
        self.userEnteredText = [self.userEnteredText stringByAppendingString:@"#"];
    }
}

- (BOOL)shouldLimitTextEntryForInputAccessoryView:(VContentInputAccessoryView *)inputAccessoryView
{
    return NO;
}

- (BOOL)shouldAddHashTagsForInputAccessoryView:(VContentInputAccessoryView *)inputAccessoryView
{
    return (self.captionType == VCaptionTypeNormal) ? YES : NO;
}

#pragma mark - NSLayoutManagerDelegate

- (void)layoutManager:(NSLayoutManager *)layoutManager
        textContainer:(NSTextContainer *)textContainer
didChangeGeometryFromSize:(CGSize)oldSize
{
    if (self.captionType != VCaptionTypeMeme)
    {
        return;
    }
    
    CGFloat maxMemeWidth = CGRectGetWidth(self.canvasView.bounds) - 40.0f; // 20 pt margin on each side
    
    if (textContainer.size.width < maxMemeWidth)
    {

    }
    
}

@end
