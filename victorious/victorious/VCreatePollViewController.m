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

CGFloat VCreatePollViewControllerPadding = 8;
CGFloat VCreatePollViewControllerLargePadding = 20;

@interface VCreatePollViewControllerTextField : UITextField
@end
@implementation VCreatePollViewControllerTextField
- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, VCreatePollViewControllerLargePadding, 0);
}
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, VCreatePollViewControllerLargePadding, 0);
}
@end

@interface VCreatePollViewController()
<UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) id<VCreateSequenceDelegate> delegate;
@property (weak, nonatomic) UIButton *postButton;
@property (weak, nonatomic) VCreatePollViewControllerTextField *questionTextField;
@property (weak, nonatomic) VCreatePollViewControllerTextField *leftQuestionTextField;
@property (weak, nonatomic) VCreatePollViewControllerTextField *rightQuestionTextField;
@property (weak, nonatomic) UIImageView *oneUpPreviewImageView;
@property (weak, nonatomic) UIImageView *leftPreviewImageView;
@property (weak, nonatomic) UIImageView *rightPreviewImageView;
@property (weak, nonatomic) UIButton *mediaButton;
@property (weak, nonatomic) UILabel *mediaLabel;
@property (strong, nonatomic) NSData *leftMediaData;
@property (strong, nonatomic) NSData *rightMediaData;
@property (strong, nonatomic) NSString *leftMediaType;
@property (strong, nonatomic) NSString *rightMediaType;
@property (weak, nonatomic) UIView *addMediaView;
@property (weak, nonatomic) UIView *oneUpMediaView;
@property (weak, nonatomic) UIView *twoUpMediaView;
@end

@implementation VCreatePollViewController

- (instancetype)initWithDelegate:(id<VCreateSequenceDelegate>)delegate
{
    if(!(self = [super init]))
    {
        return nil;
    }

    self.delegate = delegate;

    self.title = NSLocalizedString(@"New Poll", @"New poll title");
    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.background"];
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"]
                                     style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonAction:)];

    CGFloat questionsHeight = 66;

    VCreatePollViewControllerTextField *questionTextField = [VCreatePollViewControllerTextField autoLayoutView];
    questionTextField.delegate = self;
    questionTextField.returnKeyType = UIReturnKeyDone;
    questionTextField.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.poll.question"];
    [questionTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    questionTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    questionTextField.placeholder = NSLocalizedString(@"Ask a Question...", @"Poll question placeholder");
    [self.view addSubview:questionTextField];
    [questionTextField constrainToHeight:questionsHeight];
    [questionTextField pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];
    [questionTextField pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:self.topLayoutGuide];
    self.questionTextField = questionTextField;

    UIView *questionsView = [UIView autoLayoutView];
    questionsView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.poll.questions.border"];
    [self.view addSubview:questionsView];
    [questionsView constrainToHeight:questionsHeight+2];
    [questionsView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:questionTextField];
    [questionsView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];

    VCreatePollViewControllerTextField *leftQuestionTextField = [VCreatePollViewControllerTextField autoLayoutView];
    leftQuestionTextField.delegate = self;
    leftQuestionTextField.returnKeyType = UIReturnKeyDone;
    leftQuestionTextField.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.poll.questions.left.background"];
    leftQuestionTextField.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.poll.questions.left"];
    [leftQuestionTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    leftQuestionTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    leftQuestionTextField.textAlignment = NSTextAlignmentCenter;
    leftQuestionTextField.placeholder = NSLocalizedString(@"VOTE THIS...", @"Poll left question placeholder");
    [questionsView addSubview:leftQuestionTextField];
    [leftQuestionTextField pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinBottomEdge inset:1];
    [leftQuestionTextField pinToSuperviewEdges:JRTViewPinLeftEdge inset:0];
    self.leftQuestionTextField = leftQuestionTextField;

    VCreatePollViewControllerTextField *rightQuestionTextField = [VCreatePollViewControllerTextField autoLayoutView];
    rightQuestionTextField.delegate = self;
    rightQuestionTextField.returnKeyType = UIReturnKeyDone;
    rightQuestionTextField.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.poll.questions.right.background"];
    rightQuestionTextField.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.poll.questions.right"];
    [rightQuestionTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    rightQuestionTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    rightQuestionTextField.textAlignment = NSTextAlignmentCenter;
    rightQuestionTextField.placeholder = NSLocalizedString(@"VOTE THAT...", @"Poll left question placeholder");
    [questionsView addSubview:rightQuestionTextField];
    [rightQuestionTextField pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinBottomEdge inset:1];
    [rightQuestionTextField pinToSuperviewEdges:JRTViewPinRightEdge inset:0];
    self.rightQuestionTextField = rightQuestionTextField;

    [questionsView addConstraint:[NSLayoutConstraint constraintWithItem:leftQuestionTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:questionsView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [questionsView addConstraint:[NSLayoutConstraint constraintWithItem:rightQuestionTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:questionsView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

    CGSize orLabelSize = CGSizeMake(38, 38);
    UILabel *orLabel = [UILabel autoLayoutView];
    orLabel.textAlignment = NSTextAlignmentCenter;
    orLabel.layer.cornerRadius = orLabelSize.height/2;
    orLabel.layer.borderWidth = 2;
    orLabel.layer.borderColor = [[[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.poll.or.border"] CGColor];
    orLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.poll.or"];
    orLabel.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.poll.or.background"];
    orLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.post.poll.or"];
    orLabel.text = NSLocalizedString(@"OR", @"Poll OR");
    [questionsView addSubview:orLabel];
    [orLabel constrainToSize:orLabelSize];
    [orLabel centerInContainerOnAxis:NSLayoutAttributeCenterX];
    [orLabel centerInContainerOnAxis:NSLayoutAttributeCenterY];

    CGFloat postButtonHeight = 44;
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [postButton addTarget:self action:@selector(postButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    postButton.translatesAutoresizingMaskIntoConstraints = NO;
    postButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.postButton"];
    postButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.postButton.background"];
    [postButton setTitle:NSLocalizedString(@"POST POLL", @"Post poll button") forState:UIControlStateNormal];
    postButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.post.postButton"];
    [self.view addSubview:postButton];
    [postButton pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinBottomEdge|JRTViewPinRightEdge inset:VCreatePollViewControllerPadding];
    [postButton constrainToHeight:postButtonHeight];
    self.postButton = postButton;

    UIView *addMediaView = [UIView autoLayoutView];
    [self.view addSubview:addMediaView];
    [addMediaView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:VCreatePollViewControllerPadding];
    [addMediaView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:questionsView inset:VCreatePollViewControllerPadding];
    [addMediaView pinEdge:NSLayoutAttributeBottom toEdge:NSLayoutAttributeTop ofItem:postButton inset:-VCreatePollViewControllerPadding];
    self.addMediaView = addMediaView;

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
    self.mediaButton = mediaButton;

    UILabel *mediaLabel = [UILabel autoLayoutView];
    mediaLabel.text = NSLocalizedString(@"Add a photo or video", @"Add photo or video label");
    mediaLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.mediaLabel"];
    [addMediaView addSubview:mediaLabel];
    [mediaLabel pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:mediaButton inset:VCreatePollViewControllerLargePadding];
    [mediaLabel centerInContainerOnAxis:NSLayoutAttributeCenterX];
    self.mediaLabel = mediaLabel;

    UIView *oneUpMediaView = [UIView autoLayoutView];
    [self.view addSubview:oneUpMediaView];
    [oneUpMediaView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:VCreatePollViewControllerPadding];
    [oneUpMediaView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:questionsView inset:VCreatePollViewControllerPadding];
    [oneUpMediaView pinEdge:NSLayoutAttributeBottom toEdge:NSLayoutAttributeTop ofItem:postButton inset:-VCreatePollViewControllerPadding];
    self.oneUpMediaView = oneUpMediaView;

    UIImageView *oneUpPreviewImageView = [UIImageView autoLayoutView];
    oneUpPreviewImageView.userInteractionEnabled = YES;
    [oneUpMediaView addSubview:oneUpPreviewImageView];
    [oneUpPreviewImageView pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinLeftEdge inset:0];
    [oneUpPreviewImageView constrainToSize:CGSizeMake(200, 200)];
    self.oneUpPreviewImageView = oneUpPreviewImageView;

    UIImage *oneUpRemoveMediaButtonImage = [UIImage imageNamed:@"PostDelete"];
    UIButton *oneUpRemoveMediaButton = [UIButton buttonWithType:UIButtonTypeSystem];
    oneUpRemoveMediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.media.remove"];
    oneUpRemoveMediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    [oneUpRemoveMediaButton setImage:oneUpRemoveMediaButtonImage forState:UIControlStateNormal];
    [oneUpRemoveMediaButton addTarget:self action:@selector(oneUpRemoveMediaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [oneUpPreviewImageView addSubview:oneUpRemoveMediaButton];
    [oneUpRemoveMediaButton constrainToSize:oneUpRemoveMediaButtonImage.size];
    [oneUpRemoveMediaButton pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinLeftEdge inset:VCreatePollViewControllerPadding];

    UIImage *oneUpAddMediaButtonImage = [UIImage imageNamed:@"PostPollAdd"];
    UIButton *oneUpAddMediaButton = [UIButton buttonWithType:UIButtonTypeSystem];
    oneUpAddMediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.mediaButton.background"];
    oneUpAddMediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    [oneUpAddMediaButton setImage:oneUpAddMediaButtonImage forState:UIControlStateNormal];
    [oneUpAddMediaButton addTarget:self action:@selector(mediaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [oneUpMediaView addSubview:oneUpAddMediaButton];
    [oneUpAddMediaButton pinToSuperviewEdges:JRTViewPinRightEdge|JRTViewPinTopEdge inset:0];
    [oneUpAddMediaButton pinAttribute:NSLayoutAttributeHeight toSameAttributeOfView:oneUpPreviewImageView];
    [oneUpAddMediaButton pinEdge:NSLayoutAttributeLeft toEdge:NSLayoutAttributeRight ofItem:oneUpPreviewImageView];

    UIView *twoUpMediaView = [UIView autoLayoutView];
    [self.view addSubview:twoUpMediaView];
    [twoUpMediaView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:VCreatePollViewControllerPadding];
    [twoUpMediaView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:questionsView inset:VCreatePollViewControllerPadding];
    [twoUpMediaView pinEdge:NSLayoutAttributeBottom toEdge:NSLayoutAttributeTop ofItem:postButton inset:-VCreatePollViewControllerPadding];
    self.twoUpMediaView = twoUpMediaView;

    UIImageView *leftPreviewImageView = [UIImageView autoLayoutView];
    leftPreviewImageView.userInteractionEnabled = YES;
    [twoUpMediaView addSubview:leftPreviewImageView];
    [leftPreviewImageView pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinLeftEdge inset:0];
    self.leftPreviewImageView = leftPreviewImageView;

    UIImage *leftRemoveMediaButtonImage = [UIImage imageNamed:@"PostDelete"];
    UIButton *leftRemoveMediaButton = [UIButton buttonWithType:UIButtonTypeSystem];
    leftRemoveMediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.media.remove"];
    leftRemoveMediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    [leftRemoveMediaButton setImage:leftRemoveMediaButtonImage forState:UIControlStateNormal];
    [leftRemoveMediaButton addTarget:self action:@selector(leftRemoveMediaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [leftPreviewImageView addSubview:leftRemoveMediaButton];
    [leftRemoveMediaButton constrainToSize:leftRemoveMediaButtonImage.size];
    [leftRemoveMediaButton pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinLeftEdge inset:VCreatePollViewControllerPadding];

    UIImageView *rightPreviewImageView = [UIImageView autoLayoutView];
    rightPreviewImageView.userInteractionEnabled = YES;
    [twoUpMediaView addSubview:rightPreviewImageView];
    [rightPreviewImageView pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinRightEdge inset:0];
    self.rightPreviewImageView = rightPreviewImageView;

    UIImage *rightRemoveMediaButtonImage = [UIImage imageNamed:@"PostDelete"];
    UIButton *rightRemoveMediaButton = [UIButton buttonWithType:UIButtonTypeSystem];
    rightRemoveMediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.media.remove"];
    rightRemoveMediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    [rightRemoveMediaButton setImage:rightRemoveMediaButtonImage forState:UIControlStateNormal];
    [rightRemoveMediaButton addTarget:self action:@selector(rightRemoveMediaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightPreviewImageView addSubview:rightRemoveMediaButton];
    [rightRemoveMediaButton constrainToSize:rightRemoveMediaButtonImage.size];
    [rightRemoveMediaButton pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinLeftEdge inset:VCreatePollViewControllerPadding];

    [twoUpMediaView addConstraint:[NSLayoutConstraint constraintWithItem:leftPreviewImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:twoUpMediaView attribute:NSLayoutAttributeCenterX multiplier:1 constant:-VCreatePollViewControllerPadding/2]];
    [twoUpMediaView addConstraint:[NSLayoutConstraint constraintWithItem:rightPreviewImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:twoUpMediaView attribute:NSLayoutAttributeCenterX multiplier:1 constant:VCreatePollViewControllerPadding/2]];

    [twoUpMediaView addConstraint:[NSLayoutConstraint constraintWithItem:leftPreviewImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:leftPreviewImageView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [twoUpMediaView addConstraint:[NSLayoutConstraint constraintWithItem:rightPreviewImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:rightPreviewImageView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];

    [self validatePostButtonState];
    [self updateViewState];

    return self;        
}

- (void)validatePostButtonState{
    if(!self.leftMediaData)
    {
        [self.postButton setEnabled:NO];
        return;
    }

    if([self.questionTextField.text length] == 0)
    {
        [self.postButton setEnabled:NO];
        return;
    }
    if([self.questionTextField.text length] > VConstantsForumTitleLength)
    {
        [self.postButton setEnabled:NO];
        return;
    }

    if([self.leftQuestionTextField.text length] == 0)
    {
        [self.postButton setEnabled:NO];
        return;
    }
    if([self.leftQuestionTextField.text length] > VConstantsForumTitleLength)
    {
        [self.postButton setEnabled:NO];
        return;
    }

    if([self.rightQuestionTextField.text length] == 0)
    {
        [self.postButton setEnabled:NO];
        return;
    }
    if([self.rightQuestionTextField.text length] > VConstantsForumTitleLength)
    {
        [self.postButton setEnabled:NO];
        return;
    }

    [self.postButton setEnabled:YES];
}

- (void)updateViewState
{
    if(!self.leftMediaData && !self.rightMediaData)
    {
        [self.addMediaView setHidden:NO];
        [self.oneUpMediaView setHidden:YES];
        [self.twoUpMediaView setHidden:YES];
    }
    else if(self.leftMediaData || self.rightMediaData)
    {
        [self.addMediaView setHidden:YES];

        if(self.leftMediaData && !self.rightMediaData)
        {
            [self.oneUpMediaView setHidden:NO];
            [self.twoUpMediaView setHidden:YES];
        }
        else
        {
            [self.oneUpMediaView setHidden:YES];
            [self.twoUpMediaView setHidden:NO];
        }
    }
}

- (void)addMediaWithImage:(UIImage *)image data:(NSData *)data andType:(NSString *)type
{
    if(!self.leftMediaData)
    {
        self.leftMediaData = data;
        self.leftMediaType = type;
        self.leftPreviewImageView.image = image;
        self.oneUpPreviewImageView.image = image;
    }
    else
    {
        self.rightMediaData = data;
        self.rightMediaType = type;
        self.rightPreviewImageView.image = image;
    }

    [self updateViewState];
    [self validatePostButtonState];
}

- (void)clearLeftMedia
{
    self.leftMediaData = nil;
    self.leftMediaType = nil;
    self.leftPreviewImageView.image = nil;

    if(self.rightMediaData)
    {
        NSData *data = self.rightMediaData;
        NSString *type = self.leftMediaType;
        UIImage *image = self.rightPreviewImageView.image;
        [self clearRightMedia];
        [self addMediaWithImage:image data:data andType:type];
    }
    else
    {
        [self updateViewState];
        [self validatePostButtonState];
    }
}

- (void)clearRightMedia
{
    self.rightMediaData = nil;
    self.rightMediaType = nil;
    self.rightPreviewImageView.image = nil;
    [self updateViewState];
    [self validatePostButtonState];
}

#pragma mark - Actions

- (void)oneUpRemoveMediaButtonAction:(id)sender
{
    [self clearLeftMedia];
}

- (void)leftRemoveMediaButtonAction:(id)sender
{
    [self clearLeftMedia];
}

- (void)rightRemoveMediaButtonAction:(id)sender
{
    [self clearRightMedia];
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

- (void)closeButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postButtonAction:(id)sender
{
    [self.delegate createViewController:self
             shouldPostPollWithQuestion:self.questionTextField.text
                            answer1Text:self.leftQuestionTextField.text
                            answer2Text:self.rightQuestionTextField.text
                             media1Data:self.leftMediaData
                        media1Extension:self.leftMediaType
                             media2Data:self.rightMediaData
                        media2Extension:self.rightMediaType];

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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:nil];

    if(UTTypeEqual((__bridge CFStringRef)(info[UIImagePickerControllerMediaType]), kUTTypeMovie))
    {
        NSURL *mediaURL = info[UIImagePickerControllerMediaURL];
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

        [self addMediaWithImage:[[UIImage alloc] initWithCGImage:image] data:[NSData dataWithContentsOfURL:mediaURL] andType:[mediaURL pathExtension]];

        CGImageRelease(image);
    }
    else if(UTTypeEqual((__bridge CFStringRef)(info[UIImagePickerControllerMediaType]), kUTTypeImage))
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (image == nil)
        {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        [self addMediaWithImage:image data:[NSData dataWithData:UIImagePNGRepresentation(image)] andType:@"png"];
    }
}

@end
