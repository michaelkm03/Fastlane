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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setType:self.type];
    
    
    [self.mediaView constrainToSize:self.mediaView.frame.size];
    [self.mediaView centerInContainerOnAxis:NSLayoutAttributeCenterX];
    self.contentTopConstraint = [self.mediaView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:self.topLayoutGuide inset:VCreateViewControllerLargePadding];
    
    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.background"];
    
    UIImage* newImage = [self.mediaButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.mediaButton setImage:newImage forState:UIControlStateNormal];
    self.mediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.mediaButton.icon"];
    self.mediaButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.mediaButton.background"];
    self.mediaButton.layer.cornerRadius = self.mediaButton.frame.size.height/2;
    
    newImage = [self.removeMediaButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.removeMediaButton setImage:newImage forState:UIControlStateNormal];
    self.removeMediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.media.remove"];
    [self.previewImage addSubview:self.removeMediaButton];
    [self.removeMediaButton pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinLeftEdge inset:VCreateViewControllerPadding];
    
    self.mediaLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.mediaLabel"];
    [self.mediaLabel centerInContainerOnAxis:NSLayoutAttributeCenterX];
    
    self.textView.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.post"];
    self.textView.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post"];
    self.textView.layer.borderColor = [[[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.input.border"] CGColor];
    self.textView.layer.borderWidth = 1;
    [self.textView constrainToHeight:self.textView.frame.size.height];
    
    self.postButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.postButton"];
    self.postButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.postButton.background"];
    [self.postButton setTitle:NSLocalizedString(@"POST IT", @"Post button") forState:UIControlStateNormal];
    self.postButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.post.postButton"];
    
    self.characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post"];
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
    self.previewImage.image = nil;
    [self.previewImage setHidden:YES];
}

- (IBAction)closeButtonAction:(id)sender
{
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postButtonAction:(id)sender
{
    [self.textView resignFirstResponder];
    
    [self.delegate createViewController:self shouldPostWithMessage:self.textView.text
                                   data:self.mediaData mediaType:self.mediaType];
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
        self.characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.count.invalid"];
    }
    else
    {
        self.characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.count"];
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
    [self.previewImage setImage: previewImage];
    
    self.previewImage.hidden = NO;
}
@end
