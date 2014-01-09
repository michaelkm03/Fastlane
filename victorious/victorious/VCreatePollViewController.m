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
@property (weak, nonatomic) UIButton *mediaButton;
@property (weak, nonatomic) UILabel *mediaLabel;
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

    UIView *mediaView = [UIView autoLayoutView];
    [self.view addSubview:mediaView];
    [mediaView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:VCreatePollViewControllerPadding];
    [mediaView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:questionsView inset:VCreatePollViewControllerPadding];
    [mediaView pinEdge:NSLayoutAttributeBottom toEdge:NSLayoutAttributeTop ofItem:postButton inset:-VCreatePollViewControllerPadding];

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
    mediaLabel.text = NSLocalizedString(@"Add a photo or video", @"Add photo or video label");
    mediaLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.mediaLabel"];
    [mediaView addSubview:mediaLabel];
    [mediaLabel pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:mediaButton inset:VCreatePollViewControllerLargePadding];
    [mediaLabel centerInContainerOnAxis:NSLayoutAttributeCenterX];
    self.mediaLabel = mediaLabel;

    [self validatePostButtonState];

    return self;        
}

- (void)validatePostButtonState{
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

#pragma mark - Actions

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
    [self.delegate createViewController:self shouldPostWithMessage:nil
                                   data:nil mediaType:nil];

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

@end
