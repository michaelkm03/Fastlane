//
//  VCreateViewController.m
//  victorious
//
//  Created by David Keegan on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCreateViewController.h"
#import "VThemeManager.h"
#import "UIView+AutoLayout.h"
#import "VConstants.h"

CGFloat VCreateViewControllerPadding = 8;
CGFloat VCreateViewControllerLargePadding = 20;

@interface VCreateViewController()
<UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) NSLayoutConstraint *contentTopConstraint;
@property (weak, nonatomic) UIButton *mediaButton;
@property (weak, nonatomic) UILabel *mediaLabel;
@property (weak, nonatomic) UITextView *textView;
@property (weak, nonatomic) UIButton *postButton;
@property (weak, nonatomic) UILabel *characterCountLabel;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) VCreateViewControllerType type;
@end

@implementation VCreateViewController

- (instancetype)initWithType:(VCreateViewControllerType)type
{
    if(!(self = [super init]))
    {
        return nil;
    }

    self.type = type;

    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.background"];
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"]
                                     style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonAction:)];

    switch(self.type)
    {
        case VCreateViewControllerTypePhoto:
            self.title = NSLocalizedString(@"New Photo", @"New photo title");
            break;
        case VCreateViewControllerTypeVideo:
            self.title = NSLocalizedString(@"New Video", @"New video title");
            break;
        case VCreateViewControllerTypePhotoAndVideo:
            self.title = NSLocalizedString(@"New Post", @"New post(photo or video) title");
            break;
        case VCreateViewControllerTypePoll:
            self.title = NSLocalizedString(@"New Poll", @"New poll title");
            break;
        case VCreateViewControllerTypeForum:
            self.title = NSLocalizedString(@"New Topic", @"New topic(forum) title");
            break;
    }

    CGSize mediaViewSize = CGSizeMake(200, 200);
    UIView *mediaView = [UIView autoLayoutView];
    [self.view addSubview:mediaView];
    [mediaView constrainToSize:mediaViewSize];
    [mediaView centerInContainerOnAxis:NSLayoutAttributeCenterX];
    self.contentTopConstraint = [mediaView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:self.topLayoutGuide];

    CGSize mediaButtonSize = CGSizeMake(120, 120);
    UIButton *mediaButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [mediaButton addTarget:self action:@selector(mediaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [mediaButton setImage:[UIImage imageNamed:@"PostCamera"] forState:UIControlStateNormal];
    mediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.mediaButton.icon"];
    mediaButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.mediaButton.background"];
    mediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    mediaButton.layer.cornerRadius = mediaButtonSize.height/2;
    [mediaView addSubview:mediaButton];
    [mediaButton centerInContainerOnAxis:NSLayoutAttributeCenterY];
    [mediaButton centerInContainerOnAxis:NSLayoutAttributeCenterX];
    [mediaButton constrainToSize:mediaButtonSize];
    self.mediaButton = mediaButton;

    UILabel *mediaLabel = [UILabel autoLayoutView];
    mediaLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.text"];
    [mediaView addSubview:mediaLabel];
    [mediaLabel pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:mediaButton inset:VCreateViewControllerLargePadding];
    [mediaLabel centerInContainerOnAxis:NSLayoutAttributeCenterX];
    self.mediaLabel = mediaLabel;

    switch(self.type)
    {
        case VCreateViewControllerTypePhoto:
            mediaLabel.text = NSLocalizedString(@"Add a photo", @"Add photo label");
            break;
        case VCreateViewControllerTypeVideo:
            mediaLabel.text = NSLocalizedString(@"Add a video", @"Add video label");
            break;
        case VCreateViewControllerTypePhotoAndVideo:
        case VCreateViewControllerTypePoll:
        case VCreateViewControllerTypeForum:
            mediaLabel.text = NSLocalizedString(@"Add a photo or video", @"Add photo or video label");
            break;
    }

    UITextView *textView = [UITextView autoLayoutView];
    textView.delegate = self;
    textView.returnKeyType = UIReturnKeyDone;
    textView.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.text"];
    textView.layer.borderColor = [[[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.text.border"] CGColor];
    textView.layer.borderWidth = 1;
    [self.view addSubview:textView];
    [textView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:mediaLabel inset:VCreateViewControllerLargePadding];
    [textView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:VCreateViewControllerPadding];
    [textView constrainToHeight:120];
    self.textView = textView;

    CGFloat postButtonHeight = 44;
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [postButton addTarget:self action:@selector(postButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    postButton.translatesAutoresizingMaskIntoConstraints = NO;
    postButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.postButton.text"];
    postButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.postButton.background"];
    [postButton setTitle:NSLocalizedString(@"POST IT", @"Post button") forState:UIControlStateNormal];
    postButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.post.postButton"];
    [self.view addSubview:postButton];
    [postButton pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinBottomEdge|JRTViewPinRightEdge inset:VCreateViewControllerPadding];
    [postButton constrainToHeight:postButtonHeight];
    self.postButton = postButton;

    UILabel *characterCountLabel = [UILabel autoLayoutView];
    characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.text"];
    characterCountLabel.text = @"0";
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

- (void)validatePostButtonState{
    if([self.textView.text length] > VConstantsMessageLength)
    {
        [self.postButton setEnabled:NO];
        return;
    }
    if([self.textView.text length] == 0)
    {
        [self.postButton setEnabled:NO];
        return;
    }
    [self.postButton setEnabled:YES];
}

#pragma mark - Actions

- (IBAction)closeButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaButtonAction:(id)sender
{
    if (self.imagePickerController)
    {
        self.imagePickerController = nil;
    }

    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = YES;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }else{
        [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    switch(self.type)
    {
        case VCreateViewControllerTypePhoto:
            self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
            break;
        case VCreateViewControllerTypeVideo:
            self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
            break;
        case VCreateViewControllerTypePhotoAndVideo:
        case VCreateViewControllerTypePoll:
        case VCreateViewControllerTypeForum:
            self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
            break;
    }

//    SMECameraOverlayView *cameraOverlayView =
//    [[SMECameraOverlayView alloc] initWithImagePickerController:self.imagePickerController];
//    self.imagePickerController.cameraOverlayView = cameraOverlayView;
//    self.imagePickerController.showsCameraControls = NO;

    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)postButtonAction:(id)sender
{
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

    [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve << 16) animations:^{
        self.contentTopConstraint.constant = -MAX(0, CGRectGetMaxY(self.textView.frame)-CGRectGetMinY(keyboardEndFrame)+VCreateViewControllerPadding);
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSUInteger characterCount = [textView.text length];
    if(characterCount > VConstantsMessageLength)
    {
        self.characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.text.count.invalid"];
    }
    else
    {
        self.characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.text.count"];
    }
    self.characterCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)characterCount];
    [self validatePostButtonState];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:nil];

    if(UTTypeEqual((__bridge CFStringRef)(info[UIImagePickerControllerMediaType]), kUTTypeMovie))
    {
        NSURL *mediaURL = info[UIImagePickerControllerMediaURL];
    }
    else
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (image == nil)
        {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
    }
}

@end
