//
//  VCreatePollViewController.m
//  victorious
//
//  Created by David Keegan on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSString+VParseHelp.h"
#import "UIImage+ImageCreation.h"
#import "VContentInputAccessoryView.h"
#import "VCreatePollViewController.h"
#import "VImageSearchViewController.h"
#import "VThemeManager.h"
#import "VObjectManager+ContentCreation.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "victorious-Swift.h"  // for NSString+Unicode (imports all Swift files)
#import "VWorkspaceFlowController.h"

#import "VDependencyManager.h"
#import "VRootViewController.h"

static const NSInteger kMinLength = 2;

static char KVOContext;

@interface VCreatePollViewController() <UITextViewDelegate, VWorkspaceFlowControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *leftPreviewImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightPreviewImageView;

@property (weak, nonatomic) IBOutlet UIButton *leftRemoveButton;
@property (weak, nonatomic) IBOutlet UIButton *rightRemoveButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaButtonLeftSpacingConstraint;
@property (weak, nonatomic) IBOutlet UIButton *searchImageButton;
@property (weak, nonatomic) IBOutlet UIButton *mediaButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

@property (weak, nonatomic) IBOutlet UILabel *questionPrompt;
@property (weak, nonatomic) IBOutlet UILabel *leftAnswerPrompt;
@property (weak, nonatomic) IBOutlet UILabel *rightAnswerPrompt;

@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (strong, nonatomic) IBOutlet UITextView *leftAnswerTextView; // these properties are strong because they are being KVO'd
@property (strong, nonatomic) IBOutlet UITextView *rightAnswerTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftAnswerTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightAnswerTextViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *answersSuperview;

@property (weak, nonatomic) IBOutlet UIView *addMediaView;

@property (strong, nonatomic) NSURL *firstMediaURL;
@property (strong, nonatomic) NSURL *secondMediaURL;

@property (nonatomic, assign) BOOL didPublish;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *constraintsThatNeedHalfPointConstant;

@property (nonatomic) BOOL textViewsCleared;

@end

@implementation VCreatePollViewController

+ (instancetype)newCreatePollViewController
{
    VCreatePollViewController *createView = (VCreatePollViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier: NSStringFromClass([VCreatePollViewController class])];
    return createView;
}

- (void)dealloc
{
    [self.leftAnswerTextView  removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) context:&KVOContext];
    [self.rightAnswerTextView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) context:&KVOContext];
    
    if ( !self.didPublish )
    {
        NSDictionary *params = @{ VTrackingKeyContentType : VTrackingValuePoll };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCancelPublish parameters:params];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = NSLocalizedString(@"NEW POLL", @"");
    self.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    
    [self.constraintsThatNeedHalfPointConstant enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [obj setConstant:0.5f];
    }];

    UIImage *newImage = [self.mediaButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.mediaButton setImage:newImage forState:UIControlStateNormal];
    self.mediaButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];

    newImage = [self.searchImageButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.searchImageButton setImage:newImage forState:UIControlStateNormal];
    self.searchImageButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    newImage = [self.leftRemoveButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.rightRemoveButton setImage:newImage forState:UIControlStateNormal];
    
    newImage = [self.leftRemoveButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.leftRemoveButton setImage:newImage forState:UIControlStateNormal];
    
    self.questionTextView.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.questionTextView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.questionTextView.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    self.questionTextView.inputAccessoryView = [self inputAccessoryViewForTextView:self.questionTextView];

    self.questionPrompt.text      = NSLocalizedString(@"Ask a question...", @"");
    self.questionPrompt.font      = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    
    self.leftAnswerTextView.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.leftAnswerTextView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.leftAnswerTextView.font      = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    [self.leftAnswerTextView addObserver:self
                              forKeyPath:NSStringFromSelector(@selector(contentSize))
                                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                 context:&KVOContext];
    self.leftAnswerTextView.text = self.leftAnswerPrompt.text; // temporarily
    self.leftAnswerTextView.inputAccessoryView = [self inputAccessoryViewForTextView:self.leftAnswerTextView];
    ((VContentInputAccessoryView *)self.leftAnswerTextView.inputAccessoryView).maxCharacterLength = VConstantsPollAnswerLength;
    
    self.rightAnswerTextView.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.rightAnswerTextView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.rightAnswerTextView.font      = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    [self.rightAnswerTextView addObserver:self
                               forKeyPath:NSStringFromSelector(@selector(contentSize))
                                  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                  context:&KVOContext];
    self.rightAnswerTextView.text = self.rightAnswerPrompt.text; // temporarily
    self.rightAnswerTextView.inputAccessoryView = [self inputAccessoryViewForTextView:self.rightAnswerTextView];
    ((VContentInputAccessoryView *)self.rightAnswerTextView.inputAccessoryView).maxCharacterLength = VConstantsPollAnswerLength;
    
    [self.answersSuperview addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAnswerTextView
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.answersSuperview
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0f
                                                                       constant:30.0f]];
    [self.answersSuperview addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAnswerTextView
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.answersSuperview
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0f
                                                                       constant:30.0f]];
    
    self.leftAnswerPrompt.text      = NSLocalizedString(@"Vote this", @"");
    self.leftAnswerPrompt.font      = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];

    self.rightAnswerPrompt.text      = NSLocalizedString(@"Vote that", @"");
    self.rightAnswerPrompt.font      = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    
    self.postButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    [self.postButton setBackgroundImage:[UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]] forState:UIControlStateNormal];
    [self.postButton setBackgroundImage:[UIImage resizeableImageWithColor:[UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f]] forState:UIControlStateDisabled];
    [self.postButton setTitle:NSLocalizedString(@"Create Poll", @"Create Poll") forState:UIControlStateNormal];
    self.postButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton1Font];
    
    [self.postButton setEnabled:YES];

    [self updateViewState];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!self.textViewsCleared)
    {
        self.leftAnswerTextView.text = @"";
        self.rightAnswerTextView.text = @"";
        self.textViewsCleared = YES;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)postButtonStateIsValid ///<Surfaces alert if content cannot be posted.  Returns YES if it can be posted and NO if it cannot.
{
    //These should have already been trimmed by the textViewDidEndEditing: call.  But lets verify that they are trimmed.
    NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    self.questionTextView.text = [self.questionTextView.text stringByTrimmingCharactersInSet:whitespaceSet];
    self.leftAnswerTextView.text = [self.leftAnswerTextView.text stringByTrimmingCharactersInSet:whitespaceSet];
    self.rightAnswerTextView.text = [self.rightAnswerTextView.text stringByTrimmingCharactersInSet:whitespaceSet];
    
    NSString *errorMessage = @"";
    if (!self.firstMediaURL || !self.secondMediaURL)
    {
        errorMessage = [errorMessage stringByAppendingString:NSLocalizedString(@"MissingMedia", nil)];
        errorMessage = [errorMessage stringByAppendingString:@"\n"];
    }
    if ([self.questionTextView.text lengthWithUnicode] < kMinLength)
    {
        errorMessage = [errorMessage stringByAppendingString:NSLocalizedString(@"QuestionTextToShort", nil)];
        errorMessage = [errorMessage stringByAppendingString:@"\n"];
    }
    if ([self.leftAnswerTextView.text lengthWithUnicode] < kMinLength || [self.rightAnswerTextView.text lengthWithUnicode] < kMinLength)
    {
        errorMessage = [errorMessage stringByAppendingString:NSLocalizedString(@"AnswerTextToShort", nil)];
    }
    
    if (errorMessage.length > 0)
    {
        NSDictionary *params = @{ VTrackingKeyErrorMessage : errorMessage ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventPollDidFailValidation parameters:params];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Content", nil)
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }

    return YES;
}

- (void)updateViewState
{
    if (self.firstMediaURL)
    {
        self.leftPreviewImageView.alpha = 1.0f;
        self.leftRemoveButton.alpha = 1.0f;
    }
    else
    {
        self.leftPreviewImageView.alpha = 0.0f;
        self.leftRemoveButton.alpha = 0.0f;
    }
    
    if (self.secondMediaURL)
    {
        self.rightPreviewImageView.alpha = 1.0f;
        self.rightRemoveButton.alpha = 1.0f;
    }
    else
    {
        self.rightPreviewImageView.alpha = 0.0f;
        self.rightRemoveButton.alpha = 0.0f;
    }

    if (self.firstMediaURL)
    {
        self.mediaButtonLeftSpacingConstraint.constant = CGRectGetWidth(self.view.bounds) / 2;
    }
    else
    {
        self.mediaButtonLeftSpacingConstraint.constant = 0.0f;
    }

    if (self.firstMediaURL && self.secondMediaURL)
    {
        self.addMediaView.alpha = 0.0f;
    }
    else
    {
        self.addMediaView.alpha = 1.0f;
    }
    
    [self.view layoutIfNeeded];
}

#pragma mark - Actions

- (IBAction)mediaButtonAction:(id)sender
{
    VWorkspaceFlowController *workspaceFlowController = [VWorkspaceFlowController workspaceFlowControllerWithoutADependencyMangerWithInjection:@{VImageToolControllerInitialImageEditStateKey:@(VImageToolControllerInitialImageEditStateFilter), VVideoToolControllerInitalVideoEditStateKey:@(VVideoToolControllerInitialVideoEditStateVideo)}];
    workspaceFlowController.delegate = self;
    workspaceFlowController.videoEnabled = YES;
    [self presentViewController:workspaceFlowController.flowRootViewController
                       animated:YES
                     completion:nil];
}

- (IBAction)clearLeftMedia:(id)sender
{
    UIView *temporaryLeftPreviewView = [self.leftPreviewImageView snapshotViewAfterScreenUpdates:NO];
    temporaryLeftPreviewView.frame = self.leftPreviewImageView.frame;
    [self.answersSuperview addSubview:temporaryLeftPreviewView];
    
    self.leftPreviewImageView.hidden = YES;

    if (self.firstMediaURL)
    {
        [[NSFileManager defaultManager] removeItemAtURL:self.firstMediaURL error:nil];
    }
    
    self.firstMediaURL = nil;
    self.leftPreviewImageView.image = nil;

    if (self.secondMediaURL)
    {
        self.mediaButtonLeftSpacingConstraint.constant = 0;
        [self.answersSuperview layoutIfNeeded];
    }
    [UIView animateWithDuration:0.2f
                     animations:^(void)
    {
        temporaryLeftPreviewView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        temporaryLeftPreviewView.alpha = 0;
        [self updateViewState];
    }
                     completion:^(BOOL finished)
    {
        [temporaryLeftPreviewView removeFromSuperview];
        self.leftPreviewImageView.hidden = NO;
    }];
}

- (IBAction)clearRightMedia:(id)sender
{
    UIView *temporaryRightPreviewView = [self.rightPreviewImageView snapshotViewAfterScreenUpdates:NO];
    temporaryRightPreviewView.frame = self.rightPreviewImageView.frame;
    [self.answersSuperview addSubview:temporaryRightPreviewView];
    
    self.rightPreviewImageView.hidden = YES;

    if (self.secondMediaURL)
    {
        [[NSFileManager defaultManager] removeItemAtURL:self.secondMediaURL error:nil];
    }
    self.secondMediaURL = nil;
    self.rightPreviewImageView.image = nil;

    [UIView animateWithDuration:0.2f
                     animations:^(void)
    {
        temporaryRightPreviewView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        temporaryRightPreviewView.alpha = 0;
        [self updateViewState];
    }
                     completion:^(BOOL finished)
    {
        [temporaryRightPreviewView removeFromSuperview];
        self.rightPreviewImageView.hidden = NO;
    }];
}

- (IBAction)postButtonAction:(id)sender
{
    if (![self postButtonStateIsValid])
    {
        return;
    }
    
    [[VObjectManager sharedManager] createPollWithName:self.questionTextView.text
                                           description:@"<none>"
                                          previewImage:self.leftPreviewImageView.image
                                              question:self.questionTextView.text
                                           answer1Text:self.leftAnswerTextView.text
                                           answer2Text:self.rightAnswerTextView.text
                                             media1Url:self.firstMediaURL
                                             media2Url:self.secondMediaURL
                                            completion:nil];
    
    NSDictionary *params = @{ VTrackingKeyContentType : VTrackingValuePoll };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidPublishContent parameters:params];
    
    self.didPublish = YES;
    
    [self.navigationController popViewControllerAnimated:YES];
    [[NSFileManager defaultManager] removeItemAtURL:self.firstMediaURL error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:self.secondMediaURL error:nil];
}

- (IBAction)searchImageAction:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventPollDidSelectImageSearch];
    
    VImageSearchViewController *imageSearch = [VImageSearchViewController newImageSearchViewController];
    
    if (self.firstMediaURL)
    {
        imageSearch.searchTerm = self.rightAnswerTextView.text;
    }
    else
    {
        imageSearch.searchTerm = self.leftAnswerTextView.text;
    }
    
    VImageSearchViewController __weak *weakImageSearch = imageSearch;
    imageSearch.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (finished)
        {
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventPollDidSelectImageFromImageSearch];
            
            if (self.firstMediaURL)
            {
                if (!self.rightAnswerTextView.text || [self.rightAnswerTextView.text isEqualToString:@""])
                {
                    self.rightAnswerTextView.text = weakImageSearch.searchTerm;
                    [self textViewDidChange:self.rightAnswerTextView];
                }
            }
            else
            {
                if (!self.leftAnswerTextView.text || [self.leftAnswerTextView.text isEqualToString:@""])
                {
                    self.leftAnswerTextView.text = weakImageSearch.searchTerm;
                    [self textViewDidChange:self.leftAnswerTextView];
                }
            }
            [self imagePickerFinishedWithURL:capturedMediaURL previewImage:previewImage];
        }
        else
        {
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventPollDidExitImageSearch];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:imageSearch animated:YES completion:nil];
}

- (VContentInputAccessoryView *)inputAccessoryViewForTextView:(UITextView *)textView
{
    VContentInputAccessoryView *contentInputAccessory = [[VContentInputAccessoryView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    contentInputAccessory.textInputView = textView;
    contentInputAccessory.tintColor = [UIColor colorWithRed:0.85f green:0.86f blue:0.87f alpha:1.0f];
    return contentInputAccessory;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView == self.questionTextView)
    {
        self.questionPrompt.hidden = textView.text.length > 0;
    }
    else if (textView == self.leftAnswerTextView)
    {
        self.leftAnswerPrompt.hidden = textView.text.length > 0;
    }
    else if (textView == self.rightAnswerTextView)
    {
        self.rightAnswerPrompt.hidden = textView.text.length > 0;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark -

- (void)imagePickerFinishedWithURL:(NSURL *)mediaURL
                      previewImage:(UIImage *)previewImage
{
    if (!self.firstMediaURL)
    {
        self.firstMediaURL = mediaURL;
        self.leftPreviewImageView.image = previewImage;
    }
    else
    {
        self.secondMediaURL = mediaURL;
        self.rightPreviewImageView.image = previewImage;
    }
    
    [self updateViewState];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &KVOContext)
    {
        return;
    }
    
    if (object == self.leftAnswerTextView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))])
    {
        NSValue *newContentSize = change[NSKeyValueChangeNewKey];
        if (newContentSize && (id)newContentSize != [NSNull null])
        {
            NSValue *oldContentSize = change[NSKeyValueChangeOldKey];
            if (oldContentSize && (id)oldContentSize != [NSNull null] &&
                [oldContentSize CGSizeValue].height == [newContentSize CGSizeValue].height)
            {
                return;
            }
            
            void (^animations)(void) = ^(void)
            {
                self.leftAnswerTextViewHeightConstraint.constant = [newContentSize CGSizeValue].height;
                [self.answersSuperview layoutIfNeeded];
            };
            if (self.textViewsCleared)
            {
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:animations
                                 completion:nil];
            }
            else
            {
                animations();
            }
        }
    }
    else if (object == self.rightAnswerTextView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))])
    {
        NSValue *newContentSize = change[NSKeyValueChangeNewKey];
        if (newContentSize && (id)newContentSize != [NSNull null])
        {
            NSValue *oldContentSize = change[NSKeyValueChangeOldKey];
            if (oldContentSize && (id)oldContentSize != [NSNull null] &&
                [oldContentSize CGSizeValue].height == [newContentSize CGSizeValue].height)
            {
                return;
            }
            
            void (^animations)(void) = ^(void)
            {
                self.rightAnswerTextViewHeightConstraint.constant = [newContentSize CGSizeValue].height;
                [self.answersSuperview layoutIfNeeded];
            };
            if (self.textViewsCleared)
            {
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:animations
                                 completion:nil];
            }
            else
            {
                animations();
            }
        }
    }
}

#pragma mark - VWorkspaceFlowControllerDelegate

- (void)workspaceFlowControllerDidCancel:(VWorkspaceFlowController *)workspaceFlowController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)workspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
       finishedWithPreviewImage:(UIImage *)previewImage
               capturedMediaURL:(NSURL *)capturedMediaURL
{
    [self imagePickerFinishedWithURL:capturedMediaURL
                        previewImage:previewImage];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldShowPublishForWorkspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
{
    return NO;
}

@end
