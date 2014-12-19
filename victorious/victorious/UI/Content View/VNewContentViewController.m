//
//  VNewContentViewController.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNewContentViewController.h"
#import "VObjectManager+ContentCreation.h"

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

// Input Accessory
#import "VKeyboardInputAccessoryView.h"
#import "UIActionSheet+VBlocks.h"

// ViewControllers
#import "VCameraViewController.h"
#import "VVideoLightboxViewController.h"
#import "VImageLightboxViewController.h"
#import "VUserProfileViewController.h"
#import "VAuthorizationViewControllerFactory.h"
#import "VPurchaseViewController.h"

// Transitioning
#import "VLightboxTransitioningDelegate.h"

// Logged in
#import "VObjectManager+Login.h"
#import "VLoginViewController.h"

// Formatters
#import "VElapsedTimeFormatter.h"
#import "VComment+Fetcher.h"

// Simple Models
#import "VExperienceEnhancer.h"

// Experiments
#import "VSettingManager.h"

#import "VCameraPublishViewController.h"

#import "VSequence+Fetcher.h"

#import "VViewControllerTransition.h"

#import "VTracking.h"

static const CGFloat kMaxInputBarHeight = 200.0f;

@interface VNewContentViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate,VKeyboardInputAccessoryViewDelegate,VContentVideoCellDelegate, VExperienceEnhancerControllerDelegate>

@property (nonatomic, strong, readwrite) VContentViewViewModel *viewModel;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, assign) BOOL hasAutoPlayed;

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
@property (nonatomic, weak) NSLayoutConstraint *bottomKeyboardToContainerBottomConstraint;
@property (nonatomic, weak) NSLayoutConstraint *keyboardInputBarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingCollectionViewToContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingCollectionViewToContainer;

@property (nonatomic, assign) CGAffineTransform targetTransform;
@property (nonatomic, assign) CGRect oldRect;
@property (nonatomic, assign) CGAffineTransform videoTransform;

// RTC
@property (nonatomic, assign) BOOL enteringRealTimeComment;
@property (nonatomic, assign) CMTime realtimeCommentBeganTime;

@property (nonatomic, strong) VViewControllerTransition *transitionDelegate;

@end

@implementation VNewContentViewController

#pragma mark - Factory Methods

+ (VNewContentViewController *)contentViewControllerWithViewModel:(VContentViewViewModel *)viewModel
{
    VNewContentViewController *contentViewController = [[UIStoryboard storyboardWithName:@"ContentView" bundle:nil] instantiateInitialViewController];
    contentViewController.viewModel = viewModel;
    contentViewController.hasAutoPlayed = NO;
    contentViewController.transitionDelegate = [[VViewControllerTransition alloc] init];
    contentViewController.elapsedTimeFormatter = [[VElapsedTimeFormatter alloc] init];
    
    return contentViewController;
}

#pragma mark - Dealloc

- (void)dealloc
{
    [VContentCommentsCell clearSharedImageCache];
    
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
    BOOL shouldRotate = ((self.viewModel.type == VContentViewTypeVideo) && (self.videoCell.status == AVPlayerStatusReadyToPlay) && !self.presentedViewController && !self.videoCell.isPlayingAd);
    return shouldRotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    BOOL isVideoAndReadyToPlay = (self.viewModel.type == VContentViewTypeVideo) &&  (self.videoCell.status == AVPlayerStatusReadyToPlay);
    return (isVideoAndReadyToPlay) ? UIInterfaceOrientationMaskAllButUpsideDown : UIInterfaceOrientationMaskPortrait;
}

#pragma mark iOS8.0+

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self alongsideRotationupdates];
     }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self finishedRotationUpdates];
     }];
}

#pragma mark iOS7.1+

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self alongsideRotationupdates];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self finishedRotationUpdates];
}

#pragma mark Shared

- (void)alongsideRotationupdates
{
    [self.inputAccessoryView endEditing:YES];
    
    if (self.presentedViewController)
    {
        return;
    }
    
    self.landscapeMaskOverlay.alpha = (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) ? 1.0f : 0.0f;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        [self.view addSubview:self.videoCell.videoPlayerContainer];
        [self.view bringSubviewToFront:self.closeButton];
        self.videoCell.videoPlayerContainer.frame = self.view.bounds;
    }
    else
    {
        [self.videoCell togglePlayControls];
        self.videoCell.videoPlayerContainer.frame = self.videoCell.bounds;
        self.videoCell.videoPlayerContainer.transform = self.videoCell.transform;
    }
}

- (void)finishedRotationUpdates
{
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        self.videoCell.videoPlayerContainer.transform = CGAffineTransformIdentity;
        [self.videoCell.contentView addSubview:self.videoCell.videoPlayerContainer];
        [self.contentCollectionView.collectionViewLayout invalidateLayout];
    }
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Hack to remove margins stuff should probably refactor :(
    if ([self.view respondsToSelector:@selector(setLayoutMargins:)])
    {
        self.view.layoutMargins = UIEdgeInsetsZero;
    }
    else
    {
        self.leadingCollectionViewToContainer.constant = 0.0f;
        self.trailingCollectionViewToContainer.constant = 0.0f;
    }
    
    self.contentCollectionView.collectionViewLayout = [[VShrinkingContentLayout alloc] init];
    self.contentCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.viewModel.sequence.canComment)
    {
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
    }
    
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
                 forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                        withReuseIdentifier:[VSectionHandleReusableView suggestedReuseIdentifier]];
    [self.contentCollectionView.collectionViewLayout registerNib:[VContentBackgroundSupplementaryView nibForCell]
                                         forDecorationViewOfKind:VShrinkingContentLayoutContentBackgroundView];
    
    self.viewModel.experienceEnhancerController.delegate = self;
    
    NSDictionary *params = @{ VTrackingKeyTimeCurrent : [NSDate date],
                              VTrackingKeySequenceId : self.viewModel.sequence.remoteId,
                              VTrackingKeyUrls : self.viewModel.sequence.tracking.viewStart ?: @[] };
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventViewDidStart parameters:params];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentDataDidUpdate:)
                                                 name:VContentViewViewModelDidUpdateContentNotification
                                               object:self.viewModel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:VInputAccessoryViewKeyboardFrameDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStatusDidChange:)
                                                 name:kLoggedInChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLoginViewController:)
                                                 name:VExperienceEnhancerBarDidRequireLoginNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showPurchaseViewController:)
                                                 name:VExperienceEnhancerBarDidRequirePurchasePrompt
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRemixPublished:)
                                                 name:VCameraPublishViewControllerDidPublishNotification
                                               object:nil];
    
    [self.navigationController setNavigationBarHidden:YES
                                             animated:YES];
    
    self.contentCollectionView.delegate = self;
    self.videoCell.delegate = self;
    
    self.contentCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(VShrinkingContentLayoutMinimumContentHeight, 0, CGRectGetHeight(self.textEntryView.bounds), 0);
    self.contentCollectionView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.textEntryView.bounds) , 0);
    
    [self.blurredBackgroundImageView setBlurredImageWithClearImage:self.placeholderImage
                                                  placeholderImage:[UIImage resizeableImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]]
                                                         tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];

    if (self.viewModel.type == VContentViewTypeVideo)
    {
        self.textEntryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:self.videoCell.currentTime]];
    }
    else
    {
        self.textEntryView.placeholderText = NSLocalizedString(@"LeaveAComment", @"");
    }
    
    [self.viewModel reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.contentCollectionView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // We don't care about these notifications anymore but we still care about new user loggedin
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VContentViewViewModelDidUpdateCommentsNotification
                                                  object:self.viewModel];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VContentViewViewModelDidUpdateHistogramDataNotification
                                                  object:self.viewModel];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VContentViewViewModelDidUpdatePollDataNotification
                                                  object:self.viewModel];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidChangeFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VInputAccessoryViewKeyboardFrameDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VExperienceEnhancerBarDidRequirePurchasePrompt
                                                  object:nil];
    
    self.contentCollectionView.delegate = nil;
    self.videoCell.delegate = nil;
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(void (^)(void))completion
{
    [super presentViewController:viewControllerToPresent
                        animated:flag
                      completion:completion];
    
    // Pause playback on presentation
    [self.videoCell pause];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Notification Handlers

- (void)showPurchaseViewController:(NSNotification *)notification
{
    if ( notification.userInfo == nil )
    {
        return;
    }
    
    VExperienceEnhancer *experienceEnhander = (VExperienceEnhancer *)notification.userInfo[ @"experienceEnhancer" ];
    if ( experienceEnhander == nil )
    {
        return;
    }
    
    VPurchaseViewController *viewController = [VPurchaseViewController purchaseViewControllerWithVoteType:experienceEnhander.voteType];
    viewController.transitioningDelegate = self.transitionDelegate;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)showLoginViewController:(NSNotification *)notification
{
    UIViewController *loginViewController = [VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]];
    if (loginViewController)
    {
        [self presentViewController:loginViewController
                           animated:YES
                         completion:nil];
    }
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
}

- (void)contentDataDidUpdate:(NSNotification *)notification
{
    self.videoCell.viewModel = self.viewModel.videoViewModel;
}

- (void)commentsDidUpdate:(NSNotification *)notification
{
    if (self.viewModel.comments.count > 0)
    {
        if ([self.contentCollectionView numberOfItemsInSection:VContentViewSectionAllComments] > 0)
        {
            [self.contentCollectionView reloadData];
            
            __weak typeof(self) welf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
            {
                [welf.contentCollectionView flashScrollIndicators];
            });
        }
        else
        {
            NSIndexSet *commentsIndexSet = [NSIndexSet indexSetWithIndex:VContentViewSectionAllComments];
            [self.contentCollectionView reloadSections:commentsIndexSet];
        }
        
        self.handleView.numberOfComments = self.viewModel.sequence.commentCount.integerValue;
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
        self.pollCell.numberOfVotersText = self.viewModel.numberOfVotersText;
    }
}

- (void)loginStatusDidChange:(NSNotification *)notification
{
    [self.viewModel reloadData];
}

- (void)onRemixPublished:(NSNotification *)notification
{
    // Dismiss the content view and return to stream
    [self.delegate newContentViewControllerDidClose:self];
}

#pragma mark - IBActions

- (IBAction)pressedClose:(id)sender
{
    // Sometimes UICollecitonView hangs gets stuck in infinite loops while we are dismissing slowing the UI down to a crawl, by replacing it with a snapshot of the current UI we don't risk this happening.
    [self.view addSubview:[self.view snapshotViewAfterScreenUpdates:NO]];
    self.contentCollectionView.delegate = nil;
    self.videoCell.delegate = nil;
    [self.contentCollectionView removeFromSuperview];
    [self.delegate newContentViewControllerDidClose:self];
}

#pragma mark - Private Mehods

- (void)updateInitialExperienceEnhancerState
{
   /**
    When the enhancer bar is initialized and if a video cell is initialized (meaning the asset is a video),
    set the initial enhancer bar state as disabled.  It will become enabled when the video asset starts playing.
    This may happen right away if there is no ad, or after any ad is finished playing.
    */
    VExperienceEnhancerBar *enhancerBar = self.viewModel.experienceEnhancerController.enhancerBar;
    if ( enhancerBar != nil && self.videoCell != nil )
    {
        self.viewModel.experienceEnhancerController.enhancerBar.enabled = NO;
    }
}

- (NSIndexPath *)indexPathForContentView
{
    return [NSIndexPath indexPathForRow:0
                              inSection:VContentViewSectionContent];
}

- (void)configureCommentCell:(VContentCommentsCell *)commentCell
                   withIndex:(NSInteger)index
{
    commentCell.comment = self.viewModel.comments[index];
    
    __weak typeof(commentCell) wCommentCell = commentCell;
    __weak typeof(self) welf = self;
    commentCell.onMediaTapped = ^(void)
    {
        [welf showLightBoxWithMediaURL:wCommentCell.mediaURL
                          previewImage:wCommentCell.previewImage
                               isVideo:wCommentCell.mediaIsVideo
                            sourceView:wCommentCell.previewView];
    };
    commentCell.onUserProfileTapped = ^(void)
    {
        VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:wCommentCell.comment.user];
        [welf.navigationController pushViewController:profileViewController animated:YES];
    };
}

- (void)showLightBoxWithMediaURL:(NSURL *)mediaURL
                    previewImage:(UIImage *)previewImage
                         isVideo:(BOOL)isVideo
                      sourceView:(UIView *)sourceView
{
    __weak typeof(self) welf = self;
    VLightboxViewController *lightbox;
    if (isVideo)
    {
        lightbox = [[VVideoLightboxViewController alloc] initWithPreviewImage:previewImage
                                                                     videoURL:mediaURL];
        ((VVideoLightboxViewController *)lightbox).titleForAnalytics = @"Video Realtime Comment";
    }
    else
    {
        lightbox = [[VImageLightboxViewController alloc] initWithImage:previewImage];
    }
    __weak typeof(lightbox) weakLightBox = lightbox;
    lightbox.onCloseButtonTapped = ^(void)
    {
        if (welf.presentedViewController == weakLightBox)
        {
            [welf dismissViewControllerAnimated:YES
                                     completion:^
             {
                 [welf.contentCollectionView.collectionViewLayout invalidateLayout];
             }];
        }
    };
    if ([lightbox isKindOfClass:[VVideoLightboxViewController class]])
    {
        ((VVideoLightboxViewController *) lightbox).onVideoFinished = lightbox.onCloseButtonTapped;
    }
    
    [VLightboxTransitioningDelegate addNewTransitioningDelegateToLightboxController:lightbox
                                                                      referenceView:sourceView];
    
    [welf presentViewController:lightbox
                       animated:YES
                     completion:nil];
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
        case VContentViewSectionHistogramOrQuestion:
        {
            NSInteger ret = (self.viewModel.type == VContentViewTypePoll) ? 1 : 0;
            return ret;
        }
            
        case VContentViewSectionExperienceEnhancers:
            return 1;
        case VContentViewSectionAllComments:
            return (NSInteger)self.viewModel.comments.count;
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
                [videoCell setTracking:self.viewModel.sequence.tracking];
                videoCell.delegate = self;
                videoCell.speed = self.viewModel.speed;
                videoCell.loop = self.viewModel.loop;
                self.videoCell = videoCell;
                self.contentCell = videoCell;
                __weak typeof(self) welf = self;
                [self.videoCell setAnimateAlongsizePlayControlsBlock:^(BOOL playControlsHidden)
                {
                    welf.moreButton.alpha = playControlsHidden ? 0.0f : 1.0f;
                    welf.closeButton.alpha = playControlsHidden ? 0.0f : 1.0f;
                }];
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
                __weak typeof(pollCell) weakPollCell = pollCell;
                __weak typeof(self) welf = self;
                
                pollCell.onAnswerASelection = ^void(BOOL isVideo, NSURL *mediaURL)
                {
                    [welf showLightBoxWithMediaURL:mediaURL
                                      previewImage:weakPollCell.answerAPreviewImage
                                           isVideo:isVideo
                                        sourceView:weakPollCell.answerAContainer];
                };
                pollCell.onAnswerBSelection = ^void(BOOL isVideo, NSURL *mediaURL)
                {
                    [welf showLightBoxWithMediaURL:mediaURL
                                      previewImage:weakPollCell.answerBPreviewImage
                                           isVideo:isVideo
                                        sourceView:weakPollCell.answerBContainer];
                };
                
                self.pollCell = pollCell;
                return pollCell;
            }
        }
        case VContentViewSectionHistogramOrQuestion:
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
                
                __weak typeof(self) welf = self;
                self.ballotCell.answerASelectionHandler = ^(void)
                {
                    UIViewController *loginViewController = [VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]];
                    if (loginViewController)
                    {
                        [welf presentViewController:loginViewController
                                           animated:YES
                                         completion:nil];
                        return;
                    }
                    
                    [welf.viewModel answerPollWithAnswer:VPollAnswerA
                                              completion:^(BOOL succeeded, NSError *error)
                    {
                        [welf.pollCell setAnswerAPercentage:welf.viewModel.answerAPercentage
                                                   animated:YES];
                    }];
                };
                self.ballotCell.answerBSelectionHandler = ^(void)
                {
                    UIViewController *loginViewController = [VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]];
                    if (loginViewController)
                    {
                        [welf presentViewController:loginViewController
                                           animated:YES
                                         completion:nil];
                        return;
                    }
                    
                    [welf.viewModel answerPollWithAnswer:VPollAnswerB
                                              completion:^(BOOL succeeded, NSError *error)
                    {
                        [welf.pollCell setAnswerBPercentage:welf.viewModel.answerBPercentage
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
            
            [self updateInitialExperienceEnhancerState];
            
            __weak typeof(self) welf = self;
            self.experienceEnhancerCell.experienceEnhancerBar.selectionBlock = ^(VExperienceEnhancer *selectedEnhancer, CGPoint selectionCenter)
            {
                if (selectedEnhancer.isBallistic)
                {
                    UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 100.0f)];
                    animationImageView.contentMode = UIViewContentModeScaleAspectFit;
                    
                    CGPoint convertedCenterForAnimation = [welf.experienceEnhancerCell.experienceEnhancerBar convertPoint:selectionCenter toView:welf.view];
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
                         
                         CGPoint contentCenter = [welf.view convertPoint:CGPointMake(randomLocationX, randomLocationY)
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
            
        case VContentViewSectionHistogramOrQuestion:
            return nil;
        case VContentViewSectionExperienceEnhancers:
            return nil;
        case VContentViewSectionAllComments:
        {
            if (!self.handleView)
            {
                VSectionHandleReusableView *handleView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                            withReuseIdentifier:[VSectionHandleReusableView suggestedReuseIdentifier]
                                                                                                   forIndexPath:indexPath];
                self.handleView = handleView;
            }
            self.handleView.numberOfComments = self.viewModel.sequence.commentCount.integerValue;
            
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
            switch (self.viewModel.type)
            {
                case VContentViewTypeInvalid:
                    return CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds));
                case VContentViewTypeImage:
                    return [VContentImageCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
                case VContentViewTypeVideo:
                    return [VContentVideoCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
                case VContentViewTypePoll:
                    return [VContentPollCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
            }
        }
        case VContentViewSectionHistogramOrQuestion:
            if (self.viewModel.type == VContentViewTypePoll)
            {
                CGSize ret = [VContentPollQuestionCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
                return  ret;
            }
            return [VHistogramCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
        case VContentViewSectionExperienceEnhancers:
        {
            if (self.viewModel.type == VContentViewTypePoll)
            {
                return [VContentPollBallotCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
            }
            return [VExperienceEnhancerBarCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
        }
        case VContentViewSectionAllComments:
        {
            VComment *comment = self.viewModel.comments[indexPath.row];
            return [VContentCommentsCell sizeWithFullWidth:CGRectGetWidth(self.contentCollectionView.bounds)
                                               commentBody:comment.text
                                               andHasMedia:comment.hasMedia];
        }
        case VContentViewSectionCount:
            return CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds));
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
        case VContentViewSectionHistogramOrQuestion:
            return CGSizeZero;
        case VContentViewSectionExperienceEnhancers:
            return CGSizeZero;
        case VContentViewSectionAllComments:
        {
            return (self.viewModel.comments.count > 0) ? [VSectionHandleReusableView desiredSizeWithCollectionViewBounds:collectionView.bounds] : CGSizeZero;
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

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (CGRectGetMidY(scrollView.bounds) > (scrollView.contentSize.height * 0.8f))
    {
        [self.viewModel attemptToLoadNextPageOfComments];
    }
}

#pragma mark - VContentVideoCellDelegate

- (void)videoCell:(VContentVideoCell *)videoCell
    didPlayToTime:(CMTime)time
        totalTime:(CMTime)totalTime
{
    if (!self.enteringRealTimeComment)
    {
        self.textEntryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:time]];
    }

    self.histogramCell.histogramView.progress = CMTimeGetSeconds(time) / CMTimeGetSeconds(totalTime);
    self.viewModel.realTimeCommentsViewModel.currentTime = time;
}

- (void)videoCellReadyToPlay:(VContentVideoCell *)videoCell
{
    [UIViewController attemptRotationToDeviceOrientation];
    if (!self.hasAutoPlayed)
    {
        [self.videoCell play];
        self.hasAutoPlayed = YES;
        
        // The enhacer bar starts out disabled by default when a video asset is displayed.
        // If the video asset is playing, any ad (if there was one) is now over, and the
        // bar should be enabled.
        self.experienceEnhancerCell.experienceEnhancerBar.enabled = YES;
    }
}

- (void)videoCellPlayedToEnd:(VContentVideoCell *)videoCell
               withTotalTime:(CMTime)totalTime
{
    if (!self.enteringRealTimeComment)
    {
        self.textEntryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:totalTime]];
    }
}

- (void)videoCellWillStartPlaying:(VContentVideoCell *)videoCell
{
    [self.videoCell play];
}

#pragma mark - VKeyboardInputAccessoryViewDelegate

- (void)keyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inpoutAccessoryView
                         wantsSize:(CGSize)size
{
    if (size.height > kMaxInputBarHeight)
    {
        return;
    }
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
                              mediaURL:welf.mediaURL
                              realTime:welf.realtimeCommentBeganTime
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
    
    if ([[VSettingManager sharedManager] settingEnabledForKey:VExperimentsPauseVideoWhenCommenting])
    {
        [self.videoCell play];
    }
}

- (void)pressedAlternateReturnKeyonKeyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView
{
    if (inputAccessoryView.composedText.length == 0)
    {
        [self clearEditingRealTimeComment];
    }
}

- (void)pressedAttachmentOnKeyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    void (^showCamera)(void) = ^void(void)
    {
        VCameraViewController *cameraViewController = [VCameraViewController cameraViewControllerStartingWithStillCapture];
        __weak typeof(self) welf = self;
        cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
        {
            [[VThemeManager sharedThemeManager] applyStyling];
            if (finished)
            {
                welf.mediaURL = capturedMediaURL;
                [welf.textEntryView setSelectedThumbnail:previewImage];
            }
            [welf dismissViewControllerAnimated:YES completion:^
             {
                 if (finished)
                 {
                     [welf.textEntryView startEditing];
                 }
                 
                 [UIView animateWithDuration:0.0f
                                  animations:^
                  {
                      [welf.contentCollectionView reloadData];
                      [welf.contentCollectionView.collectionViewLayout invalidateLayout];
                  }];
             }];
        };
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
        [self presentViewController:navController animated:YES completion:nil];
    };
    
    if (self.mediaURL == nil)
    {
        showCamera();
        return;
    }
    
    void (^clearMediaSelection)(void) = ^void(void)
    {
        self.mediaURL = nil;
        [self.textEntryView setSelectedThumbnail:nil];
    };
    
    // We already have a selected media does the user want to discard and re-take?
    NSString *actionSheetTitle = NSLocalizedString(@"Delete this content and select something else?", @"User has already selected media (pictire/video) as an attachment for commenting.");
    NSString *discardActionTitle = NSLocalizedString(@"Delete", @"Delete the previously selected item. This is a destructive operation.");
    NSString *cancelActionTitle = NSLocalizedString(@"Cancel", @"Cancel button.");
    
    if (UI_IS_IOS8_AND_HIGHER)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:actionSheetTitle
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:discardActionTitle
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction *action)
                                        {
                                            clearMediaSelection();
                                            showCamera();
                                        }];
        [alertController addAction:deleteAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelActionTitle
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action)
                                       {
                                           [[VThemeManager sharedThemeManager] applyStyling];
                                       }];
        [alertController addAction:cancelAction];
        
        [[VThemeManager sharedThemeManager] removeStyling];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        [[[UIActionSheet alloc] initWithTitle:actionSheetTitle
                            cancelButtonTitle:cancelActionTitle
                               onCancelButton:nil
                       destructiveButtonTitle:discardActionTitle
                          onDestructiveButton:^
          {
              clearMediaSelection();
              showCamera();
          }
                   otherButtonTitlesAndBlocks:nil, nil] showInView:self.view];
    }
}

- (void)keyboardInputAccessoryViewDidClearInput:(VKeyboardInputAccessoryView *)inpoutAccessoryView
{
    if (self.viewModel.type != VContentViewTypeVideo)
    {
        return;
    }
    [self clearEditingRealTimeComment];
}

- (void)keyboardInputAccessoryViewDidBeginEditing:(VKeyboardInputAccessoryView *)inpoutAccessoryView
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    if (self.viewModel.type != VContentViewTypeVideo)
    {
        return;
    }
    
    if ([[VSettingManager sharedManager] settingEnabledForKey:VExperimentsPauseVideoWhenCommenting])
    {
        [self.videoCell pause];
    }
    
    self.enteringRealTimeComment = YES;
    self.realtimeCommentBeganTime = self.videoCell.currentTime;
}

- (void)clearEditingRealTimeComment
{
    self.enteringRealTimeComment = NO;
    self.realtimeCommentBeganTime = kCMTimeZero;
}

#pragma mark - VExperienceEnhancerControllerDelegate

- (void)experienceEnhancersDidUpdate
{
    // Do nothing, eventually a nice animation to reveal experience enhancers
}

- (BOOL)isVideoContent
{
    return self.videoCell != nil;
}

- (Float64)currentVideoTime
{
    if ( self.videoCell != nil )
    {
        Float64 seconds = CMTimeGetSeconds( self.videoCell.currentTime );
        if ( !isnan( seconds ) )
        {
            return CMTimeGetSeconds( self.videoCell.currentTime );
        }
    }
    return 0.0f;
}

@end
