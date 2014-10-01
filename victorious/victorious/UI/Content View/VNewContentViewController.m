//
//  VNewContentViewController.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNewContentViewController.h"

// Theme
#import "VThemeManager.h"

// View Categories
#import "UIView+VShadows.h"
#import "UIActionSheet+VBlocks.h"

// Images
#import "UIImage+ImageCreation.h"
#import "UIImageView+Blurring.h"

// Layout
#import "VShrinkingContentLayout.h"

// Cells
#import "VContentCell.h"
#import "VContentVideoCell.h"
#import "VContentImageCell.h"
#import "VRealTimeCommentsCell.h"
#import "VContentCommentsCell.h"

// Supplementary Views
#import "VSectionHandleReusableView.h"
#import "VContentBackgroundSupplementaryView.h"

// Input Acceossry
#import "VKeyboardInputAccessoryView.h"

// ViewControllers
#import "VCameraViewController.h"
#import "VVideoLightboxViewController.h"
#import "VImageLightboxViewController.h"
#import "VActionSheetViewController.h"
#import "VActionSheetTransitioningDelegate.h"
#import "VCameraPublishViewController.h"
#import "VRemixSelectViewController.h"
#import "VUserProfileViewController.h"
#import "VStreamContainerViewController.h"
#import "VReposterTableViewController.h"

//TODO: abstract this out of VC
#import "VStream.h"
#import "VStream+Fetcher.h"
#import "VObjectManager+Sequence.h"

// Analytics
#import "VAnalyticsRecorder.h"

// Activities
#import "VFacebookActivity.h"

// Transitioning
#import "VLightboxTransitioningDelegate.h"
#import "VActionSheetPresentationAnimator.h"

// Logged in
#import "VObjectManager+Login.h"
#import "VLoginViewController.h"

// Sharing
//TODO: would like to move this out of the VC
#import "VObjectManager+ContentCreation.h"

// Formatters
#import "VElapsedTimeFormatter.h"

@interface VNewContentViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, VKeyboardInputAccessoryViewDelegate, VContentVideoCellDelgetate, VRealtimeCommentsViewModelDelegate, VRealtimeCommentsCellStripDataSource>

@property (nonatomic, strong, readwrite) VContentViewViewModel *viewModel;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, assign) BOOL hasAutoPlayed;
@property (nonatomic, strong) NSValue *videoSizeValue;

@property (nonatomic, weak) IBOutlet UICollectionView *contentCollectionView;
@property (nonatomic, weak) IBOutlet UIImageView *blurredBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (nonatomic, weak) VContentVideoCell *videoCell;
@property (nonatomic, weak) VRealTimeCommentsCell *realTimeComentsCell;
@property (nonatomic, weak) VSectionHandleReusableView *handleView;

@property (nonatomic, readwrite) VKeyboardInputAccessoryView *inputAccessoryView;

@property (nonatomic, strong) VElapsedTimeFormatter *elapsedTimeFormatter;

@end

@implementation VNewContentViewController

#pragma mark - Factory Methods

+ (VNewContentViewController *)contentViewControllerWithViewModel:(VContentViewViewModel *)viewModel
{
    VNewContentViewController *contentViewController = [[UIStoryboard storyboardWithName:@"ContentView" bundle:nil] instantiateInitialViewController];
    
    contentViewController.viewModel = viewModel;
    contentViewController.hasAutoPlayed = NO;
    contentViewController.elapsedTimeFormatter = [[VElapsedTimeFormatter alloc] init];
    contentViewController.videoSizeValue = nil;
    
    return contentViewController;
}

#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - UIViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.contentCollectionView.collectionViewLayout = [[VShrinkingContentLayout alloc] init];
    
    [self.closeButton setImage:[self.closeButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                      forState:UIControlStateNormal];
    self.closeButton.tintColor = [UIColor whiteColor];
    [self.closeButton v_applyShadowsWithZIndex:2];
    
    [self.moreButton setImage:[self.moreButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                     forState:UIControlStateNormal];
    self.moreButton.imageView.tintColor = [UIColor whiteColor];
    [self.moreButton v_applyShadowsWithZIndex:2];
    
    self.inputAccessoryView = [VKeyboardInputAccessoryView defaultInputAccessoryView];
    self.inputAccessoryView.delegate = self;
    self.inputAccessoryView.returnKeyType = UIReturnKeyDone;
    self.inputAccessoryView.frame = CGRectMake(0,
                                               CGRectGetHeight(self.view.bounds) - self.inputAccessoryView.intrinsicContentSize.height,
                                               CGRectGetWidth(self.view.bounds),
                                               self.inputAccessoryView.intrinsicContentSize.height);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commentsDidUpdate:)
                                                 name:VContentViewViewModelDidUpdateCommentsNotification
                                               object:self.viewModel];
    
    self.contentCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    // Register nibs
    [self.contentCollectionView registerNib:[VContentCell nibForCell]
                 forCellWithReuseIdentifier:[VContentCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentVideoCell nibForCell]
                 forCellWithReuseIdentifier:[VContentVideoCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentImageCell nibForCell]
                 forCellWithReuseIdentifier:[VContentImageCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VRealTimeCommentsCell  nibForCell]
                 forCellWithReuseIdentifier:[VRealTimeCommentsCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentCommentsCell nibForCell]
                 forCellWithReuseIdentifier:[VContentCommentsCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VSectionHandleReusableView nibForCell]
                 forSupplementaryViewOfKind:VShrinkingContentLayoutAllCommentsHandle
                        withReuseIdentifier:[VSectionHandleReusableView suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentBackgroundSupplementaryView nibForCell]
                 forSupplementaryViewOfKind:VShrinkingContentLayoutContentBackgroundView
                        withReuseIdentifier:[VContentBackgroundSupplementaryView suggestedReuseIdentifier]];

    
    self.viewModel.realTimeCommentsViewModel.delegate = self;
    
    // There is a bug where input accessory view will go offscreen and not remain docked on first dismissal of the keyboard. This fixes that.
    [self becomeFirstResponder];
    [self resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];


    
    [self.navigationController setNavigationBarHidden:YES
                                             animated:YES];
    
    self.contentCollectionView.delegate = self;
    
    [self.viewModel fetchComments];
    
    
    self.contentCollectionView.contentInset = UIEdgeInsetsMake(0, 0, self.inputAccessoryView.bounds.size.height, 0);
    
    UIImage *placeholderImage = [UIImage resizeableImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    [self.blurredBackgroundImageView setBlurredImageWithURL:self.viewModel.imageURLRequest.URL
                                           placeholderImage:placeholderImage
                                                  tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];

    if (self.viewModel.type == VContentViewTypeVideo)
    {
        self.inputAccessoryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:self.viewModel.realTimeCommentsViewModel.currentTime]];
    }
    else
    {
        self.inputAccessoryView.placeholderText = NSLocalizedString(@"LaveAComment", @"");
    }
    self.inputAccessoryView.alpha = 0.0f;
    [UIView animateWithDuration:0.2f
                     animations:^
     {
         self.inputAccessoryView.alpha = 1.0f;
     }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.hasAutoPlayed)
    {
        [self.videoCell play];
        self.hasAutoPlayed = YES;
    }

    [self.contentCollectionView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.contentCollectionView.delegate = nil;
    
    [self.view.superview endEditing:YES];
    
    [UIView animateWithDuration:0.2f
                     animations:^
     {
         self.inputAccessoryView.alpha = 0.0f;
     }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.inputAccessoryView removeFromSuperview];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Notification Handlers

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    NSDictionary *userInfo = [notification userInfo];
    
    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIEdgeInsets newInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(endFrame), 0);
    
    [UIView animateWithDuration:animationDuration delay:0
                        options:(animationCurve << 16) animations:^
     {
         self.contentCollectionView.contentInset = newInsets;
         self.contentCollectionView.scrollIndicatorInsets = newInsets;
     }
                     completion:nil];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
}

- (void)commentsDidUpdate:(NSNotification *)notification
{
    if (self.viewModel.commentCount > 0)
    {
        NSIndexSet *commentsIndexSet = [NSIndexSet indexSetWithIndex:VContentViewSectionAllComments];
        [self.contentCollectionView reloadSections:commentsIndexSet];
        
        self.handleView.numberOfComments = self.viewModel.commentCount;
    }
}

#pragma mark - IBActions

- (IBAction)pressedClose:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)pressedMore:(id)sender
{
    [self becomeFirstResponder];
    [self resignFirstResponder];
    
    VActionSheetViewController *actionSheetViewController = [VActionSheetViewController actionSheetViewController];
    [VActionSheetTransitioningDelegate addNewTransitioningDelegateToActionSheetController:actionSheetViewController];
    
    VActionItem *userItem = [VActionItem userActionItemUserWithTitle:self.viewModel.authorName
                                                           avatarURL:self.viewModel.avatarForAuthor
                                                          detailText:self.viewModel.authorCaption];
    userItem.selectionHandler = ^(void)
    {
        [self dismissViewControllerAnimated:YES
                                 completion:^
         {
             VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:self.viewModel.user];
             [self.navigationController pushViewController:profileViewController animated:YES];
         }];
    };
    VActionItem *descripTionItem = [VActionItem descriptionActionItemWithText:self.viewModel.name
                                                      hashTagSelectionHandler:^(NSString *hashTag)
                                    {
                                        VStreamContainerViewController *container = [VStreamContainerViewController modalContainerForStreamTable:[VStreamTableViewController hashtagStreamWithHashtag:hashTag]];
                                        container.shouldShowHeaderLogo = NO;
                                        
                                        [self dismissViewControllerAnimated:YES
                                                                 completion:^
                                         {
                                             [self.navigationController pushViewController:container
                                                                                  animated:YES];
                                         }];
                                    }];
    VActionItem *remixItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Remix", @"") actionIcon:[UIImage imageNamed:@"remixIcon"] detailText:self.viewModel.remixCountText];
    remixItem.selectionHandler = ^(void)
    {
        if (![VObjectManager sharedManager].mainUser)
        {
            [self dismissViewControllerAnimated:YES
                                     completion:^
             {
                 [self presentViewController:[VLoginViewController loginViewController]
                                    animated:YES
                                  completion:NULL];
             }];

            return;
        }
        
        NSString *label = [self.viewModel.sequence.remoteId.stringValue stringByAppendingPathComponent:self.viewModel.sequence.name];
        [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation action:@"Pressed Remix" label:label value:nil];
        
        if (self.viewModel.type == VContentViewTypeVideo)
        {
            UIViewController *remixVC = [VRemixSelectViewController remixViewControllerWithURL:self.viewModel.sourceURLForCurrentAssetData
                                                                                    sequenceID:[self.viewModel.sequence.remoteId integerValue]
                                                                                        nodeID:self.viewModel.nodeID];
            [self presentViewController:remixVC
                               animated:YES
                             completion:
             ^{
                 [self.videoCell.videoPlayerViewController.player pause];
             }];
        }
        else
        {
            VCameraPublishViewController *publishViewController = [VCameraPublishViewController cameraPublishViewController];
            publishViewController.previewImage = self.blurredBackgroundImageView.downloadedImage;
            publishViewController.parentID = [self.viewModel.sequence.remoteId integerValue];
            publishViewController.completion = ^(BOOL complete)
            {
                [self dismissViewControllerAnimated:YES
                                         completion:nil];
            };
            UINavigationController *remixNav = [[UINavigationController alloc] initWithRootViewController:publishViewController];
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                               onCancelButton:nil
                                                       destructiveButtonTitle:nil
                                                          onDestructiveButton:nil
                                                   otherButtonTitlesAndBlocks:NSLocalizedString(@"Meme", nil),  ^(void)
                                          {
                                              publishViewController.captionType = VCaptionTypeMeme;
                                              
                                              NSData *filteredImageData = UIImageJPEGRepresentation(self.blurredBackgroundImageView.downloadedImage, VConstantJPEGCompressionQuality);
                                              NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
                                              NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
                                              if ([filteredImageData writeToURL:tempFile atomically:NO])
                                              {
                                                  publishViewController.mediaURL = tempFile;
                                                  [self presentViewController:remixNav
                                                                     animated:YES
                                                                   completion:nil];
                                              }
                                          },
                                          NSLocalizedString(@"Quote", nil),  ^(void)
                                          {
                                              publishViewController.captionType = VCaptionTypeQuote;
                                              
                                              NSData *filteredImageData = UIImageJPEGRepresentation(self.blurredBackgroundImageView.downloadedImage, VConstantJPEGCompressionQuality);
                                              NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
                                              NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
                                              if ([filteredImageData writeToURL:tempFile atomically:NO])
                                              {
                                                  publishViewController.mediaURL = tempFile;
                                                  [self presentViewController:remixNav
                                                                     animated:YES
                                                                   completion:nil];
                                              }
                                          }, nil];
            [self dismissViewControllerAnimated:YES
                                     completion:^
             {
                 [actionSheet showInView:self.view];
             }];

        }
    };
    remixItem.detailSelectionHandler = ^(void)
    {
        [self dismissViewControllerAnimated:YES
                                 completion:^
         {
             VStream *stream = [VStream remixStreamForSequence:self.viewModel.sequence];
             VStreamTableViewController  *streamTableView = [VStreamTableViewController streamWithDefaultStream:stream name:@"remix" title:NSLocalizedString(@"Remixes", nil)];
             streamTableView.noContentTitle = NSLocalizedString(@"NoRemixersTitle", @"");
             streamTableView.noContentMessage = NSLocalizedString(@"NoRemixersMessage", @"");
             streamTableView.noContentImage = [UIImage imageNamed:@"noRemixIcon"];
             [self.navigationController pushViewController:[VStreamContainerViewController modalContainerForStreamTable:streamTableView] animated:YES];
             
         }];
    };
    VActionItem *repostItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Repost", @"") actionIcon:[UIImage imageNamed:@"repostIcon"] detailText:self.viewModel.repostCountText];
    repostItem.selectionHandler = ^(void)
    {
        [self dismissViewControllerAnimated:YES
                                 completion:^
        {
            if (![VObjectManager sharedManager].mainUser)
            {
                [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
                return;
            }
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                               onCancelButton:nil
                                                       destructiveButtonTitle:nil
                                                          onDestructiveButton:nil
                                                   otherButtonTitlesAndBlocks:NSLocalizedString(@"Repost", nil),  ^(void)
                                          {
                                              [[VObjectManager sharedManager] repostNode:self.viewModel.currentNode
                                                                                withName:nil
                                                                            successBlock:nil
                                                                               failBlock:nil];
                                          }, nil];
            
            [actionSheet showInView:self.view];
        }];
    };
    repostItem.detailSelectionHandler = ^(void)
    {
        [self dismissViewControllerAnimated:YES
                                 completion:^
        {
            VReposterTableViewController *vc = [[VReposterTableViewController alloc] init];
            vc.sequence = self.viewModel.sequence;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    };
    VActionItem *shareItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Share", @"") actionIcon:[UIImage imageNamed:@"shareIcon"] detailText:self.viewModel.shareCountText];

    void (^shareHandler)(void) = ^void(void)
    {
        //Remove the styling for the mail view.
        [[VThemeManager sharedThemeManager] removeStyling];
        
        VFacebookActivity *fbActivity = [[VFacebookActivity alloc] init];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.viewModel.sequence,
                                                                                                                     self.viewModel.shareText,
                                                                                                                     self.viewModel.shareURL]
                                                                                             applicationActivities:@[fbActivity]];
        
        NSString *emailSubject = [NSString stringWithFormat:NSLocalizedString(@"EmailShareSubjectFormat", nil), [[VThemeManager sharedThemeManager] themedStringForKey:kVChannelName]];
        [activityViewController setValue:emailSubject forKey:@"subject"];
        activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
        activityViewController.completionHandler = ^(NSString *activityType, BOOL completed)
        {
            [[VThemeManager sharedThemeManager] applyStyling];
            [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:[NSString stringWithFormat:@"Shared %@, via %@", self.viewModel.analyticsContentTypeText, activityType]
                                                                         action:nil
                                                                          label:nil
                                                                          value:nil];
            [self reloadInputViews];
        };
        [self resignFirstResponder];
        
        [self dismissViewControllerAnimated:YES
                                 completion:^
         {
             [self presentViewController:activityViewController
                                animated:YES
                              completion:nil];
         }];
    };
    shareItem.selectionHandler = shareHandler;
    shareItem.detailSelectionHandler = shareHandler;
    
    VActionItem *flagItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Report/Flag", @"")
                                                         actionIcon:[UIImage imageNamed:@"reportIcon"]
                                                         detailText:nil];
    flagItem.selectionHandler = ^(void)
    {
        [[VObjectManager sharedManager] flagSequence:self.viewModel.sequence
                                        successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
         {
             UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ReportedTitle", @"")
                                                                    message:NSLocalizedString(@"ReportContentMessage", @"")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                          otherButtonTitles:nil];
             [alert show];
             
         }
                                           failBlock:^(NSOperation *operation, NSError *error)
         {
             VLog(@"Failed to flag sequence %@", self.viewModel.sequence);
             
             UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WereSorry", @"")
                                                                    message:NSLocalizedString(@"ErrorOccured", @"")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                          otherButtonTitles:nil];
             [alert show];
         }];
    };
    
    [actionSheetViewController addActionItems:@[userItem, descripTionItem, remixItem, repostItem, shareItem, flagItem]];
    
    actionSheetViewController.cancelHandler = ^void(void)
    {
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    };
    
    [self presentViewController:actionSheetViewController
                       animated:YES
                     completion:nil];
}

#pragma mark - Private Mehods

- (NSIndexPath *)indexPathForContentView
{
    return [NSIndexPath indexPathForRow:0
                              inSection:VContentViewSectionContent];
}

- (void)configureCommentCell:(VContentCommentsCell *)commentCell
                   withIndex:(NSInteger)index
{
    commentCell.commentBody = [self.viewModel commentBodyForCommentIndex:index];
    commentCell.commenterName = [self.viewModel commenterNameForCommentIndex:index];
    commentCell.URLForCommenterAvatar = [self.viewModel commenterAvatarURLForCommentIndex:index];
    commentCell.timestampText = [self.viewModel commentTimeAgoTextForCommentIndex:index];
    commentCell.realTimeCommentText = [self.viewModel commentRealTimeCommentTextForCommentIndex:index];
    if ([self.viewModel commentHasMediaForCommentIndex:index])
    {
        commentCell.hasMedia = YES;
        commentCell.mediaPreviewURL = [self.viewModel commentMediaPreviewUrlForCommentIndex:index];
        commentCell.mediaIsVideo = [self.viewModel commentMediaIsVideoForCommentIndex:index];
    }
    
    __weak typeof(self) welf = self;
    __weak typeof(commentCell) wCommentCell = commentCell;
    commentCell.onMediaTapped = ^(void)
    {
        VLightboxViewController *lightbox;
        if (wCommentCell.mediaIsVideo)
        {
            lightbox = [[VVideoLightboxViewController alloc] initWithPreviewImage:wCommentCell.previewImage
                                                                         videoURL:[welf.viewModel mediaURLForCommentIndex:index]];
            
            ((VVideoLightboxViewController *)lightbox).onVideoFinished = lightbox.onCloseButtonTapped;
            ((VVideoLightboxViewController *)lightbox).titleForAnalytics = @"Video Realtime Comment";
        }
        else
        {
            lightbox = [[VImageLightboxViewController alloc] initWithImage:wCommentCell.previewImage];
        }
        
        lightbox.onCloseButtonTapped = ^(void)
        {
            [welf dismissViewControllerAnimated:YES completion:nil];
        };
        
        [VLightboxTransitioningDelegate addNewTransitioningDelegateToLightboxController:lightbox
                                                                          referenceView:wCommentCell.previewView];
        
        [welf presentViewController:lightbox
                           animated:YES
                         completion:nil];
    };
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    VContentViewSection vSection = section;
    switch (vSection)
    {
        case VContentViewSectionContent:
            return 1;
        case VContentViewSectionHistogram:
            return 1;
        case VContentViewSectionTicker:
            return 1;
        case VContentViewSectionAllComments:
            return self.viewModel.commentCount;
        case VContentViewSectionCount:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return VContentViewSectionCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VContentViewSection vSection = indexPath.section;
    switch (vSection)
    {
        case VContentViewSectionContent:
            switch (self.viewModel.type)
        {
            case VContentViewTypeInvalid:
                return nil;
            case VContentViewTypeImage:
            {
                VContentImageCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentImageCell suggestedReuseIdentifier]
                                                                                         forIndexPath:indexPath];
                [imageCell.contentImageView setImageWithURLRequest:self.viewModel.imageURLRequest
                                                  placeholderImage:nil
                                                           success:nil
                                                           failure:nil];
                return imageCell;
            }
            case VContentViewTypeVideo:
            {
                if (self.videoCell)
                {
                    return self.videoCell;
                }
                
                VContentVideoCell *videoCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentVideoCell suggestedReuseIdentifier]
                                                                                         forIndexPath:indexPath];
                videoCell.videoURL = self.viewModel.videoURL;
                videoCell.delegate = self;
                self.videoCell = videoCell;
                return videoCell;
            }
            case VContentViewTypePoll:
                return [collectionView dequeueReusableCellWithReuseIdentifier:[VContentCell suggestedReuseIdentifier]
                                                                 forIndexPath:indexPath];
        }
        case VContentViewSectionHistogram:
        {
            VContentImageCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentImageCell suggestedReuseIdentifier]
                                                                                     forIndexPath:indexPath];
            imageCell.contentView.backgroundColor = [UIColor blueColor];
            return imageCell;
        }
        case VContentViewSectionTicker:
        {
            if (self.realTimeComentsCell)
            {
                return self.realTimeComentsCell;
            }
            
            self.realTimeComentsCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VRealTimeCommentsCell suggestedReuseIdentifier]
                                                                                 forIndexPath:indexPath];
            self.realTimeComentsCell.dataSource = self;
            return self.realTimeComentsCell;
        }
        case VContentViewSectionAllComments:
        {
            VContentCommentsCell *commentCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentCommentsCell suggestedReuseIdentifier]
                                                                                          forIndexPath:indexPath];
            
            [self configureCommentCell:commentCell
                             withIndex:indexPath.row];
            
            return commentCell;
        }
        case VContentViewSectionCount:
            return nil;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    VContentViewSection vSection = indexPath.section;
    switch (vSection)
    {
        case VContentViewSectionContent:
        {
            return [collectionView dequeueReusableSupplementaryViewOfKind:VShrinkingContentLayoutContentBackgroundView
                                                      withReuseIdentifier:[VContentBackgroundSupplementaryView suggestedReuseIdentifier]
                                                             forIndexPath:indexPath];
        }
            
        case VContentViewSectionHistogram:
            return nil;
        case VContentViewSectionTicker:
            return nil;
        case VContentViewSectionAllComments:
        {
            if (!self.handleView)
            {
                VSectionHandleReusableView *handleView = (self.viewModel.commentCount == 0) ? nil : [collectionView dequeueReusableSupplementaryViewOfKind:VShrinkingContentLayoutAllCommentsHandle
                                                                                                                                       withReuseIdentifier:[VSectionHandleReusableView suggestedReuseIdentifier]
                                                                                                                                              forIndexPath:indexPath];
                self.handleView = handleView;
            }
            self.handleView.numberOfComments = self.viewModel.commentCount;
            
            return self.handleView;
        }
        case VContentViewSectionCount:
            return nil;
    }
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VContentViewSection vSection = indexPath.section;
    switch (vSection)
    {
        case VContentViewSectionContent:
        {
            if (self.videoSizeValue)
            {
                return [self.videoSizeValue CGSizeValue];
            }
            return [VContentCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
        }
        case VContentViewSectionHistogram:
            return CGSizeMake(CGRectGetWidth(self.contentCollectionView.bounds),
                              20.0f);
        case VContentViewSectionTicker:
        {
            return CGSizeMake(CGRectGetWidth(self.contentCollectionView.bounds),
                              50.0f);
            
        }
        case VContentViewSectionAllComments:
        {
            return [VContentCommentsCell sizeWithFullWidth:CGRectGetWidth(self.contentCollectionView.bounds)
                                               commentBody:[self.viewModel commentBodyForCommentIndex:indexPath.row]
                                               andHasMedia:[self.viewModel commentHasMediaForCommentIndex:indexPath.row]];
        }
            
        case VContentViewSectionCount:
            return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    VContentViewSection vSection = section;
    switch (vSection)
    {
        case VContentViewSectionContent:
            return CGSizeZero;
        case VContentViewSectionHistogram:
            return CGSizeZero;
        case VContentViewSectionTicker:
            return CGSizeZero;
        case VContentViewSectionAllComments:
        {
            CGSize allCommentsHandleSize = (self.viewModel.commentCount == 0) ? CGSizeZero :[VSectionHandleReusableView desiredSizeWithCollectionViewBounds:collectionView.bounds];
            ((VShrinkingContentLayout *)self.contentCollectionView.collectionViewLayout).allCommentsHandleBottomInset = allCommentsHandleSize.height;
            return allCommentsHandleSize;
        }
        case VContentViewSectionCount:
            return CGSizeZero;
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:[self indexPathForContentView]] == NSOrderedSame)
    {
        [self.contentCollectionView setContentOffset:CGPointMake(0, 0)
                                            animated:YES];
    }
}

#pragma mark - VContentVideoCellDelgetate

- (void)videoCell:(VContentVideoCell *)videoCell
    didPlayToTime:(CMTime)time
        totalTime:(CMTime)totalTime
{
    self.viewModel.realTimeCommentsViewModel.currentTime = time;
    
    CGFloat progressedTime = !isnan(CMTimeGetSeconds(time)/CMTimeGetSeconds(totalTime)) ? CMTimeGetSeconds(time)/CMTimeGetSeconds(totalTime) : 0.0f;
    [self.realTimeComentsCell setProgress:progressedTime];
    
    self.inputAccessoryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:time]];
    

    // configure current comment
    VRealtimeCommentsViewModel *realtimeCommentsViewModel = self.viewModel.realTimeCommentsViewModel;
    [self.realTimeComentsCell configureWithCurrentUserAvatarURL:realtimeCommentsViewModel.avatarURLForCurrentRealtimeComent
                                                currentUsername:realtimeCommentsViewModel.usernameForCurrentRealtimeComment
                                             currentTimeAgoText:realtimeCommentsViewModel.timeAgoTextForCurrentRealtimeComment
                                             currentCommentBody:realtimeCommentsViewModel.realTimeCommentBodyForCurrentRealTimeComent
                                                     atTimeText:realtimeCommentsViewModel.atRealtimeTextForCurrentRealTimeComment
                                     commentPercentThroughMedia:realtimeCommentsViewModel.percentThroughMediaForCurrentRealTimeComment];
}

- (void)videoCellReadyToPlay:(VContentVideoCell *)videoCell
{
    self.viewModel.realTimeCommentsViewModel.totalTime = self.videoCell.videoPlayerViewController.playerItemDuration;
    
    // should we update content size?
    CGSize desiredSizeForVideo = AVMakeRectWithAspectRatioInsideRect(videoCell.videoPlayerViewController.naturalSize, CGRectMake(0, 0, 320, 320)).size;
    if (!isnan(desiredSizeForVideo.width) && !isnan(desiredSizeForVideo.height))
    {
        if (desiredSizeForVideo.height > desiredSizeForVideo.width)
        {
            desiredSizeForVideo = CGSizeMake(CGRectGetWidth(self.contentCollectionView.bounds), CGRectGetWidth(self.contentCollectionView.bounds));
        }
        desiredSizeForVideo.width = CGRectGetWidth(self.contentCollectionView.bounds);
        self.videoSizeValue = [NSValue valueWithCGSize:desiredSizeForVideo];
    }
    
    [UIView animateWithDuration:0.0f
                     animations:^
     {
         [self.contentCollectionView.collectionViewLayout invalidateLayout];
     }];
}

- (void)videoCellPlayedToEnd:(VContentVideoCell *)videoCell
               withTotalTime:(CMTime)totalTime
{
    self.realTimeComentsCell.progress = 1.0f;
    self.inputAccessoryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:totalTime]];
}

#pragma mark - VRealtimeCommentsCellStripDataSource

- (NSInteger)numberOfAvatarsInStripForStripCell:(VRealTimeCommentsCell *)realtimeCommentsCell
{
    return self.viewModel.realTimeCommentsViewModel.numberOfRealTimeComments;
}

- (NSURL *)urlForAvatarImageAtIndex:(NSInteger)avatarIndex forAvatarCell:(VRealTimeCommentsCell *)realtimeCommentsCell
{
    return [self.viewModel.realTimeCommentsViewModel avatarURLForRealTimeCommentAtIndex:avatarIndex];
}

- (CGFloat)percentThroughVideoForAvatarAtIndex:(NSInteger)avatarIndex forAvatarCell:(VRealTimeCommentsCell *)realtimeCommentsCell
{
    return [self.viewModel.realTimeCommentsViewModel percentThroughMediaForRealTimeCommentAtIndex:avatarIndex];
}

#pragma mark - VRealtimeCommentsViewModelDelegate

- (void)currentCommentDidChangeOnRealtimeCommentsViewModel:(VRealtimeCommentsViewModel *)viewModel
{
    VRealtimeCommentsViewModel *realtimeCommentsViewModel = self.viewModel.realTimeCommentsViewModel;
    [self.realTimeComentsCell configureWithCurrentUserAvatarURL:realtimeCommentsViewModel.avatarURLForCurrentRealtimeComent
                                                currentUsername:realtimeCommentsViewModel.usernameForCurrentRealtimeComment
                                             currentTimeAgoText:realtimeCommentsViewModel.timeAgoTextForCurrentRealtimeComment
                                             currentCommentBody:realtimeCommentsViewModel.realTimeCommentBodyForCurrentRealTimeComent
                                                     atTimeText:realtimeCommentsViewModel.atRealtimeTextForCurrentRealTimeComment
                                     commentPercentThroughMedia:realtimeCommentsViewModel.percentThroughMediaForCurrentRealTimeComment];
}

- (void)realtimeCommentsViewModelDidLoadNewComments:(VRealtimeCommentsViewModel *)viewModel
{
    [UIView animateWithDuration:0.0f
                     animations:^
     {
         [self.contentCollectionView reloadData];
         [self.contentCollectionView.collectionViewLayout invalidateLayout];
     }];

    [self.contentCollectionView setContentOffset:CGPointMake(0, self.contentCollectionView.contentOffset.y +1) animated:YES];
}

- (void)realtimeCommentsReadyToLoadRTC:(VRealtimeCommentsViewModel *)viewModel
{
    [self.realTimeComentsCell reloadAvatarStrip];
}

#pragma mark - VKeyboardInputAccessoryViewDelegate

- (void)keyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inpoutAccessoryView
                         wantsSize:(CGSize)size
{
    self.inputAccessoryView.frame = CGRectMake(0, 0, size.width, size.height);
    [self.inputAccessoryView layoutIfNeeded];
}

- (void)pressedSendOnKeyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    __weak typeof(self) welf = self;
    [self.viewModel addCommentWithText:inputAccessoryView.composedText
                              mediaURL:self.mediaURL
                            completion:^(BOOL succeeded)
     {
         [welf.viewModel fetchComments];
         [UIView animateWithDuration:0.0f
                          animations:^
          {
              [welf.contentCollectionView reloadData];
              [welf.contentCollectionView.collectionViewLayout invalidateLayout];
          }];
     }];
    
    [inputAccessoryView clearTextAndResign];
    self.mediaURL = nil;
}

- (void)pressedAttachmentOnKeyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    VCameraViewController *cameraViewController = [VCameraViewController cameraViewController];
    cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (finished)
        {
            self.mediaURL = capturedMediaURL;
            [self.inputAccessoryView setSelectedThumbnail:previewImage];
        }
        [self dismissViewControllerAnimated:YES completion:^
        {
            [UIView animateWithDuration:0.0f
                             animations:^
             {
                 [self.contentCollectionView reloadData];
                 [self.contentCollectionView.collectionViewLayout invalidateLayout];
             }];
        }];
    };
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

@end
