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
#import "UIView+VFrameManipulation.h"

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
    
    self.addMediaView.translatesAutoresizingMaskIntoConstraints = YES;
    self.rightPreviewImageView.translatesAutoresizingMaskIntoConstraints = YES;

    self.questionTextField.textColor =  [[VThemeManager sharedThemeManager] themedColorForKey:kVContentAccentColor];
    self.questionTextField.placeholder = NSLocalizedString(@"Ask a Question...", @"Poll question placeholder");
//    self.questionViews.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePollQuestionBorderColor];
    
//    self.leftAnswerTextField.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePollQuestionLeftBGColor];
    self.leftAnswerTextField.textColor =  [[VThemeManager sharedThemeManager] themedColorForKey:kVContentAccentColor];
    self.leftAnswerTextField.placeholder = NSLocalizedString(@"VOTE THIS...", @"Poll left question placeholder");
    
    self.rightAnswerTextField.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentAccentColor];
    self.rightAnswerTextField.placeholder = NSLocalizedString(@"VOTE THAT...", @"Poll left question placeholder");
    
    [self setType:self.type];
    self.mediaLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    
    UIImage* newImage = [self.removeMediaButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.rightRemoveButton setImage:newImage forState:UIControlStateNormal];
    self.rightRemoveButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainColor];
    self.removeMediaButton.hidden = NO;

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
    
    if(!self.mediaData || !self.secondMediaData)
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
    if(!self.secondMediaData)
    {
        self.rightPreviewImageView.hidden = YES;
        self.rightRemoveButton.hidden = YES;
    }
    else
    {
        self.rightPreviewImageView.hidden = NO;
        self.rightRemoveButton.hidden = NO;
    }
}

#pragma mark - Actions

- (IBAction)clearMedia:(id)sender
{
    self.addMediaView.userInteractionEnabled = NO;
    self.postButton.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:.5f
                     animations:^
     {
         [self.addMediaView setXOrigin:self.addMediaView.frame.origin.x - self.addMediaView.frame.size.width];
         [self.rightPreviewImageView setXOrigin:self.rightPreviewImageView.frame.origin.x - self.addMediaView.frame.size.width];
     }
                     completion:^(BOOL finished)
     {
         self.addMediaView.userInteractionEnabled = YES;
         self.postButton.userInteractionEnabled = YES;
         
         self.mediaData = self.secondMediaData;
         self.mediaType = self.secondMediaType;
         self.previewImageView.image = self.rightPreviewImageView.image;
         
         self.secondMediaData = nil;
         self.secondMediaType = nil;
         self.rightPreviewImageView.image = nil;
         
         [self updateViewState];
         
         [self.rightPreviewImageView setXOrigin:self.rightPreviewImageView.frame.origin.x + self.addMediaView.frame.size.width];
         
         [self validatePostButtonState];
     }];
}

- (IBAction)clearRightMedia:(id)sender
{
    self.addMediaView.userInteractionEnabled = NO;
    self.postButton.userInteractionEnabled = NO;

    [UIView animateWithDuration:.5f
                     animations:^
     {
         [self.addMediaView setXOrigin:self.addMediaView.frame.origin.x - self.addMediaView.frame.size.width];
     }
                     completion:^(BOOL finished)
     {
         self.addMediaView.userInteractionEnabled = YES;
         self.postButton.userInteractionEnabled = YES;
         
         self.secondMediaData = nil;
         self.secondMediaType = nil;
         self.rightPreviewImageView.image = nil;
         [self updateViewState];
         [self validatePostButtonState];
     }];
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
        self.previewImageView.image = previewImage;
    }
    else
    {
        self.secondMediaData = data;
        self.secondMediaType = extension;
        self.rightPreviewImageView.image = previewImage;
    }
    
    self.addMediaView.userInteractionEnabled = NO;
    self.postButton.userInteractionEnabled = NO;
    
    [self updateViewState];
    
    [UIView animateWithDuration:.5f
                     animations:^
     {
         [self.addMediaView setXOrigin:self.addMediaView.frame.origin.x + self.addMediaView.frame.size.width];
     }
                     completion:^(BOOL finished)
     {
         self.addMediaView.userInteractionEnabled = YES;
         self.postButton.userInteractionEnabled = YES;
         
         [self validatePostButtonState];
     }];
}

@end