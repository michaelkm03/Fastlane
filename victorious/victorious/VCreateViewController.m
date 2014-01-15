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

@interface VCreateViewController()
<UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) NSLayoutConstraint *contentTopConstraint;
@property (weak, nonatomic) UIButton *mediaButton;
@property (weak, nonatomic) UIImageView *previewImage;
@property (weak, nonatomic) UIButton *removeMediaButton;
@property (weak, nonatomic) UILabel *mediaLabel;
@property (weak, nonatomic) UITextView *textView;
@property (weak, nonatomic) UIButton *postButton;
@property (weak, nonatomic) UILabel *characterCountLabel;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) VCreateViewControllerType type;
@property (weak, nonatomic) id<VCreateSequenceDelegate> delegate;
@property (strong, nonatomic) NSData *mediaData;
@property (strong, nonatomic) NSString *mediaType;
@end

@implementation VCreateViewController

- (instancetype)initWithType:(VCreateViewControllerType)type andDelegate:(id<VCreateSequenceDelegate>)delegate
{
    if(!(self = [super init]))
    {
        return nil;
    }

    self.type = type;
    self.delegate = delegate;

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
    }

    CGSize mediaViewSize = CGSizeMake(200, 200);
    UIView *mediaView = [UIView autoLayoutView];
    [self.view addSubview:mediaView];
    [mediaView constrainToSize:mediaViewSize];
    [mediaView centerInContainerOnAxis:NSLayoutAttributeCenterX];
    self.contentTopConstraint = [mediaView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:self.topLayoutGuide inset:VCreateViewControllerLargePadding];

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
    mediaLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.mediaLabel"];
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
            mediaLabel.text = NSLocalizedString(@"Add a photo or video", @"Add photo or video label");
            break;
    }

    UIImageView *previewImage = [UIImageView autoLayoutView];
    previewImage.userInteractionEnabled = YES;
    [mediaView addSubview:previewImage];
    [previewImage pinToSuperviewEdgesWithInset:UIEdgeInsetsZero];
    [previewImage setHidden:YES];
    self.previewImage = previewImage;

    UIImage *removeMediaButtonImage = [UIImage imageNamed:@"PostDelete"];
    UIButton *removeMediaButton = [UIButton buttonWithType:UIButtonTypeSystem];
    removeMediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.media.remove"];
    removeMediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    [removeMediaButton setImage:removeMediaButtonImage forState:UIControlStateNormal];
    [removeMediaButton addTarget:self action:@selector(removeMediaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [previewImage addSubview:removeMediaButton];
    [removeMediaButton constrainToSize:removeMediaButtonImage.size];
    [removeMediaButton pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinLeftEdge inset:VCreateViewControllerPadding];

    UITextView *textView = [UITextView autoLayoutView];
    textView.delegate = self;
    textView.returnKeyType = UIReturnKeyDone;
    textView.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post"];
    textView.layer.borderColor = [[[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.input.border"] CGColor];
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
    if([self.textView.text length] == 0)
    {
        [self.postButton setEnabled:NO];
        return;
    }
    [self.postButton setEnabled:YES];
}

- (void)clearMedia{
    self.mediaData = nil;
    self.mediaType = nil;
    self.previewImage.image = nil;
    [self.previewImage setHidden:YES];
}

- (void)setMediaData:(NSData *)mediaData
{
    if(_mediaData == mediaData)
    {
        return;
    }

    _mediaData = mediaData;
    [self validatePostButtonState];
}

#pragma mark - Actions

- (IBAction)closeButtonAction:(id)sender
{
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaButtonAction:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.videoMaximumDuration = 10.0f;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }else{
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    switch(self.type)
    {
        case VCreateViewControllerTypePhoto:
            imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
            break;
        case VCreateViewControllerTypeVideo:
            imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
            break;
        case VCreateViewControllerTypePhotoAndVideo:
            imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
            break;
    }

    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)postButtonAction:(id)sender
{
    [self.textView resignFirstResponder];
    
    [self.delegate createViewController:self shouldPostWithMessage:self.textView.text
                                   data:self.mediaData mediaType:self.mediaType];

}

- (void)removeMediaButtonAction:(id)sender
{
    [self clearMedia];
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
        self.contentTopConstraint.constant = VCreateViewControllerLargePadding-MAX(0, CGRectGetMaxY(self.textView.frame)-CGRectGetMinY(keyboardEndFrame)+VCreateViewControllerPadding);
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSUInteger characterCount = [textView.text length];
    if(characterCount > VConstantsMessageLength)
    {
        self.characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.count.invalid"];
    }
    else
    {
        self.characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.count"];
    }
    self.characterCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)(VConstantsMessageLength - characterCount)];
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
        self.mediaData = [NSData dataWithContentsOfURL:mediaURL];
        self.mediaType = [mediaURL pathExtension];

        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:mediaURL options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:NULL error:&error];
        if(error)
        {
            NSLog(@"%@", error);
        }
        self.previewImage.image = [[UIImage alloc] initWithCGImage:image];
        [self.previewImage setHidden:NO];
        CGImageRelease(image);
    }
    else if(UTTypeEqual((__bridge CFStringRef)(info[UIImagePickerControllerMediaType]), kUTTypeImage))
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (image == nil)
        {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        self.mediaData = [NSData dataWithData:UIImagePNGRepresentation(image)];
        self.mediaType = @"png";

        self.previewImage.image = image;
        [self.previewImage setHidden:NO];
    }
}

@end
