//
//  VCreateViewController.m
//  victorious
//
//  Created by David Keegan on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VCreateViewController.h"
#import "VThemeManager.h"
#import "UIView+AutoLayout.h"
#import "VConstants.h"
#import "NSString+VParseHelp.h"

CGFloat VCreateViewControllerPadding = 8;
CGFloat VCreateViewControllerLargePadding = 20;

@interface VCreateViewController() <UITextViewDelegate>

@property (weak, nonatomic) NSLayoutConstraint *contentTopConstraint;

@property (strong, nonatomic) NSData *mediaData;
@property (strong, nonatomic) NSString *mediaType;

@end

@implementation VCreateViewController

+ (instancetype)newCreateViewControllerForType:(VImagePickerViewControllerType)type
                                  withDelegate:(id<VCreateSequenceDelegate>)delegate
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VCreateViewController* createView = (VCreateViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([VCreateViewController class])];
    createView.delegate = delegate;
    createView.type = type;
    return createView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setType:self.type];
    
    [self.addMediaView constrainToSize:self.addMediaView.frame.size];
    [self.addMediaView centerInContainerOnAxis:NSLayoutAttributeCenterX];
    
    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostBackgroundColor];
    
    UIImage* newImage = [self.mediaButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.mediaButton setImage:newImage forState:UIControlStateNormal];
    self.mediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostMediaButtonColor];
    self.mediaButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostMediaButtonBGColor];
    self.mediaButton.layer.cornerRadius = self.mediaButton.frame.size.height/2;

    newImage = [self.removeMediaButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.removeMediaButton setImage:newImage forState:UIControlStateNormal];
    self.removeMediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:KVRemoveMediaButtonColor];
    self.removeMediaButton.hidden = YES;
    
    self.mediaLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostMediaLabelColor];
    [self.mediaLabel centerInContainerOnAxis:NSLayoutAttributeCenterX];
    
    self.textView.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVCreatePostFont];
    self.textView.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostTextColor];
    self.textView.layer.borderColor = [[[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostInputBorderColor] CGColor];
    self.textView.layer.borderWidth = 1;
    
    self.postButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostButtonTextColor];
    self.postButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostButtonBGColor];
    [self.postButton setTitle:NSLocalizedString(@"POST IT", @"Post button") forState:UIControlStateNormal];
    self.postButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVCreatePostButtonFont];
    
    self.characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostTextColor];
    self.characterCountLabel.text = @(VConstantsMessageLength).stringValue;
    [self.characterCountLabel pinEdges:JRTViewPinBottomEdge toSameEdgesOfView:self.textView inset:VCreateViewControllerPadding];
    
    [self validatePostButtonState];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardFrameChanged:)
     name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)setType:(VImagePickerViewControllerType)type
{
    [super setType:type];
    
    switch(self.type)
    {
        case VImagePickerViewControllerPhoto:
            self.mediaLabel.text = NSLocalizedString(@"Add a photo", @"Add photo label");
            self.title = NSLocalizedString(@"New Photo", @"New photo title");
            break;
        case VImagePickerViewControllerVideo:
            self.mediaLabel.text = NSLocalizedString(@"Add a video", @"Add video label");
            self.title = NSLocalizedString(@"New Video", @"New video title");
            break;
        case VImagePickerViewControllerPhotoAndVideo:
            self.mediaLabel.text = NSLocalizedString(@"Add a photo or video", @"Add photo or video label");
            self.title = NSLocalizedString(@"New Post", @"New post(photo or video) title");
            break;
    }
}

#pragma mark - Media

- (void)validatePostButtonState
{
    if(!self.mediaData)
    {
        [self.postButton setEnabled:NO];
        return;
    }
    if([self.textView.text length] > VConstantsMessageLength
       || [self.textView.text isEmpty])
    {
        [self.postButton setEnabled:NO];
        return;
    }
    [self.postButton setEnabled:YES];
}


- (void)setMediaData:(NSData *)mediaData
{
    _mediaData = mediaData;
    [self validatePostButtonState];
}

#pragma mark - Actions

- (IBAction)clearMedia:(id)sender
{
    self.mediaData = nil;
    self.mediaType = nil;
    self.previewImageView.image = nil;
    self.previewImageView.hidden = YES;;
    self.removeMediaButton.hidden = YES;
}

- (IBAction)closeButtonAction:(id)sender
{
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postButtonAction:(id)sender
{
    [self.textView resignFirstResponder];
    
    [self.delegate createPostWithTitle:nil
                               message:self.textView.text
                                  data:self.mediaData
                             mediaType:self.mediaType];
}

#pragma mark - Notifications

- (void)keyboardFrameChanged:(NSNotification *)notification
{
    CGRect keyboardEndFrame;
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    NSDictionary *userInfo = [notification userInfo];

    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];

    [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve << 16) animations:^
    {
        self.contentTopConstraint.constant = VCreateViewControllerLargePadding-MAX(0, CGRectGetMaxY(self.textView.frame)-CGRectGetMinY(keyboardEndFrame)+VCreateViewControllerPadding);
        [self.view layoutIfNeeded];
    }
                     completion:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger characterCount = VConstantsMessageLength-[textView.text length];
    if(characterCount < 0)
    {
        self.characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostCountInvalidColor];
    }
    else
    {
        self.characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostCountColor];
    }
    self.characterCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)characterCount];
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

#pragma mark - Overrides
- (void)imagePickerFinishedWithData:(NSData*)data
                          extension:(NSString*)extension
                       previewImage:(UIImage*)previewImage
                           mediaURL:(NSURL*)mediaURL
{
    self.mediaData = data;
    self.mediaType = extension;
    [self.previewImageView setImage: previewImage];
    
    self.previewImageView.hidden = NO;
    self.removeMediaButton.hidden = NO;
}
@end
