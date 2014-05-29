//
//  VCreatePollViewController.m
//  victorious
//
//  Created by David Keegan on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "NSString+VParseHelp.h"
#import "UIImage+ImageCreation.h"
#import "VCameraViewController.h"
#import "VConstants.h"
#import "VCreatePollViewController.h"
#import "VImageSearchViewController.h"
#import "VThemeManager.h"

static const CGFloat kPreviewImageWidth = 160.0f;

@interface VCreatePollViewController() <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *leftPreviewImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightPreviewImageView;

@property (weak, nonatomic) IBOutlet UIButton *leftRemoveButton;
@property (weak, nonatomic) IBOutlet UIButton *rightRemoveButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaButtonLeftSpacingConstraint;
@property (weak, nonatomic) IBOutlet UIButton *searchImageButton;
@property (weak, nonatomic) IBOutlet UIButton *mediaButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

@property (weak, nonatomic) IBOutlet UITextField *questionTextField;
@property (weak, nonatomic) IBOutlet UITextField *leftAnswerTextField;
@property (weak, nonatomic) IBOutlet UITextField *rightAnswerTextField;

@property (weak, nonatomic) IBOutlet UIView* answersSuperview;
@property (weak, nonatomic) IBOutlet UILabel *characterCountLabel;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIView *addMediaView;

@property (strong, nonatomic) NSURL *firstMediaURL;
@property (strong, nonatomic) NSURL *secondMediaURL;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *constraintsThatNeedHalfPointConstant;

@property (nonatomic, strong)   UIBarButtonItem*    countDownLabel;

@end

@implementation VCreatePollViewController

+ (instancetype)newCreatePollViewControllerWithDelegate:(id<VCreateSequenceDelegate>)delegate
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VCreatePollViewController* createView = (VCreatePollViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([VCreatePollViewController class])];
    createView.delegate = delegate;
    return createView;
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

    UIImage* newImage = [self.mediaButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.mediaButton setImage:newImage forState:UIControlStateNormal];
    self.mediaButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];

    newImage = [self.searchImageButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.searchImageButton setImage:newImage forState:UIControlStateNormal];
    self.searchImageButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    newImage = [self.leftRemoveButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.rightRemoveButton setImage:newImage forState:UIControlStateNormal];
    
    newImage = [self.leftRemoveButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.leftRemoveButton setImage:newImage forState:UIControlStateNormal];
    
    self.questionTextField.textColor =  [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.questionTextField.placeholder = NSLocalizedString(@"Ask a Question...", @"Poll question placeholder");
    [self.questionTextField addTarget:self action:@selector(questionTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.questionTextField.delegate = self;

    self.leftAnswerTextField.textColor =  [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.leftAnswerTextField.placeholder = NSLocalizedString(@"VOTE THIS...", @"Poll left question placeholder");
    
    self.rightAnswerTextField.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.rightAnswerTextField.placeholder = NSLocalizedString(@"VOTE THAT...", @"Poll left question placeholder");
    
    self.postButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    [self.postButton setBackgroundImage:[UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]] forState:UIControlStateNormal];
    [self.postButton setBackgroundImage:[UIImage resizeableImageWithColor:[UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f]] forState:UIControlStateDisabled];
    [self.postButton setTitle:NSLocalizedString(@"Create Poll", @"Create Poll") forState:UIControlStateNormal];
    self.postButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton1Font];
    
    [self validatePostButtonState];
    [self updateViewState];
    [self createInputAccessoryView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![self.navigationController isNavigationBarHidden])
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)validatePostButtonState
{
    [self.postButton setEnabled:YES];
    
    if(!self.firstMediaURL || !self.secondMediaURL)
        [self.postButton setEnabled:NO];
    
    else if([self.questionTextField.text isEmpty])
        [self.postButton setEnabled:NO];

    else if([self.questionTextField.text length] > VConstantsForumTitleLength)
        [self.postButton setEnabled:NO];
    
    else if([self.leftAnswerTextField.text isEmpty])
        [self.postButton setEnabled:NO];

    else if([self.leftAnswerTextField.text length] > VConstantsForumTitleLength)
        [self.postButton setEnabled:NO];
    
    else if([self.rightAnswerTextField.text isEmpty])
        [self.postButton setEnabled:NO];

    else if([self.rightAnswerTextField.text length] > VConstantsForumTitleLength)
        [self.postButton setEnabled:NO];
}

- (void)updateViewState
{
    if (self.firstMediaURL)
    {
        self.mediaButtonLeftSpacingConstraint.constant = kPreviewImageWidth;
        self.leftPreviewImageView.alpha = 1.0f;
        self.leftRemoveButton.alpha = 1.0f;
    }
    else
    {
        self.mediaButtonLeftSpacingConstraint.constant = 0.0f;
        self.leftPreviewImageView.alpha = 0.0f;
        self.leftRemoveButton.alpha = 0.0f;
    }
    
    if (self.secondMediaURL)
    {
        self.rightPreviewImageView.alpha = 1.0f;
        self.rightRemoveButton.alpha = 1.0f;
        self.addMediaView.alpha = 0.0f;
    }
    else
    {
        self.rightPreviewImageView.alpha = 0.0f;
        self.rightRemoveButton.alpha = 0.0f;
        self.addMediaView.alpha = 1.0f;
    }
    
    [self.view layoutIfNeeded];
}

#pragma mark - Actions

- (IBAction)mediaButtonAction:(id)sender
{
    VCameraViewController *cameraViewController = [VCameraViewController cameraViewController];
    cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (finished)
        {
            [self imagePickerFinishedWithURL:capturedMediaURL
                                previewImage:previewImage];
        }

        [self dismissViewControllerAnimated:YES completion:nil];
    };

    UINavigationController *navigationController = [[UINavigationController alloc] init];
    [navigationController pushViewController:cameraViewController animated:NO];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)clearLeftMedia:(id)sender
{
    UIView *temporaryRightPreviewView = [self.rightPreviewImageView snapshotViewAfterScreenUpdates:NO];
    UIView *temporaryLeftPreviewView = [self.leftPreviewImageView snapshotViewAfterScreenUpdates:NO];
    temporaryRightPreviewView.frame = self.rightPreviewImageView.frame;
    temporaryLeftPreviewView.frame = self.leftPreviewImageView.frame;
    [self.answersSuperview addSubview:temporaryRightPreviewView];
    [self.answersSuperview addSubview:temporaryLeftPreviewView];
    
    self.rightPreviewImageView.hidden = YES;
    self.leftPreviewImageView.hidden = YES;

    if (!self.secondMediaURL)
    {
        [[NSFileManager defaultManager] removeItemAtURL:self.firstMediaURL error:nil];
    }
    
    self.firstMediaURL = self.secondMediaURL;
    self.leftPreviewImageView.image = self.rightPreviewImageView.image;
    
    if (self.secondMediaURL)
    {
        [[NSFileManager defaultManager] removeItemAtURL:self.secondMediaURL error:nil];
    }
    self.secondMediaURL = nil;
    self.rightPreviewImageView.image = nil;
    
    [UIView animateWithDuration:0.2f
                     animations:^(void)
    {
        temporaryRightPreviewView.frame = temporaryLeftPreviewView.frame;
        temporaryLeftPreviewView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        temporaryLeftPreviewView.alpha = 0;
        [self validatePostButtonState];
        [self updateViewState];
    }
                     completion:^(BOOL finished)
    {
        [temporaryLeftPreviewView removeFromSuperview];
        [temporaryRightPreviewView removeFromSuperview];
        self.rightPreviewImageView.hidden = NO;
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
        [self validatePostButtonState];
    }
                     completion:^(BOOL finished)
    {
        [temporaryRightPreviewView removeFromSuperview];
        self.rightPreviewImageView.hidden = NO;
    }];
}

- (IBAction)postButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(createPollWithQuestion:answer1Text:answer2Text:media1URL:media2URL:)])
    {
        [self.delegate createPollWithQuestion:self.questionTextField.text
                                  answer1Text:self.leftAnswerTextField.text
                                  answer2Text:self.rightAnswerTextField.text
                                    media1URL:self.firstMediaURL
                                    media2URL:self.secondMediaURL];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)closeButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)searchImageAction:(id)sender
{
    VImageSearchViewController *imageSearch = [VImageSearchViewController newImageSearchViewController];
    imageSearch.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (finished)
        {
            [self imagePickerFinishedWithURL:capturedMediaURL previewImage:previewImage];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:imageSearch animated:YES completion:nil];
}

- (IBAction)hashButtonClicked:(id)sender
{
    self.questionTextField.text = [self.questionTextField.text stringByAppendingString:@"#"];
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
    
    self.countDownLabel = [[UIBarButtonItem alloc] initWithTitle:[NSNumberFormatter localizedStringFromNumber:@(VConstantsMessageLength) numberStyle:NSNumberFormatterDecimalStyle]
                                                           style:UIBarButtonItemStyleBordered
                                                          target:nil
                                                          action:nil];
    
    toolbar.items = @[hashButton, flexibleSpace, self.countDownLabel];
    self.questionTextField.inputAccessoryView = toolbar;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self validatePostButtonState];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.questionTextField)
        [self.leftAnswerTextField becomeFirstResponder];

    if (textField == self.leftAnswerTextField)
        [self.rightAnswerTextField becomeFirstResponder];

    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.questionTextField])
    {
        BOOL    isDeleteKey = ([string isEqualToString:@""]);
        if ((textField.text.length >= VConstantsMessageLength) && (!isDeleteKey))
            return NO;
    }
    
    return YES;
}

- (void)questionTextFieldDidChange:(id)sender
{
    self.countDownLabel.title = [NSNumberFormatter localizedStringFromNumber:@(VConstantsMessageLength - self.questionTextField.text.length)
                                                                 numberStyle:NSNumberFormatterDecimalStyle];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger characterCount = VConstantsMessageLength-[textView.text length];
    if(characterCount < 0)
    {
        self.characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    }
    else
    {
        self.characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    }

    self.characterCountLabel.text = [NSNumberFormatter localizedStringFromNumber:@(characterCount)
                                                                     numberStyle:NSNumberFormatterDecimalStyle];
    [self validatePostButtonState];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
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
    [self validatePostButtonState];
}

@end
