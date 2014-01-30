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

CGFloat VCreateViewControllerPadding = 8;
CGFloat VCreateViewControllerLargePadding = 20;

@interface VCreateViewController() <UITextViewDelegate>

@property (weak, nonatomic) NSLayoutConstraint *contentTopConstraint;

@property (weak, nonatomic) UITextView *textView;

@property (weak, nonatomic) UILabel *characterCountLabel;

@property (weak, nonatomic) id<VCreateSequenceDelegate> delegate;

@property (strong, nonatomic) NSData *mediaData;
@property (strong, nonatomic) NSString *mediaType;

@end

@implementation VCreateViewController

- (instancetype)initWithType:(VImagePickerViewControllerType)type andDelegate:(id<VCreateSequenceDelegate>)delegate
{
    if(!(self = [super initWithType:type]))
    {
        return nil;
    }

    self.delegate = delegate;

    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.background"];
    
//    self.navigationItem.leftBarButtonItem =
//    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"]
//                                     style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonAction:)];

//    CGSize mediaViewSize = CGSizeMake(200, 200);
//    UIView *mediaView = [UIView autoLayoutView];
//    [self.view addSubview:mediaView];
//    [mediaView constrainToSize:mediaViewSize];
//    [mediaView centerInContainerOnAxis:NSLayoutAttributeCenterX];
//    self.contentTopConstraint = [mediaView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:self.topLayoutGuide inset:VCreateViewControllerLargePadding];

    self.mediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.mediaButton.icon"];
    self.mediaButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.mediaButton.background"];
    self.mediaButton.layer.cornerRadius = self.mediaButton.frame.size.height/2;
    self.mediaButton.translatesAutoresizingMaskIntoConstraints = NO;

//    [self.mediaButton centerInContainerOnAxis:NSLayoutAttributeCenterY];
//    [self.mediaButton centerInContainerOnAxis:NSLayoutAttributeCenterX];
//    [self.mediaButton constrainToSize:mediaButtonSize];
//
//    UIImageView *previewImage = [UIImageView autoLayoutView];
//    previewImage.userInteractionEnabled = YES;
//    [mediaView addSubview:previewImage];
//    [previewImage pinToSuperviewEdgesWithInset:UIEdgeInsetsZero];
//    [self.previewImage setHidden:YES];
//    self.previewImage = previewImage;

    
    self.removeMediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.media.remove"];
    self.removeMediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.previewImage addSubview:self.removeMediaButton];
    [self.removeMediaButton pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinLeftEdge inset:VCreateViewControllerPadding];
    
    self.mediaLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.mediaLabel"];
    [self.mediaLabel pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:self.mediaButton inset:VCreateViewControllerLargePadding];
    [self.mediaLabel centerInContainerOnAxis:NSLayoutAttributeCenterX];
    
    switch(type)
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
    
    UITextView *textView = [UITextView autoLayoutView];
    textView.delegate = self;
    textView.returnKeyType = UIReturnKeyDone;
    textView.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.post"];
    textView.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post"];
    textView.layer.borderColor = [[[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.input.border"] CGColor];
    textView.layer.borderWidth = 1;
    [self.view addSubview:textView];
    [textView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:self.mediaLabel inset:VCreateViewControllerLargePadding];
    [textView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:VCreateViewControllerPadding];
    [textView constrainToHeight:120];
    self.textView = textView;

    CGFloat postButtonHeight = 44;
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [postButton addTarget:self action:@selector(postButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    postButton.translatesAutoresizingMaskIntoConstraints = NO;
    postButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.postButton"];
    postButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.postButton.background"];
    [postButton setTitle:NSLocalizedString(@"POST IT", @"Post button") forState:UIControlStateNormal];
    postButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.post.postButton"];
    [self.view addSubview:postButton];
    [postButton pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinBottomEdge|JRTViewPinRightEdge inset:VCreateViewControllerPadding];
    [postButton constrainToHeight:postButtonHeight];
    self.postButton = postButton;

    UILabel *characterCountLabel = [UILabel autoLayoutView];
    characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post"];
    characterCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)VConstantsMessageLength];
    [self.view addSubview:characterCountLabel];
    [characterCountLabel pinEdges:JRTViewPinRightEdge toSameEdgesOfView:textView inset:VCreateViewControllerPadding];
    [characterCountLabel pinEdges:JRTViewPinBottomEdge toSameEdgesOfView:textView inset:VCreateViewControllerPadding];
    self.characterCountLabel = characterCountLabel;

    [self validatePostButtonState];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardFrameChanged:)
     name:UIKeyboardWillChangeFrameNotification object:nil];

    return self;
}

#pragma mark - Media

- (void)validatePostButtonState
{
    if(!self.mediaData)
    {
        [self.postButton setEnabled:NO];
        return;
    }
    if([self.textView.text length] > VConstantsMessageLength)
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

@end
