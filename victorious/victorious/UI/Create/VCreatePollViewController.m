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

@interface VCreatePollViewController()
<UITextFieldDelegate>

@property (strong, nonatomic) NSData *mediaData;
@property (strong, nonatomic) NSData *secondMediaData;

@property (strong, nonatomic) NSString *mediaType;
@property (strong, nonatomic) NSString *secondMediaType;

@end

@implementation VCreatePollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.questionTextField.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.poll.question"];
    //    [questionTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    //    self.questionTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.questionTextField.placeholder = NSLocalizedString(@"Ask a Question...", @"Poll question placeholder");
    //    [questionTextField constrainToHeight:questionsHeight];
    //    [questionTextField pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];
    //    [questionTextField pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:self.topLayoutGuide];
    
    self.questionViews.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.poll.questions.border"];
    //    [questionsView constrainToHeight:questionsHeight+2];
    //    [questionsView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:questionTextField];
    //    [questionsView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];
    
    self.leftAnswerTextField.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.poll.questions.left.background"];
    self.leftAnswerTextField.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.poll.questions.left"];
    //    self.leftAnswerTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.leftAnswerTextField.textAlignment = NSTextAlignmentCenter;
    self.leftAnswerTextField.placeholder = NSLocalizedString(@"VOTE THIS...", @"Poll left question placeholder");
    //    [leftAnswerTextField pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinBottomEdge inset:1];
    //    [leftAnswerTextField pinToSuperviewEdges:JRTViewPinLeftEdge inset:0];
    
    self.rightAnswerTextField.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.poll.questions.right.background"];
    self.rightAnswerTextField.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.poll.questions.right"];
    //    self.rightAnswerTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.rightAnswerTextField.placeholder = NSLocalizedString(@"VOTE THAT...", @"Poll left question placeholder");
    //    [rightAnswerTextField pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinBottomEdge inset:1];
    //    [rightAnswerTextField pinToSuperviewEdges:JRTViewPinRightEdge inset:0];
    
    
    //    [questionsView addConstraint:[NSLayoutConstraint constraintWithItem:leftAnswerTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:questionsView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    //    [questionsView addConstraint:[NSLayoutConstraint constraintWithItem:rightAnswerTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:questionsView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
//    CGSize orLabelSize = CGSizeMake(38, 38);
//    UILabel *orLabel = [UILabel autoLayoutView];
//    orLabel.textAlignment = NSTextAlignmentCenter;
//    orLabel.layer.cornerRadius = orLabelSize.height/2;
//    orLabel.layer.borderWidth = 2;
//    orLabel.layer.borderColor = [[[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.poll.or.border"] CGColor];
//    orLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.poll.or"];
//    orLabel.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.poll.or.background"];
//    orLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.post.poll.or"];
//    orLabel.text = NSLocalizedString(@"OR", @"Poll OR");
//    [self.questionView addSubview:orLabel];
//    [orLabel constrainToSize:orLabelSize];
//    [orLabel centerInContainerOnAxis:NSLayoutAttributeCenterX];
//    [orLabel centerInContainerOnAxis:NSLayoutAttributeCenterY];
    
    [self setType:self.type];
    self.mediaLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.mediaLabel"];
    
    UIImage* newImage = [self.removeMediaButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.removeMediaButton setImage:newImage forState:UIControlStateNormal];
    self.removeMediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.media.remove"];
    
    [self.rightRemoveButton setImage:newImage forState:UIControlStateNormal];
    self.rightRemoveButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.media.remove"];
    
    //    [twoUpMediaView addConstraint:[NSLayoutConstraint constraintWithItem:leftPreviewImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:twoUpMediaView attribute:NSLayoutAttributeCenterX multiplier:1 constant:-VCreatePollViewControllerPadding/2]];
    //    [twoUpMediaView addConstraint:[NSLayoutConstraint constraintWithItem:rightPreviewImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:twoUpMediaView attribute:NSLayoutAttributeCenterX multiplier:1 constant:VCreatePollViewControllerPadding/2]];
    //
    //    [twoUpMediaView addConstraint:[NSLayoutConstraint constraintWithItem:leftPreviewImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:leftPreviewImageView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    //    [twoUpMediaView addConstraint:[NSLayoutConstraint constraintWithItem:rightPreviewImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:rightPreviewImageView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    [self validatePostButtonState];
    [self updateViewState];
}

- (void)setType:(VImagePickerViewControllerType)type
{
    [super setType:type];
    
    self.title = NSLocalizedString(@"New Poll", @"New poll title");
}


- (void)validatePostButtonState{
    if(!self.mediaData)
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
    
    if([self.leftAnswerTextField.text length] == 0)
    {
        [self.postButton setEnabled:NO];
        return;
    }
    if([self.leftAnswerTextField.text length] > VConstantsForumTitleLength)
    {
        [self.postButton setEnabled:NO];
        return;
    }
    
    if([self.rightAnswerTextField.text length] == 0)
    {
        [self.postButton setEnabled:NO];
        return;
    }
    if([self.rightAnswerTextField.text length] > VConstantsForumTitleLength)
    {
        [self.postButton setEnabled:NO];
        return;
    }
    
    [self.postButton setEnabled:YES];
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

- (void)clearLeftMedia
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
        [self clearRightMedia];
        [self imagePickerFinishedWithData:data extension:type previewImage:image mediaURL:nil];
    }
    else
    {
        [self updateViewState];
        [self validatePostButtonState];
    }
}

- (void)clearRightMedia
{
    self.secondMediaData = nil;
    self.secondMediaType = nil;
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

- (IBAction)postButtonAction:(id)sender
{
    [self.delegate createPostPollWithQuestion:self.questionTextField.text
                                  answer1Text:self.leftAnswerTextField.text
                                  answer2Text:self.rightAnswerTextField.text
                                   media1Data:self.mediaData
                              media1Extension:self.mediaType
                                   media2Data:self.secondMediaData
                              media2Extension:self.secondMediaType];
    
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
