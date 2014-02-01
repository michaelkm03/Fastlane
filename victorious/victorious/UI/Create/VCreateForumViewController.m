////
////  VCreateForumViewController.m
////  victorious
////
////  Created by David Keegan on 1/9/14.
////  Copyright (c) 2014 Victorious. All rights reserved.
////
//
//@import AVFoundation;
//
//#import "VCreateForumViewController.h"
//#import "VThemeManager.h"
//#import "UIView+AutoLayout.h"
//#import "VConstants.h"
//
//CGFloat VCreateForumViewControllerPadding = 8;
//CGFloat VCreateForumViewControllerLargePadding = 20;
//
//@interface VCreateForumViewControllerTextField : UITextField
//@end
//@implementation VCreateForumViewControllerTextField
//- (CGRect)textRectForBounds:(CGRect)bounds
//{
//    return CGRectInset(bounds, VCreateForumViewControllerLargePadding, 0);
//}
//- (CGRect)editingRectForBounds:(CGRect)bounds
//{
//    return CGRectInset(bounds, VCreateForumViewControllerLargePadding, 0);
//}
//@end
//
//@interface VCreateForumViewController()
//
//@end
//
//@implementation VCreateForumViewController
//
//- (instancetype)initWithDelegate:(id<VCreateSequenceDelegate>)delegate
//{
//    if(!(self = [super init]))
//    {
//        return nil;
//    }
//
//    self.delegate = delegate;
//
//    self.title = NSLocalizedString(@"New Topic", @"New forum topic title");
//    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostBackgroundColor];
//    self.navigationItem.leftBarButtonItem =
//    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"]
//                                     style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonAction:)];
//
//    VCreateForumViewControllerTextField *titleTextField = [VCreateForumViewControllerTextField autoLayoutView];
//    titleTextField.delegate = self;
//    titleTextField.returnKeyType = UIReturnKeyDone;
//    titleTextField.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.poll.question"];
//    [titleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//    titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    titleTextField.placeholder = NSLocalizedString(@"Title...", @"Topic title placeholder");
//    [self.view addSubview:titleTextField];
//    [titleTextField constrainToHeight:48];
//    [titleTextField pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];
//    [titleTextField pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:self.topLayoutGuide];
//    self.titleTextField = titleTextField;
//
//    UIView *messageView = [UIView autoLayoutView];
//    messageView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePollQuestionBorderColor];
//    [self.view addSubview:messageView];
//    [messageView constrainToHeight:100];
//    [messageView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:titleTextField];
//    [messageView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];
//
//    UITextView *textView = [UITextView autoLayoutView];
//    textView.delegate = self;
//    textView.returnKeyType = UIReturnKeyDone;
//    textView.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVCreatePostFont];    
//    textView.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostTextColor];
//    [messageView addSubview:textView];
//    [textView pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinBottomEdge inset:1];
//    [textView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];
//    self.textView = textView;
//
//    UILabel *characterCountLabel = [UILabel autoLayoutView];
//    characterCountLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostTextColor];
//    characterCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)VConstantsMessageLength];
//    [self.view addSubview:characterCountLabel];
//    [characterCountLabel pinEdges:JRTViewPinRightEdge toSameEdgesOfView:textView inset:VCreateForumViewControllerPadding];
//    [characterCountLabel pinEdges:JRTViewPinBottomEdge toSameEdgesOfView:textView inset:VCreateForumViewControllerPadding];
//    self.characterCountLabel = characterCountLabel;
//
//    CGFloat postButtonHeight = 44;
//    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [postButton addTarget:self action:@selector(postButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    postButton.translatesAutoresizingMaskIntoConstraints = NO;
//    postButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostButtonTextColor];
//    postButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostButtonBGColor];
//    [postButton setTitle:NSLocalizedString(@"POST TOPIC", @"Post forum topic button") forState:UIControlStateNormal];
//    postButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVCreatePostButtonFont];
//    [self.view addSubview:postButton];
//    [postButton pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinBottomEdge|JRTViewPinRightEdge inset:VCreateForumViewControllerPadding];
//    [postButton constrainToHeight:postButtonHeight];
//    self.postButton = postButton;
//
//    UIView *addMediaView = [UIView autoLayoutView];
//    [self.view addSubview:addMediaView];
//    [addMediaView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:VCreateForumViewControllerPadding];
//    [addMediaView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:messageView inset:VCreateForumViewControllerPadding];
//    [addMediaView pinEdge:NSLayoutAttributeBottom toEdge:NSLayoutAttributeTop ofItem:postButton inset:-VCreateForumViewControllerPadding];
//
//    CGSize mediaButtonSize = CGSizeMake(120, 120);
//    UIButton *mediaButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [mediaButton addTarget:self action:@selector(mediaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [mediaButton setImage:[UIImage imageNamed:@"PostCamera"] forState:UIControlStateNormal];
//    mediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostMediaButtonColor];
//    mediaButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostMediaButtonBGColor];
//    mediaButton.translatesAutoresizingMaskIntoConstraints = NO;
//    mediaButton.layer.cornerRadius = mediaButtonSize.height/2;
//    [addMediaView addSubview:mediaButton];
//    [mediaButton centerInContainerOnAxis:NSLayoutAttributeCenterY];
//    [mediaButton centerInContainerOnAxis:NSLayoutAttributeCenterX];
//    [mediaButton constrainToSize:mediaButtonSize];
//
//    UILabel *mediaLabel = [UILabel autoLayoutView];
//    mediaLabel.text = NSLocalizedString(@"Add a photo or video", @"Add photo or video label");
//    mediaLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVCreatePostMediaLabelColor];
//    [addMediaView addSubview:mediaLabel];
//    [mediaLabel pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:mediaButton inset:VCreateForumViewControllerLargePadding];
//    [mediaLabel centerInContainerOnAxis:NSLayoutAttributeCenterX];
//
//    UIImageView *previewImage = [UIImageView autoLayoutView];
//    previewImage.userInteractionEnabled = YES;
//    [addMediaView addSubview:previewImage];
//    [previewImage constrainToSize:CGSizeMake(200, 200)];
//    [previewImage centerInContainerOnAxis:NSLayoutAttributeCenterX];
//    [previewImage centerInContainerOnAxis:NSLayoutAttributeCenterY];
//    [previewImage setHidden:YES];
//    self.previewImage = previewImage;
//
//    UIImage *removeMediaButtonImage = [UIImage imageNamed:@"PostDelete"];
//    UIButton *removeMediaButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    removeMediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:KVRemoveMediaButtonColor];
//    removeMediaButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [removeMediaButton setImage:removeMediaButtonImage forState:UIControlStateNormal];
//    [removeMediaButton addTarget:self action:@selector(clearMedia) forControlEvents:UIControlEventTouchUpInside];
//    [previewImage addSubview:removeMediaButton];
//    [removeMediaButton constrainToSize:removeMediaButtonImage.size];
//    [removeMediaButton pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinLeftEdge inset:VCreateForumViewControllerPadding];
//
//    [self validatePostButtonState];
//
//    return self;
//}
//
//- (void)validatePostButtonState
//{
////    [super validatePostButtonState]
////    if (!self.postButton.enabled)
////        return;
//    
//    if([self.titleTextField.text length] == 0)
//    {
//        [self.postButton setEnabled:NO];
//        return;
//    }
//    if([self.titleTextField.text length] > VConstantsForumTitleLength)
//    {
//        [self.postButton setEnabled:NO];
//        return;
//    }
//
//    [self.postButton setEnabled:YES];
//}
//
//#pragma mark - Actions
//
////- (void)postButtonAction:(id)sender
////{
////    [self.textView resignFirstResponder];
////    [self.delegate createViewController:self
////               shouldPostWithTitle:self.titleTextField.text message:self.textView.text
////                                   data:self.mediaData mediaType:self.mediaType];
////
////}
//
//- (void)textFieldDidChange:(UITextField *)textField
//{
//    [self validatePostButtonState];
//}
//
//#pragma mark - UITextFieldDelegate
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    return YES;
//}
//
//@end
