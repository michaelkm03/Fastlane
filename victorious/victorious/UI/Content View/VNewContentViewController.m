//
//  VNewContentViewController.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNewContentViewController.h"

// View Categories
#import "UIView+VShadows.h"

// Images
#import "UIImage+ImageCreation.h"
#import "UIImageView+Blurring.h"

// Layout
#import "VContentViewVideoLayout.h"
#import "VContentViewImageLayout.h"

// Cells
#import "VContentCell.h"
#import "VContentVideoCell.h"
#import "VContentImageCell.h"
#import "VRealTimeCommentsCell.h"
#import "VEmptyProgressView.h"
#import "VContentCommentsCell.h"

// Supplementary Views
#import "VSectionHandleReusableView.h"
#import "VDropdownTitleView.h"

// Input Acceossry
#import "VKeyboardInputAccessoryView.h"

// ViewControllers
#import "VCameraViewController.h"
#import "VVideoLightboxViewController.h"
#import "VImageLightboxViewController.h"

// Transitioning
#import "VLightboxTransitioningDelegate.h"

// Logged in
#import "VObjectManager+Login.h"
#import "VLoginViewController.h"

// Formatters
#import "VElapsedTimeFormatter.h"

typedef NS_ENUM(NSInteger, VContentViewSection)
{
    VContentViewSectionContent,
    VContentViewSectionRealTimeComments,
    VContentViewSectionAllComments,
    VContentViewSectionCount
};

@interface VNewContentViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, VKeyboardInputAccessoryViewDelegate, VContentVideoCellDelgetate, VRealtimeCommentsViewModelDelegate>

@property (nonatomic, strong, readwrite) VContentViewViewModel *viewModel;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, assign) BOOL hasAutoPlayed;

@property (nonatomic, weak) IBOutlet UICollectionView *contentCollectionView;
@property (nonatomic, weak) IBOutlet UIImageView *blurredBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (nonatomic, weak) VContentVideoCell *videoCell;
@property (nonatomic, weak) VRealTimeCommentsCell *realTimeComentsCell;
@property (nonatomic, weak) VEmptyProgressView *emptyRealTimeCommentsCell;
@property (nonatomic, weak) VSectionHandleReusableView *handleView;
@property (nonatomic, weak) VDropdownTitleView *dropdownHeaderView;

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
    
    switch (self.viewModel.type)
    {
        case VContentViewTypeInvalid:
        case VContentViewTypeImage:
        {
            VContentViewImageLayout *imageLayout = [[VContentViewImageLayout alloc] init];
            self.contentCollectionView.collectionViewLayout = imageLayout;
        }
            break;
        case VContentViewTypePoll:
            //
        case VContentViewTypeVideo:
            // do nothing assign in storyboard. Should fix this
            break;
    }
    
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
    [self.contentCollectionView registerNib:[VEmptyProgressView nibForCell]
                 forCellWithReuseIdentifier:[VEmptyProgressView suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentCommentsCell nibForCell]
                 forCellWithReuseIdentifier:[VContentCommentsCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VSectionHandleReusableView nibForCell]
                 forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                        withReuseIdentifier:[VSectionHandleReusableView suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VDropdownTitleView nibForCell]
                 forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                        withReuseIdentifier:[VDropdownTitleView suggestedReuseIdentifier]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commentsDidUpdate:)
                                                 name:VContentViewViewModelDidUpdateCommentsNotification
                                               object:self.viewModel];
    
    self.viewModel.realTimeCommentsViewModel.delegate = self;
    
    // There is a bug where input accessory view will go offscreen and not remain docked on first dismissal of the keyboard. This fixes that.
    [self becomeFirstResponder];
    [self resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    VContentViewVideoLayout *layout = (VContentViewVideoLayout *)self.contentCollectionView.collectionViewLayout;
    
    self.inputAccessoryView.maximumAllowedSize = CGSizeMake(CGRectGetWidth(self.view.frame),
                                                            CGRectGetHeight(self.view.frame) - CGRectGetHeight(endFrame) - layout.dropDownHeaderMiniumHeight + CGRectGetHeight(self.inputAccessoryView.frame));
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

#pragma mark - Convenience

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
        case VContentViewSectionRealTimeComments:
            return (self.viewModel.type == VContentViewTypeVideo) ? 1 : 0;
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
        case VContentViewSectionRealTimeComments:
        {
            if (self.viewModel.realTimeCommentsViewModel.numberOfRealTimeComments > 0)
            {
                if (self.realTimeComentsCell)
                {
                    return self.realTimeComentsCell;
                }
                
                self.realTimeComentsCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VRealTimeCommentsCell suggestedReuseIdentifier]
                                                                                     forIndexPath:indexPath];
                return self.realTimeComentsCell;
            }
            else
            {
                self.emptyRealTimeCommentsCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VEmptyProgressView suggestedReuseIdentifier]
                                                                 forIndexPath:indexPath];
                return self.emptyRealTimeCommentsCell;
            }
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
            VDropdownTitleView *titleView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                               withReuseIdentifier:[VDropdownTitleView suggestedReuseIdentifier]
                                                                                      forIndexPath:indexPath];
            titleView.titleText = self.viewModel.name;
            self.dropdownHeaderView = titleView;
            return titleView;
        }
            
        case VContentViewSectionRealTimeComments:
            return nil;
        case VContentViewSectionAllComments:
        {
            if (!self.handleView)
            {
                VSectionHandleReusableView *handleView = (self.viewModel.commentCount == 0) ? nil : [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
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
            return [VContentCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
        case VContentViewSectionRealTimeComments:
            if (self.viewModel.realTimeCommentsViewModel.numberOfRealTimeComments > 0)
            {
                CGSize realTimeCommentsSize = [VRealTimeCommentsCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
                VContentViewVideoLayout *videoLayout = ((VContentViewVideoLayout *)self.contentCollectionView.collectionViewLayout);
                [videoLayout setSizeForRealTimeComentsView:realTimeCommentsSize];
                [videoLayout setCatchPoint:realTimeCommentsSize.height];
                
                return realTimeCommentsSize;
            }
            else
            {
                return [VEmptyProgressView desiredSizeWithCollectionViewBounds:collectionView.bounds];
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
        case VContentViewSectionRealTimeComments:
            return CGSizeZero;
        case VContentViewSectionAllComments:
            return (self.viewModel.commentCount == 0) ? CGSizeZero : [VSectionHandleReusableView desiredSizeWithCollectionViewBounds:collectionView.bounds];
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

#pragma mark UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSDictionary *lastDesiredContentOffset = [[((VContentViewBaseLayout *)self.contentCollectionView.collectionViewLayout) desiredDecelerationLocations] lastObject];
    CGFloat fullContentOffset = [lastDesiredContentOffset[VContentViewBaseLayoutDecelerationLocationDesiredContentOffset] CGPointValue].y;
    
    CGFloat headerProgress = self.contentCollectionView.contentOffset.y / fullContentOffset;
    self.dropdownHeaderView.label.alpha = headerProgress;
    self.dropdownHeaderView.label.transform = CGAffineTransformMakeTranslation(0, -20 * (1-headerProgress));
    if (self.contentCollectionView.contentOffset.y > fullContentOffset)
    {
        self.dropdownHeaderView.label.alpha = 1.0f;
        self.dropdownHeaderView.label.transform = CGAffineTransformIdentity;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    __block void (^delayedContentOffsetBlock)(void);
    
    NSArray *desiredContentOffsets = [((VContentViewBaseLayout *)self.contentCollectionView.collectionViewLayout) desiredDecelerationLocations];
    
    [desiredContentOffsets enumerateObjectsUsingBlock:^(NSDictionary *desiredOffsetLocation, NSUInteger idx, BOOL *stop)
    {
        CGPoint desiredContentOffset = [desiredOffsetLocation[VContentViewBaseLayoutDecelerationLocationDesiredContentOffset] CGPointValue];
        CGFloat desiredContentOffsetThresholdAbove = [desiredOffsetLocation[VContentViewBaseLayoutDecelerationLocationThresholdAbove] floatValue];
        CGFloat desiredContentOffsetTresholdBelow = [desiredOffsetLocation[VContentViewBaseLayoutDecelerationLocationThresholdBelow] floatValue];
        if ((targetContentOffset->y <= (desiredContentOffset.y + desiredContentOffsetThresholdAbove)) && (targetContentOffset->y >= (desiredContentOffset.y - desiredContentOffsetTresholdBelow)))
        {
            if (((desiredContentOffset.y < targetContentOffset->y) && (velocity.y > 0.0f)) ||
                ((desiredContentOffset.y > targetContentOffset->y) && (velocity.y < 0.0f)))
            {
                delayedContentOffsetBlock = ^void(void)
                {
                    [scrollView setContentOffset:desiredContentOffset
                                        animated:YES];
                };
            }
            else
            {
                *targetContentOffset = desiredContentOffset;
            }
            
            *stop = YES;
        }
    }];
    
    if (delayedContentOffsetBlock)
    {
        // This is done to prevent cases where merely setting targetContentOffset lead to jumpy scrolling
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            delayedContentOffsetBlock();
        });
    }
}

#pragma mark - VContentVideoCellDelgetate

- (void)videoCell:(VContentVideoCell *)videoCell
    didPlayToTime:(CMTime)time
        totalTime:(CMTime)totalTime
{
    self.viewModel.realTimeCommentsViewModel.currentTime = time;
    self.viewModel.realTimeCommentsViewModel.totalTime = totalTime;
    
    CGFloat progressedTime = !isnan(CMTimeGetSeconds(time)/CMTimeGetSeconds(totalTime)) ? CMTimeGetSeconds(time)/CMTimeGetSeconds(totalTime) : 0.0f;
    [self.emptyRealTimeCommentsCell setProgress: progressedTime];
    [self.realTimeComentsCell setProgress:progressedTime];
    
    self.inputAccessoryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:time]];
}

- (void)videoCellReadyToPlay:(VContentVideoCell *)videoCell
{
    self.viewModel.realTimeCommentsViewModel.totalTime = self.videoCell.videoPlayerViewController.playerItemDuration;
    
    [self.realTimeComentsCell clearAvatarStrip];
    
    for (NSInteger realtimeCommentIndex = 0; realtimeCommentIndex < self.viewModel.realTimeCommentsViewModel.numberOfRealTimeComments-1; realtimeCommentIndex++)
    {
        VRealtimeCommentsViewModel *realtimeCommentsViewModel = self.viewModel.realTimeCommentsViewModel;
        realtimeCommentsViewModel.totalTime = self.videoCell.videoPlayerViewController.playerItemDuration;
        [self.realTimeComentsCell addAvatarWithURL:[realtimeCommentsViewModel avatarURLForRealTimeCommentAtIndex:realtimeCommentIndex]
                               withPercentLocation:[realtimeCommentsViewModel percentThroughMediaForRealTimeCommentAtIndex:realtimeCommentIndex]];
    }
}

- (void)videoCellPlayedToEnd:(VContentVideoCell *)videoCell
               withTotalTime:(CMTime)totalTime
{
    self.viewModel.realTimeCommentsViewModel.currentTime = totalTime;
    self.viewModel.realTimeCommentsViewModel.totalTime = totalTime;
    
    self.emptyRealTimeCommentsCell.progress = 1.0f;
    self.realTimeComentsCell.progress = 1.0f;
    
    self.inputAccessoryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:totalTime]];
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

    [UIView animateWithDuration:0.5f
                     animations:^{
                             [self.contentCollectionView.collectionViewLayout invalidateLayout];
                     }];

    [self.contentCollectionView setContentOffset:CGPointZero animated:YES];
}

- (void)realtimeCommentsViewModelDidLoadNewComments:(VRealtimeCommentsViewModel *)viewModel
{
    [self.contentCollectionView reloadData];
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [self.contentCollectionView.collectionViewLayout invalidateLayout];
                     }];

    [self.contentCollectionView setContentOffset:CGPointZero animated:YES];


//
//    [self.realTimeComentsCell clearAvatarStrip];
//    
//    for (NSInteger realtimeCommentIndex = 0; realtimeCommentIndex < self.viewModel.realTimeCommentsViewModel.numberOfRealTimeComments-1; realtimeCommentIndex++)
//    {
//        VRealtimeCommentsViewModel *realtimeCommentsViewModel = self.viewModel.realTimeCommentsViewModel;
//        realtimeCommentsViewModel.totalTime = self.videoCell.videoPlayerViewController.playerItemDuration;
//        [self.realTimeComentsCell addAvatarWithURL:[realtimeCommentsViewModel avatarURLForRealTimeCommentAtIndex:realtimeCommentIndex]
//                               withPercentLocation:[realtimeCommentsViewModel percentThroughMediaForRealTimeCommentAtIndex:realtimeCommentIndex]];
//    }
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
         [welf.contentCollectionView reloadData];
         [welf.contentCollectionView.collectionViewLayout invalidateLayout];
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
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

@end
