//
//  VCreateTopicViewController.m
//  victorious
//
//  Created by David Keegan on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VCreateTopicViewController.h"
#import "VThemeManager.h"
#import "UIView+AutoLayout.h"
#import "VConstants.h"

CGFloat VCreateTopicViewControllerPadding = 8;
CGFloat VCreateTopicViewControllerLargePadding = 20;

@interface VCreateTopicViewControllerTextField : UITextField
@end
@implementation VCreateTopicViewControllerTextField
- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, VCreateTopicViewControllerLargePadding, 0);
}
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, VCreateTopicViewControllerLargePadding, 0);
}
@end

@interface VCreateTopicViewController()
<UITextFieldDelegate, UITextViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) id<VCreateSequenceDelegate> delegate;
@property (weak, nonatomic) UIButton *postButton;
@property (weak, nonatomic) VCreateTopicViewControllerTextField *titleTextField;
@property (weak, nonatomic) UITextView *textView;
@property (weak, nonatomic) UILabel *characterCountLabel;
@property (weak, nonatomic) UIImageView *previewImage;
@property (strong, nonatomic) NSData *mediaData;
@property (strong, nonatomic) NSString *mediaType;
@end

@implementation VCreateTopicViewController

- (instancetype)initWithDelegate:(id<VCreateSequenceDelegate>)delegate
{
    if(!(self = [super init]))
    {
        return nil;
    }

    self.delegate = delegate;

    self.title = NSLocalizedString(@"New Topic", @"New forum topic title");
    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.background"];
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"]
                                     style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonAction:)];

    VCreateTopicViewControllerTextField *titleTextField = [VCreateTopicViewControllerTextField autoLayoutView];
    titleTextField.delegate = self;
    titleTextField.returnKeyType = UIReturnKeyDone;
    titleTextField.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.poll.question"];
    [titleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    titleTextField.placeholder = NSLocalizedString(@"Title...", @"Topic title placeholder");
    [self.view addSubview:titleTextField];
    [titleTextField constrainToHeight:48];
    [titleTextField pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];
    [titleTextField pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:self.topLayoutGuide];
    self.titleTextField = titleTextField;

    UIView *messageView = [UIView autoLayoutView];
    messageView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.poll.questions.border"];
    [self.view addSubview:messageView];
    [messageView constrainToHeight:100];
    [messageView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:titleTextField];
    [messageView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];

    UITextView *textView = [UITextView autoLayoutView];
    textView.delegate = self;
    textView.returnKeyType = UIReturnKeyDone;
    textView.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.post"];    
    textView.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post"];
    [messageView addSubview:textView];
    [textView pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinBottomEdge inset:1];
    [textView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];
    self.textView = textView;

    UILabel *characterCountLabel = [UILabel autoLayoutView];
    characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post"];
    characterCountLabel.text = [NSString stringWithFormat:@"%lu", VConstantsMessageLength];
    [self.view addSubview:characterCountLabel];
    [characterCountLabel pinEdges:JRTViewPinRightEdge toSameEdgesOfView:textView inset:VCreateTopicViewControllerPadding];
    [characterCountLabel pinEdges:JRTViewPinBottomEdge toSameEdgesOfView:textView inset:VCreateTopicViewControllerPadding];
    self.characterCountLabel = characterCountLabel;

    CGFloat postButtonHeight = 44;
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [postButton addTarget:self action:@selector(postButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    postButton.translatesAutoresizingMaskIntoConstraints = NO;
    postButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.postButton"];
    postButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.postButton.background"];
    [postButton setTitle:NSLocalizedString(@"POST TOPIC", @"Post forum topic button") forState:UIControlStateNormal];
    postButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.post.postButton"];
    [self.view addSubview:postButton];
    [postButton pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinBottomEdge|JRTViewPinRightEdge inset:VCreateTopicViewControllerPadding];
    [postButton constrainToHeight:postButtonHeight];
    self.postButton = postButton;

    UIView *addMediaView = [UIView autoLayoutView];
    [self.view addSubview:addMediaView];
    [addMediaView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:VCreateTopicViewControllerPadding];
    [addMediaView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:messageView inset:VCreateTopicViewControllerPadding];
    [addMediaView pinEdge:NSLayoutAttributeBottom toEdge:NSLayoutAttributeTop ofItem:postButton inset:-VCreateTopicViewControllerPadding];

    CGSize mediaButtonSize = CGSizeMake(120, 120);
    UIButton *mediaButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [mediaButton addTarget:self action:@selector(mediaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [mediaButton setImage:[UIImage imageNamed:@"PostCamera"] forState:UIControlStateNormal];
    mediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.mediaButton.icon"];
    mediaButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.mediaButton.background"];
    mediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    mediaButton.layer.cornerRadius = mediaButtonSize.height/2;
    [addMediaView addSubview:mediaButton];
    [mediaButton centerInContainerOnAxis:NSLayoutAttributeCenterY];
    [mediaButton centerInContainerOnAxis:NSLayoutAttributeCenterX];
    [mediaButton constrainToSize:mediaButtonSize];

    UILabel *mediaLabel = [UILabel autoLayoutView];
    mediaLabel.text = NSLocalizedString(@"Add a photo or video", @"Add photo or video label");
    mediaLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.mediaLabel"];
    [addMediaView addSubview:mediaLabel];
    [mediaLabel pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:mediaButton inset:VCreateTopicViewControllerLargePadding];
    [mediaLabel centerInContainerOnAxis:NSLayoutAttributeCenterX];

    UIImageView *previewImage = [UIImageView autoLayoutView];
    previewImage.userInteractionEnabled = YES;
    [addMediaView addSubview:previewImage];
    [previewImage constrainToSize:CGSizeMake(200, 200)];
    [previewImage centerInContainerOnAxis:NSLayoutAttributeCenterX];
    [previewImage centerInContainerOnAxis:NSLayoutAttributeCenterY];
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
    [removeMediaButton pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinLeftEdge inset:VCreateTopicViewControllerPadding];

    [self validatePostButtonState];

    return self;
}

- (void)validatePostButtonState{
    if(!self.mediaData)
    {
        [self.postButton setEnabled:NO];
        return;
    }
    
    if([self.titleTextField.text length] == 0)
    {
        [self.postButton setEnabled:NO];
        return;
    }
    if([self.titleTextField.text length] > VConstantsForumTitleLength)
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
    imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
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

- (void)textFieldDidChange:(UITextField *)textField
{
    [self validatePostButtonState];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
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
