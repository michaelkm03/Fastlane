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

// SubViews
#import "VExperienceEnhancerBar.h"
#import "VHistogramBarView.h"

// Images
#import "UIImage+ImageCreation.h"
#import "UIImageView+Blurring.h"

// Layout
#import "VShrinkingContentLayout.h"

// Cells
#import "VContentCell.h"
#import "VContentVideoCell.h"
#import "VContentImageCell.h"
#import "VContentPollCell.h"
#import "VContentPollQuestionCell.h"
#import "VContentPollBallotCell.h"
//#import "VTickerCell.h"
#import "VContentCommentsCell.h"
#import "VHistogramCell.h"
#import "VExperienceEnhancerBarCell.h"

// Supplementary Views
#import "VSectionHandleReusableView.h"
#import "VContentBackgroundSupplementaryView.h"

// Input Acceossry
#import "VKeyboardInputAccessoryView.h"

// ViewControllers
#import "VCameraViewController.h"
#import "VVideoLightboxViewController.h"
#import "VImageLightboxViewController.h"
#import "VUserProfileViewController.h"
#import "VAuthorizationViewControllerFactory.h"

// Transitioning
#import "VLightboxTransitioningDelegate.h"

// Logged in
#import "VObjectManager+Login.h"
#import "VLoginViewController.h"

// Formatters
#import "VElapsedTimeFormatter.h"

// Simple Models
#import "VExperienceEnhancer.h"

static const NSTimeInterval kRotationCompletionAnimationDuration = 0.45f;
static const CGFloat kRotationCompletionAnimationDamping = 1.0f;

@interface VNewContentViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate,VKeyboardInputAccessoryViewDelegate,VContentVideoCellDelgetate>

@property (nonatomic, strong, readwrite) VContentViewViewModel *viewModel;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, assign) BOOL hasAutoPlayed;
@property (nonatomic, strong) NSValue *videoSizeValue;

@property (nonatomic, weak) IBOutlet UICollectionView *contentCollectionView;
@property (nonatomic, weak) IBOutlet UIImageView *blurredBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIView *landscapeMaskOverlay;

// Cells
@property (nonatomic, weak) VContentCell *contentCell;
@property (nonatomic, weak) VContentVideoCell *videoCell;
@property (nonatomic, weak) VExperienceEnhancerBarCell *experienceEnhancerCell;
@property (nonatomic, weak) VSectionHandleReusableView *handleView;
@property (nonatomic, weak) VHistogramCell *histogramCell;
@property (nonatomic, weak) VContentPollCell *pollCell;
@property (nonatomic, weak) VContentPollBallotCell *ballotCell;

// Text input
@property (nonatomic, weak) VKeyboardInputAccessoryView *textEntryView;
@property (nonatomic, strong) VElapsedTimeFormatter *elapsedTimeFormatter;

// Constraints
@property (nonatomic, weak) NSLayoutConstraint *bottomExperienceEnhancerBarToContainerConstraint;
@property (nonatomic, weak) NSLayoutConstraint *bottomKeyboardToContainerBottomConstraint;
@property (nonatomic, weak) NSLayoutConstraint *keyboardInputBarHeightConstraint;

@property (nonatomic, assign) CGAffineTransform targetTransform;
@property (nonatomic, assign) CGRect oldRect;
@property (nonatomic, assign) CGAffineTransform videoTransform;

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

- (UIView *)inputAccessoryView
{
    VInputAccessoryView *_inputAccessoryView = nil;
    if (_inputAccessoryView)
    {
        return _inputAccessoryView;
    }
    
    _inputAccessoryView = [VInputAccessoryView new];
    
    return _inputAccessoryView;
}

#pragma mark - UIViewController
#pragma mark Rotation

- (BOOL)shouldAutorotate
{
    BOOL shouldRotate = ((self.viewModel.type == VContentViewTypeVideo) && (self.videoCell.videoPlayerViewController.player.status == AVPlayerStatusReadyToPlay) && !self.presentedViewController);
    return shouldRotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return (self.videoCell.videoPlayerViewController.player.status == AVPlayerStatusReadyToPlay) ? UIInterfaceOrientationMaskAllButUpsideDown : UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    CGAffineTransform transform = [coordinator targetTransform];
    if (CGAffineTransformIsIdentity(transform))
    {
        return;
    }
    UIInterfaceOrientation oldOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        {
            if (UIInterfaceOrientationIsLandscape(oldOrientation))
            {
                [coordinator containerView].transform = CGAffineTransformRotate(CGAffineTransformInvert([UIApplication sharedApplication].keyWindow.transform), M_PI);
                [self.view addSubview:self.videoCell.videoPlayerViewController.view];
                [self.view bringSubviewToFront:self.videoCell.videoPlayerViewController.view];

                return;
            }
            [coordinator containerView].transform = CGAffineTransformInvert([coordinator targetTransform]);
            [coordinator containerView].bounds = CGRectMake(0, 0, CGRectGetHeight([coordinator containerView].bounds), CGRectGetWidth([coordinator containerView].bounds));
            
            self.videoCell.videoPlayerViewController.view.transform = [coordinator targetTransform];
            self.videoCell.videoPlayerViewController.view.bounds = CGRectMake(0, 0, CGRectGetHeight([coordinator containerView].bounds), CGRectGetWidth([coordinator containerView].bounds));
            self.videoCell.videoPlayerViewController.view.center = self.view.center;
            [self.view addSubview:self.videoCell.videoPlayerViewController.view];
            self.landscapeMaskOverlay.alpha = 1.0f;
        }
        else
        {
            [coordinator containerView].transform = CGAffineTransformIdentity;
            [coordinator containerView].bounds = CGRectMake(0, 0, CGRectGetHeight([coordinator containerView].bounds), CGRectGetWidth([coordinator containerView].bounds));
            self.view.transform = CGAffineTransformIdentity;
            self.videoCell.videoPlayerViewController.view.transform = CGAffineTransformInvert([coordinator targetTransform]);
        }
    }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
        [self animateVideoPlayerToPortrait];
    }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIView *rootView = self.navigationController.view;
    CGAffineTransform oldTransform = rootView.transform;

    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        rootView.transform = CGAffineTransformIdentity;
        rootView.bounds = CGRectMake(0, 0, CGRectGetHeight(rootView.bounds), CGRectGetWidth(rootView.bounds));
        self.view.transform = CGAffineTransformIdentity;
        self.view.bounds = rootView.bounds;

        self.videoCell.videoPlayerViewController.view.transform = oldTransform;
        self.videoCell.videoPlayerViewController.view.bounds = CGRectMake(0, 0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds));
        self.videoCell.videoPlayerViewController.view.center = rootView.center;
        [self.view addSubview:self.videoCell.videoPlayerViewController.view];
        self.landscapeMaskOverlay.alpha = 1.0f;
    }
    else
    {
        self.view.transform = CGAffineTransformIdentity;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self animateVideoPlayerToPortrait];
}

- (void)animateVideoPlayerToPortrait
{
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        [UIView animateWithDuration:kRotationCompletionAnimationDuration
                              delay:0.0f
             usingSpringWithDamping:kRotationCompletionAnimationDamping
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^
         {

             self.videoCell.videoPlayerViewController.view.bounds = self.videoCell.contentView.bounds;//CGRectApplyAffineTransform(self.videoCell.contentView.bounds, self.videoCell.transform);
             self.videoCell.videoPlayerViewController.view.transform = self.videoCell.transform;
             self.videoCell.videoPlayerViewController.view.center = self.videoCell.contentView.center;
             
             self.landscapeMaskOverlay.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
             {
                 [self.videoCell.contentView addSubview:self.videoCell.videoPlayerViewController.view];
                 self.videoCell.videoPlayerViewController.view.transform = CGAffineTransformIdentity;
             }
         }];
    }
    [self.contentCollectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.contentCollectionView.collectionViewLayout = [[VShrinkingContentLayout alloc] init];
    self.contentCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    VKeyboardInputAccessoryView *inputAccessoryView = [VKeyboardInputAccessoryView defaultInputAccessoryView];
    inputAccessoryView.translatesAutoresizingMaskIntoConstraints = NO;
    inputAccessoryView.returnKeyType = UIReturnKeyDone;
    inputAccessoryView.delegate = self;
    self.textEntryView = inputAccessoryView;
    NSLayoutConstraint *inputViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:inputAccessoryView
                                                                                  attribute:NSLayoutAttributeLeading
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self.view
                                                                                  attribute:NSLayoutAttributeLeading
                                                                                 multiplier:1.0f
                                                                                   constant:0.0f];
    NSLayoutConstraint *inputViewTrailingconstraint = [NSLayoutConstraint constraintWithItem:inputAccessoryView
                                                                                   attribute:NSLayoutAttributeTrailing
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.view
                                                                                   attribute:NSLayoutAttributeTrailing
                                                                                  multiplier:1.0f
                                                                                    constant:0.0f];
    self.keyboardInputBarHeightConstraint = [NSLayoutConstraint constraintWithItem:inputAccessoryView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1.0f
                                                                          constant:VInputAccessoryViewDesiredMinimumHeight];
    self.bottomKeyboardToContainerBottomConstraint = [NSLayoutConstraint constraintWithItem:inputAccessoryView
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self.view
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1.0f
                                                                                   constant:0.0f];
    self.bottomKeyboardToContainerBottomConstraint.priority = UILayoutPriorityDefaultLow;
    [self.view insertSubview:inputAccessoryView
                belowSubview:self.landscapeMaskOverlay];
    [self.view addConstraints:@[self.keyboardInputBarHeightConstraint, inputViewLeadingConstraint, inputViewTrailingconstraint, self.bottomKeyboardToContainerBottomConstraint]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commentsDidUpdate:)
                                                 name:VContentViewViewModelDidUpdateCommentsNotification
                                               object:self.viewModel];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hitogramDataDidUpdate:)
                                                 name:VContentViewViewModelDidUpdateHistogramDataNotification
                                               object:self.viewModel];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pollDataDidUpdate:)
                                                 name:VContentViewViewModelDidUpdatePollDataNotification
                                               object:self.viewModel];
    
    self.contentCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    // Register nibs
    [self.contentCollectionView registerNib:[VContentCell nibForCell]
                 forCellWithReuseIdentifier:[VContentCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentVideoCell nibForCell]
                 forCellWithReuseIdentifier:[VContentVideoCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentImageCell nibForCell]
                 forCellWithReuseIdentifier:[VContentImageCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentCommentsCell nibForCell]
                 forCellWithReuseIdentifier:[VContentCommentsCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VHistogramCell nibForCell]
                 forCellWithReuseIdentifier:[VHistogramCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VExperienceEnhancerBarCell nibForCell]
                 forCellWithReuseIdentifier:[VExperienceEnhancerBarCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentPollCell nibForCell]
                 forCellWithReuseIdentifier:[VContentPollCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentPollQuestionCell nibForCell]
                 forCellWithReuseIdentifier:[VContentPollQuestionCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentPollBallotCell nibForCell]
                 forCellWithReuseIdentifier:[VContentPollBallotCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VSectionHandleReusableView nibForCell]
                 forSupplementaryViewOfKind:VShrinkingContentLayoutAllCommentsHandle
                        withReuseIdentifier:[VSectionHandleReusableView suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentBackgroundSupplementaryView nibForCell]
                 forSupplementaryViewOfKind:VShrinkingContentLayoutContentBackgroundView
                        withReuseIdentifier:[VContentBackgroundSupplementaryView suggestedReuseIdentifier]];
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:VInputAccessoryViewKeyboardFrameDidChangeNotification
                                               object:nil];
    
    [self.navigationController setNavigationBarHidden:YES
                                             animated:YES];
    
    self.contentCollectionView.delegate = self;
    
    [self.viewModel fetchComments];
    
    self.contentCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(VShrinkingContentLayoutMinimumContentHeight, 0, CGRectGetHeight(self.textEntryView.bounds), 0);
    self.contentCollectionView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.textEntryView.bounds) , 0);
    
    [self.blurredBackgroundImageView setBlurredImageWithClearImage:self.placeholderImage
                                                  placeholderImage:[UIImage resizeableImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]]
                                                         tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];

    if (self.viewModel.type == VContentViewTypeVideo)
    {
        self.textEntryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:self.videoCell.videoPlayerViewController.currentTime]];
    }
    else
    {
        self.textEntryView.placeholderText = NSLocalizedString(@"LaveAComment", @"");
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.contentCollectionView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.contentCollectionView.delegate = nil;
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(void (^)(void))completion
{
    [super presentViewController:viewControllerToPresent
                        animated:flag
                      completion:completion];
    
    // Pause playback on presentation
    [self.videoCell.videoPlayerViewController.player pause];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Notification Handlers

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
 
    if ([notification.name isEqualToString:VInputAccessoryViewKeyboardFrameDidChangeNotification])
    {
        CGFloat newBottomKeyboardBarToContainerConstraintHeight = 0.0f;
        if (!isnan(endFrame.origin.y) && !isinf(endFrame.origin.y))
        {
            newBottomKeyboardBarToContainerConstraintHeight = -CGRectGetHeight([UIScreen mainScreen].bounds) + endFrame.origin.y;// + offset;
        }
        
        self.bottomKeyboardToContainerBottomConstraint.constant = newBottomKeyboardBarToContainerConstraintHeight;
        [self.view layoutIfNeeded];
    }
    else if ([notification.name isEqualToString:UIKeyboardDidChangeFrameNotification])
    {
        VShrinkingContentLayout *layout = (VShrinkingContentLayout *)self.contentCollectionView.collectionViewLayout;
        CGFloat newBottomInset = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(endFrame) - layout.allCommentsHandleBottomInset + CGRectGetHeight(self.textEntryView.bounds);
        newBottomInset = (isnan(newBottomInset) || isinf(newBottomInset)) ? (CGRectGetHeight(self.textEntryView.bounds)) : newBottomInset;
        self.contentCollectionView.contentInset = UIEdgeInsetsMake(0, 0, newBottomInset, 0);
        self.contentCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, newBottomInset + layout.allCommentsHandleBottomInset, 0);
    }
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

- (void)hitogramDataDidUpdate:(NSNotification *)notification
{
    if (!self.viewModel.histogramDataSource)
    {
        return;
    }
    self.histogramCell.histogramView.dataSource = self.viewModel.histogramDataSource;
    [self.contentCollectionView.collectionViewLayout invalidateLayout];
}

- (void)pollDataDidUpdate:(NSNotification *)notification
{

    if (!self.viewModel.votingEnabled)
    {
        [self.pollCell setAnswerAPercentage:self.viewModel.answerAPercentage
                                   animated:YES];
        [self.pollCell setAnswerBPercentage:self.viewModel.answerBPercentage
                                   animated:YES];
        
        [self.ballotCell setVotingDisabledWithFavoredBallot:(self.viewModel.favoredAnswer == VPollAnswerA) ? VBallotA : VBallotB
                                                   animated:YES];
        self.pollCell.answerAIsFavored = (self.viewModel.favoredAnswer == VPollAnswerA);
        self.pollCell.answerBIsFavored = (self.viewModel.favoredAnswer == VPollAnswerB);
    }
}

#pragma mark - IBActions

- (IBAction)pressedClose:(id)sender
{
    [self.delegate newContentViewControllerDidClose:self];
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
    commentCell.onUserProfileTapped = ^(void)
    {
        VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:[self.viewModel userForCommentIndex:index]];
        [self.navigationController pushViewController:profileViewController animated:YES];
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
        case VContentViewSectionExperienceEnhancers:
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
                                                  placeholderImage:self.placeholderImage?:nil
                                                           success:nil
                                                           failure:nil];
                self.contentCell = imageCell;
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
                [videoCell.videoPlayerViewController enableTrackingWithTrackingItem:self.viewModel.sequence.tracking];
                videoCell.videoURL = self.viewModel.videoURL;
                videoCell.delegate = self;
                self.videoCell = videoCell;
                self.contentCell = videoCell;
                self.videoCell.videoPlayerViewController.animateWithPlayControls = ^void(BOOL playControlsHidden)
                {
                    self.moreButton.alpha = playControlsHidden ? 0.0f : 1.0f;
                    self.closeButton.alpha = playControlsHidden ? 0.0f : 1.0f;
                };
                return videoCell;
            }
            case VContentViewTypePoll:
            {
                VContentPollCell *pollCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentPollCell suggestedReuseIdentifier]
                                                                                       forIndexPath:indexPath];
                pollCell.answerAThumbnailMediaURL = self.viewModel.answerAThumbnailMediaURL;
                if (self.viewModel.answerAIsVideo)
                {
                    [pollCell setAnswerAIsVideowithVideoURL:self.viewModel.answerAVideoUrl];
                }
                pollCell.answerBThumbnailMediaURL = self.viewModel.answerBThumbnailMediaURL;
                if (self.viewModel.answerBIsVideo)
                {
                    [pollCell setAnswerBIsVideowithVideoURL:self.viewModel.answerBVideoUrl];
                }
                self.pollCell = pollCell;
                return pollCell;
            }
        }
        case VContentViewSectionHistogram:
        {
            if (self.viewModel.type == VContentViewTypePoll)
            {
                VContentPollQuestionCell *questionCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentPollQuestionCell suggestedReuseIdentifier]
                                                                 forIndexPath:indexPath];
                questionCell.question = self.viewModel.sequence.name;
                return questionCell;
            }
            
            if (self.histogramCell)
            {
                return self.histogramCell;
            }
            self.histogramCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VHistogramCell suggestedReuseIdentifier]
                                                                                     forIndexPath:indexPath];
            
            self.histogramCell.histogramView.dataSource = self.viewModel.histogramDataSource;
            [self.histogramCell.histogramView reloadData];
            
            return self.histogramCell;
        }
        case VContentViewSectionExperienceEnhancers:
        {
            if (self.viewModel.type == VContentViewTypePoll)
            {
                if (!self.ballotCell)
                {
                    self.ballotCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentPollBallotCell suggestedReuseIdentifier]
                                                                                forIndexPath:indexPath];
                }
                self.ballotCell.answerA = self.viewModel.answerALabelText;
                self.ballotCell.answerB = self.viewModel.answerBLabelText;
                
                self.ballotCell.answerASelectionHandler = ^(void)
                {
                    UIViewController *loginViewController = [VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]];
                    if (loginViewController)
                    {
                        [self presentViewController:loginViewController
                                           animated:YES
                                         completion:nil];
                        return;
                    }
                    
                    [self.viewModel answerPollWithAnswer:VPollAnswerA
                                              completion:^(BOOL succeeded, NSError *error)
                    {
                        [self.pollCell setAnswerAPercentage:self.viewModel.answerAPercentage
                                                   animated:YES];
                    }];
                };
                self.ballotCell.answerBSelectionHandler = ^(void)
                {
                    UIViewController *loginViewController = [VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]];
                    if (loginViewController)
                    {
                        [self presentViewController:loginViewController
                                           animated:YES
                                         completion:nil];
                        return;
                    }
                    
                    [self.viewModel answerPollWithAnswer:VPollAnswerB
                                              completion:^(BOOL succeeded, NSError *error)
                    {
                        [self.pollCell setAnswerBPercentage:self.viewModel.answerBPercentage
                                                   animated:YES];
                    }];
                };
                
                return self.ballotCell;
            }
            
            if (self.experienceEnhancerCell)
            {
                return self.experienceEnhancerCell;
            }
            
            self.experienceEnhancerCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VExperienceEnhancerBarCell suggestedReuseIdentifier]
                                                                                    forIndexPath:indexPath];
            self.viewModel.experienceEnhancerController.enhancerBar = self.experienceEnhancerCell.experienceEnhancerBar;
            
            __weak typeof(self) welf = self;
            self.experienceEnhancerCell.experienceEnhancerBar.selectionBlock = ^(VExperienceEnhancer *selectedEnhancer, CGPoint selectionCenter)
            {
                if (selectedEnhancer.isBallistic)
                {
                    UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 100.0f)];
                    animationImageView.contentMode = UIViewContentModeScaleAspectFit;
                    
                    CGPoint convertedCenterForAnimation = [self.experienceEnhancerCell.experienceEnhancerBar convertPoint:selectionCenter toView:self.view];
                    animationImageView.center = convertedCenterForAnimation;
                    animationImageView.image = selectedEnhancer.flightImage;
                    [welf.view addSubview:animationImageView];
                    
                    [UIView animateWithDuration:selectedEnhancer.flightDuration
                                          delay:0.0f
                                        options:UIViewAnimationOptionCurveLinear
                                     animations:^
                     {
                         CGFloat randomLocationX = fminf(fmaxf(arc4random_uniform(CGRectGetWidth(welf.contentCell.bounds)), (CGRectGetWidth(animationImageView.bounds) * 0.5f)), CGRectGetWidth(welf.contentCell.bounds) - (CGRectGetWidth(animationImageView.bounds) * 0.5f));
                         CGFloat randomLocationY = fminf(fmaxf(arc4random_uniform(CGRectGetHeight(welf.contentCell.bounds)), (CGRectGetHeight(animationImageView.bounds) * 0.5f)), CGRectGetHeight(welf.contentCell.bounds) - (CGRectGetHeight(animationImageView.bounds) * 0.5f));
                         
                         CGPoint contentCenter = [self.view convertPoint:CGPointMake(randomLocationX, randomLocationY)
                                                                fromView:welf.contentCell];
                         animationImageView.center = contentCenter;
                         
                     }
                                     completion:^(BOOL finished)
                     {
                         animationImageView.animationDuration = selectedEnhancer.animationDuration;
                         animationImageView.animationImages = selectedEnhancer.animationSequence;
                         animationImageView.animationRepeatCount = 1;
                         animationImageView.image = nil;
                         [animationImageView startAnimating];
                         
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(selectedEnhancer.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                                        {
                                            [animationImageView removeFromSuperview];
                                        });
                     }];
                }
                else // full overlay
                {
                    UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:welf.contentCell.bounds];
                    animationImageView.animationDuration = selectedEnhancer.animationDuration;
                    animationImageView.animationImages = selectedEnhancer.animationSequence;
                    animationImageView.animationRepeatCount = 1;
                    animationImageView.contentMode = selectedEnhancer.contentMode;
                    
                    [welf.contentCell.contentView addSubview:animationImageView];
                    [animationImageView startAnimating];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(selectedEnhancer.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                                   {
                                       [animationImageView removeFromSuperview];
                                   });
                }
            };
            
            return self.experienceEnhancerCell;
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
        case VContentViewSectionExperienceEnhancers:
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
            switch (self.viewModel.type)
            {
                case VContentViewTypeInvalid:
                    return CGSizeZero;
                case VContentViewTypeImage:
                    return [VContentImageCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
                case VContentViewTypeVideo:
                    return [VContentCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
                case VContentViewTypePoll:
                    return [VContentPollCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
            }
        }
        case VContentViewSectionHistogram:
            if (self.viewModel.type == VContentViewTypePoll)
            {
                return [VContentPollQuestionCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
            }
            if (!self.viewModel.histogramDataSource)
            {
                return CGSizeZero;
            }
            return [VHistogramCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
        case VContentViewSectionExperienceEnhancers:
        {
            if (self.viewModel.type == VContentViewTypePoll)
            {
                return [VContentPollBallotCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
            }
            if (self.viewModel.type == VContentViewTypePoll)
            {
                return CGSizeZero;
            }
            if ( self.viewModel.experienceEnhancerController.numberOfExperienceEnhancers == 0 )
            {
                return CGSizeZero;
            }
            return [VExperienceEnhancerBarCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
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
        case VContentViewSectionExperienceEnhancers:
            return CGSizeZero;
        case VContentViewSectionAllComments:
        {
            CGSize allCommentsHandleSize = (self.viewModel.commentCount == 0) ? CGSizeZero :[VSectionHandleReusableView desiredSizeWithCollectionViewBounds:collectionView.bounds];
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
    self.textEntryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:time]];
    self.histogramCell.histogramView.progress = CMTimeGetSeconds(time) / CMTimeGetSeconds(totalTime);
    self.viewModel.realTimeCommentsViewModel.currentTime = time;
}

- (void)videoCellReadyToPlay:(VContentVideoCell *)videoCell
{
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
     }completion:^(BOOL finished) {
         if (!self.hasAutoPlayed)
         {
             [self.videoCell play];
             self.hasAutoPlayed = YES;
         }
     }];
}

- (void)videoCellPlayedToEnd:(VContentVideoCell *)videoCell
               withTotalTime:(CMTime)totalTime
{
    self.textEntryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:totalTime]];
}

#pragma mark - VKeyboardInputAccessoryViewDelegate

- (void)keyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inpoutAccessoryView
                         wantsSize:(CGSize)size
{
    self.keyboardInputBarHeightConstraint.constant = size.height;
    [self.view layoutIfNeeded];
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
              [welf commentsDidUpdate:nil];
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
            [self.textEntryView setSelectedThumbnail:previewImage];
        }
        [self dismissViewControllerAnimated:YES completion:^
        {
            if (finished)
            {
                [self.textEntryView startEditing];
            }
            
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
