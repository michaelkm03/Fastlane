//
//  VCreatePollViewController.m
//  victorious
//
//  Created by David Keegan on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VCreatePollViewController.h"
#import "VThemeManager.h"
#import "UIView+AutoLayout.h"
#import "VConstants.h"
#import "NSString+VParseHelp.h"

@interface VCreatePollViewController() <UITextFieldDelegate>

@property (strong, nonatomic) NSData *mediaData;
@property (strong, nonatomic) NSData *secondMediaData;

@property (strong, nonatomic) NSString *mediaType;
@property (strong, nonatomic) NSString *secondMediaType;

@end

@implementation VCreatePollViewController

+ (instancetype)newCreatePollViewControllerForType:(VImagePickerViewControllerType)type
                                      withDelegate:(id<VCreateSequenceDelegate>)delegate
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VCreatePollViewController* createView = (VCreatePollViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([VCreatePollViewController class])];
    createView.delegate = delegate;
    createView.type = type;
    return createView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.questionTextField.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePollQuestionColor];
    self.questionTextField.placeholder = NSLocalizedString(@"Ask a Question...", @"Poll question placeholder");
//    self.questionViews.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePollQuestionBorderColor];
    
//    self.leftAnswerTextField.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePollQuestionLeftBGColor];
//    self.leftAnswerTextField.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePollQuestionLeftColor];
    self.leftAnswerTextField.placeholder = NSLocalizedString(@"VOTE THIS...", @"Poll left question placeholder");
    
//    self.rightAnswerTextField.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePollQuestionRightBGColor];
//    self.rightAnswerTextField.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePollQuestionRightColor];
    self.rightAnswerTextField.placeholder = NSLocalizedString(@"VOTE THAT...", @"Poll left question placeholder");
    
    [self setType:self.type];
    self.mediaLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVAccentColor];
    
    UIImage* newImage = [self.removeMediaButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.rightRemoveButton setImage:newImage forState:UIControlStateNormal];
    self.rightRemoveButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVMainColor];
    
    [self validatePostButtonState];
    [self updateViewState];
}

- (void)setType:(VImagePickerViewControllerType)type
{
    [super setType:type];
    
    self.title = NSLocalizedString(@"New Poll", @"New poll title");
}

- (void)validatePostButtonState
{
    [self.postButton setEnabled:YES];
    
    if(!self.mediaData)
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
    if(!self.mediaData && !self.secondMediaData)
    {
        [self.addMediaView setHidden:NO];
        
        [self.previewImageView setHidden:YES];
        [self.removeMediaButton setHidden:YES];
        [self.rightRemoveButton setHidden:YES];
        [self.leftPreviewImageView setHidden:YES];
        [self.rightPreviewImageView setHidden:YES];
        [self.addMoreMediaButton setHidden:YES];
    }
    else if(self.mediaData && self.secondMediaData)
    {
        [self.addMediaView setHidden:YES];
        [self.addMoreMediaButton setHidden:YES];
        [self.previewImageView setHidden:YES];
        
        [self.removeMediaButton setHidden:NO];
        [self.rightRemoveButton setHidden:NO];
        [self.leftPreviewImageView setHidden:NO];
        [self.rightPreviewImageView setHidden:NO];
    }
    else if (self.mediaData && !self.secondMediaData)
    {
        [self.addMediaView setHidden:YES];
        [self.rightRemoveButton setHidden:YES];
        [self.leftPreviewImageView setHidden:YES];
        [self.rightPreviewImageView setHidden:YES];
        
        [self.previewImageView setHidden:NO];
        [self.removeMediaButton setHidden:NO];
        [self.addMoreMediaButton setHidden:NO];
    }
}

#pragma mark - Actions

- (IBAction)clearMedia:(id)sender
{
    self.mediaData = nil;
    self.mediaType = nil;
    self.leftPreviewImageView.image = nil;
    self.previewImageView.image = nil;
    
    if(self.secondMediaData)
    {
        NSData *data = self.secondMediaData;
        NSString *type = self.secondMediaType;
        UIImage *image = self.rightPreviewImageView.image;
        [self clearRightMedia:nil];
        [self imagePickerFinishedWithData:data extension:type previewImage:image mediaURL:nil];
    }
    else
    {
        [self updateViewState];
        [self validatePostButtonState];
    }
}

- (IBAction)clearRightMedia:(id)sender
{
    self.secondMediaData = nil;
    self.secondMediaType = nil;
    self.rightPreviewImageView.image = nil;
    [self updateViewState];
    [self validatePostButtonState];
}

- (IBAction)postButtonAction:(id)sender
{
    [self.delegate createPollWithQuestion:self.questionTextField.text
                              answer1Text:self.leftAnswerTextField.text
                              answer2Text:self.rightAnswerTextField.text
                               media1Data:self.mediaData
                          media1Extension:self.mediaType
                               media2Data:self.secondMediaData
                          media2Extension:self.secondMediaType];
    
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

#pragma mark - Overrides
- (void)imagePickerFinishedWithData:(NSData*)data
                          extension:(NSString*)extension
                       previewImage:(UIImage*)previewImage
                           mediaURL:(NSURL*)mediaURL
{
    if(!self.mediaData)
    {
        self.mediaData = data;
        self.mediaType = extension;
        self.leftPreviewImageView.image = previewImage;
        self.previewImageView.image = previewImage;
    }
    else
    {
        self.secondMediaData = data;
        self.secondMediaType = extension;
        self.rightPreviewImageView.image = previewImage;
    }
    
    [self updateViewState];
    [self validatePostButtonState];
}
@end
