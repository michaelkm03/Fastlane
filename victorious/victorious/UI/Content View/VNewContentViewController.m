//
//  VNewContentViewController.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNewContentViewController.h"
#import "VObjectManager+ContentCreation.h"

// SubViews
#import "VExperienceEnhancerBar.h"

// Images
#import "UIImage+ImageCreation.h"
#import "UIImageView+Blurring.h"

// Layout
#import "VShrinkingContentLayout.h"
#import "UIView+AutoLayout.h"

// Cells
#import "VContentCell.h"
#import "VContentVideoCell.h"
#import "VContentImageCell.h"
#import "VContentPollCell.h"
#import "VContentPollQuestionCell.h"
#import "VContentPollBallotCell.h"
#import "VContentCommentsCell.h"
#import "VExperienceEnhancerBarCell.h"
#import "VContentTextCell.h"

// Supplementary Views
#import "VSectionHandleReusableView.h"
#import "VContentBackgroundSupplementaryView.h"

// Input Accessory
#import "VKeyboardInputAccessoryView.h"
#import "UIActionSheet+VBlocks.h"

// ViewControllers
#import "VVideoLightboxViewController.h"
#import "VImageLightboxViewController.h"
#import "VUserProfileViewController.h"
#import "VPurchaseViewController.h"

// Media Attachments
#import "VMediaAttachmentPresenter.h"

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
#import "VDependencyManager+VTabScaffoldViewController.h"

// Swift
#import "victorious-Swift.h"

#import "VSequence+Fetcher.h"

#import "VTransitionDelegate.h"
#import "VEditCommentViewController.h"
#import "VSimpleModalTransition.h"

#import "VTracking.h"
#import "VCollectionViewCommentHighlighter.h"
#import "VScrollPaginator.h"
#import "VSequenceActionController.h"
#import "VContentViewRotationHelper.h"
#import "VEndCard.h"
#import "VContentRepopulateTransition.h"
#import "VAbstractCommentHighlighter.h"
#import "VEndCardActionModel.h"
#import "VCommentAlertHelper.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "VInlineSearchTableViewController.h"
#import "VTextAndMediaView.h"
#import "VTagSensitiveTextView.h"
#import "VTag.h"
#import "VUserTag.h"
#import "VHashtagStreamCollectionViewController.h"
#import "VNavigationController.h"
#import "VAuthorizedAction.h"
#import "VNode+Fetcher.h"
#import "VDependencyManager+VUserProfile.h"
#import "VHashtagSelectionResponder.h"
#import "VURLSelectionResponder.h"
#import "VDependencyManager+VTabScaffoldViewController.h"
#import "VContentViewFactory.h"
#import "VCoachmarkDisplayer.h"
#import "VDependencyManager+VCoachmarkManager.h"
#import "VCoachmarkManager.h"
#import "VSequenceExpressionsObserver.h"
#import "VExperienceEnhancerResponder.h"
#import "VDependencyManager+VTracking.h"
#import "VCommentTextAndMediaView.h"

// Cell focus
#import "VCollectionViewStreamFocusHelper.h"

#define HANDOFFENABLED 0

static NSString * const kPollBallotIconKey = @"orIcon";

@interface VNewContentViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UINavigationControllerDelegate, VKeyboardInputAccessoryViewDelegate,VContentVideoCellDelegate, VExperienceEnhancerControllerDelegate, VSwipeViewControllerDelegate, VCommentCellUtilitiesDelegate, VEditCommentViewControllerDelegate, VPurchaseViewControllerDelegate, VContentViewViewModelDelegate, VScrollPaginatorDelegate, VEndCardViewControllerDelegate, NSUserActivityDelegate, VTagSensitiveTextViewDelegate, VHashtagSelectionResponder, VURLSelectionResponder, VCoachmarkDisplayer, VExperienceEnhancerResponder, VUserTaggingTextStorageDelegate>

@property (nonatomic, strong) NSUserActivity *handoffObject;

@property (nonatomic, strong, readwrite) VContentViewViewModel *viewModel;
@property (nonatomic, strong) VPublishParameters *publishParameters;
@property (nonatomic, assign) BOOL hasAutoPlayed;

@property (nonatomic, weak) IBOutlet VInputAccessoryCollectionView *contentCollectionView;
@property (nonatomic, weak) IBOutlet UIImageView *blurredBackgroundImageView;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIButton *moreButton;

// Cells
@property (nonatomic, weak) VContentCell *contentCell;
@property (nonatomic, weak) VContentVideoCell *videoCell;
@property (nonatomic, weak) VExperienceEnhancerBarCell *experienceEnhancerCell;
@property (nonatomic, weak) VSectionHandleReusableView *handleView;
@property (nonatomic, weak) VContentPollCell *pollCell;
@property (nonatomic, weak) VContentPollBallotCell *ballotCell;
@property (nonatomic, weak) VContentTextCell *textCell;

// Text input
@property (nonatomic, weak) VKeyboardInputAccessoryView *textEntryView;
@property (nonatomic, strong) VElapsedTimeFormatter *elapsedTimeFormatter;
@property (nonatomic, strong) VMediaAttachmentPresenter *mediaAttachmentPresenter;
@property (nonatomic, assign) BOOL shouldResumeEditingAfterClearActionSheet;

// Constraints
@property (nonatomic, weak) NSLayoutConstraint *bottomKeyboardToContainerBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingCollectionViewToContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *trailingCollectionViewToContainer;

// RTC
@property (nonatomic, assign) BOOL enteringRealTimeComment;
@property (nonatomic, assign) CMTime realtimeCommentBeganTime;

@property (nonatomic, strong) VTransitionDelegate *modalTransitionDelegate;
@property (nonatomic, strong) VTransitionDelegate *repopulateTransitionDelegate;

@property (nonatomic, strong) VCollectionViewCommentHighlighter *commentHighlighter;
@property (nonatomic, assign) CGPoint offsetBeforeLandscape;
@property (nonatomic, weak) IBOutlet VContentViewRotationHelper *rotationHelper;
@property (nonatomic, weak) IBOutlet VScrollPaginator *scrollPaginator;
@property (nonatomic, weak, readwrite) IBOutlet VSequenceActionController *sequenceActionController;

@property (nonatomic, strong) VAuthorizedAction *authorizedAction;

@property (nonatomic, weak) UIView *snapshotView;
@property (nonatomic, assign) CGPoint offsetBeforeRemoval;
@property (nonatomic, strong) NSDate *videoLoadedDate;

@property (nonatomic, assign) BOOL hasBeenPresented;

@property (nonatomic, strong) VSequenceExpressionsObserver *expressionsObserver;

@property (nonatomic, strong) VContentLikeButton *likeButton;

@property (nonatomic, strong) VCollectionViewStreamFocusHelper *focusHelper;

@property (nonatomic, strong) NSMutableArray *commentCellReuseIdentifiers;

@end

@implementation VNewContentViewController

#pragma mark - Factory Methods

+ (VNewContentViewController *)contentViewControllerWithViewModel:(VContentViewViewModel *)viewModel
                                                dependencyManager:(VDependencyManager *)dependencyManager
{
    VNewContentViewController *contentViewController = [[UIStoryboard storyboardWithName:@"ContentView" bundle:nil] instantiateInitialViewController];
    contentViewController.viewModel = viewModel;
    contentViewController.hasAutoPlayed = NO;
    contentViewController.dependencyManager = dependencyManager;
    contentViewController.sequenceActionController.dependencyManager = dependencyManager;
    
    VSimpleModalTransition *modalTransition = [[VSimpleModalTransition alloc] init];
    contentViewController.modalTransitionDelegate = [[VTransitionDelegate alloc] initWithTransition:modalTransition];
    VContentRepopulateTransition *repopulateTransition = [[VContentRepopulateTransition alloc] init];
    contentViewController.repopulateTransitionDelegate = [[VTransitionDelegate alloc] initWithTransition:repopulateTransition];
    
    contentViewController.elapsedTimeFormatter = [[VElapsedTimeFormatter alloc] init];
    
    viewModel.delegate = contentViewController;
    
    return contentViewController;
}

#pragma mark - Dealloc

- (void)dealloc
{
    [VContentCommentsCell clearSharedImageCache];
}

#pragma mark - VContentViewViewModelDelegate

- (void)didUpdateCommentsWithPageType:(VPageType)pageType
{
    if (self.viewModel.comments.count > 0 && self.contentCollectionView.numberOfSections > VContentViewSectionAllComments)
    {
        if ([self.contentCollectionView numberOfItemsInSection:VContentViewSectionAllComments] > 0)
        {
            CGSize startSize = self.contentCollectionView.collectionViewLayout.collectionViewContentSize;
            
            if ( !self.commentHighlighter.isAnimatingCellHighlight ) //< Otherwise the animation is interrupted
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [self.contentCollectionView reloadData];
                    
                    __weak typeof(self) welf = self;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                                   {
                                       [welf.contentCollectionView flashScrollIndicators];
                                   });
                    
                    // If we're prepending new comments, we must adjust the scroll view's offset
                    if ( pageType == VPageTypePrevious )
                    {
                        CGSize endSize = self.contentCollectionView.collectionViewLayout.collectionViewContentSize;
                        CGPoint diff = CGPointMake( endSize.width - startSize.width, endSize.height - startSize.height );
                        CGPoint contentOffset = self.contentCollectionView.contentOffset;
                        contentOffset.x += diff.x;
                        contentOffset.y += diff.y;
                        self.contentCollectionView.contentOffset = contentOffset;
                    }
                    
                    [self.focusHelper updateFocus];
                });
            }
        }
        else
        {
            NSIndexSet *commentsIndexSet = [NSIndexSet indexSetWithIndex:VContentViewSectionAllComments];
            [self.contentCollectionView reloadSections:commentsIndexSet];
        }
        
        self.handleView.numberOfComments = self.viewModel.sequence.commentCount.integerValue;
    }
}

- (void)didUpdateCommentsWithDeepLink:(NSNumber *)commentId
{
    [self didUpdateCommentsWithPageType:VPageTypeFirst];
    
    for ( NSUInteger i = 0; i < self.viewModel.comments.count; i++ )
    {
        VComment *comment = self.viewModel.comments[ i ];
        if ( [comment.remoteId isEqualToNumber:commentId] )
        {
            [self didUpdateCommentsWithPageType:VPageTypePrevious];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:VContentViewSectionAllComments];
            [self.commentHighlighter scrollToAndHighlightIndexPath:indexPath delay:0.3f completion:^
            {
                // Setting `isAnimatingCellHighlight` to YES prevents the collectionView
                // from reloading (as intented).  So we call `updateCommentsWithPageType:`
                // to update if it any new comments were loading while
                // the animation was playing.
                [self didUpdateCommentsWithPageType:VPageTypePrevious];
                
                // Trigger the paginator to load any more pages based on the scroll
                // position to which VCommentHighlighter animated to
                [self.scrollPaginator scrollViewDidScroll:self.contentCollectionView];
            }];
        }
    }
}

- (void)didUpdateContent
{
    self.videoLoadedDate = [NSDate date];
    self.videoCell.viewModel = self.viewModel.videoViewModel;
}

- (void)didUpdatePollsData
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

#pragma mark Rotation

- (BOOL)shouldAutorotate
{
    BOOL hasVideoAsset = self.viewModel.type == VContentViewTypeVideo || self.viewModel.type == VContentViewTypeGIFVideo;
    BOOL shouldRotate = (hasVideoAsset && self.videoCell.status == AVPlayerStatusReadyToPlay && !self.presentedViewController && !self.videoCell.isPlayingAd);
    return shouldRotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    BOOL hasVideoAsset = self.viewModel.type == VContentViewTypeVideo || self.viewModel.type == VContentViewTypeGIFVideo;
    BOOL isVideoAndReadyToPlay = hasVideoAsset &&  (self.videoCell.status == AVPlayerStatusReadyToPlay);
    return (isVideoAndReadyToPlay) ? UIInterfaceOrientationMaskAllButUpsideDown : UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    __weak typeof(self) welf = self;
    void (^rotationUpdate)() = ^
    {
        __strong typeof(welf) strongSelf = welf;
        [strongSelf handleRotationToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
    };
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         rotationUpdate();
     }
                                 completion:nil];
}

- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // We need to update first responder status on the collection view for the comment bar
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        [self.textEntryView stopEditing];
        [self.contentCollectionView resignFirstResponder];
        self.offsetBeforeLandscape = self.contentCollectionView.contentOffset;
    }
    else
    {
        self.contentCollectionView.contentOffset = self.offsetBeforeLandscape;
        [self.contentCollectionView becomeFirstResponder];
    }

    NSMutableArray *affectedViews = [[NSMutableArray alloc] init];
    
    if ( self.moreButton != nil )
    {
        [affectedViews addObject:self.moreButton];
    }
    
    const CGSize experienceEnhancerCellSize = [VExperienceEnhancerBarCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds
                                                                                            dependencyManager:self.dependencyManager];
    const CGPoint fixedLandscapeOffset = CGPointMake( 0.0f, experienceEnhancerCellSize.height );
    
    [self.rotationHelper handleRotationToInterfaceOrientation:toInterfaceOrientation
                                          targetContentOffset:fixedLandscapeOffset
                                               collectionView:self.contentCollectionView
                                                affectedViews:[NSArray arrayWithArray:affectedViews]];
    if ( self.videoCell != nil )
    {
        [self.videoCell handleRotationToInterfaceOrientation:toInterfaceOrientation];
    }
}

- (void)updateOrientation
{
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self handleRotationToInterfaceOrientation:currentOrientation];
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.closeButton.accessibilityIdentifier = VAutomationIdentifierContentViewCloseButton;

    self.authorizedAction = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                           dependencyManager:self.dependencyManager];
    
    self.commentHighlighter = [[VCollectionViewCommentHighlighter alloc] initWithCollectionView:self.contentCollectionView];
    
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
    
    self.focusHelper = [[VCollectionViewStreamFocusHelper alloc] initWithCollectionView:self.contentCollectionView];
    
    self.contentCollectionView.collectionViewLayout = [[VShrinkingContentLayout alloc] init];
    self.contentCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.viewModel.sequence.permissions.canComment )
    {
        NSDictionary *commentBarConfig = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:@"commentBar"];
        VDependencyManager *commentBarDependencyManager = [[VDependencyManager alloc] initWithParentManager:self.dependencyManager configuration:commentBarConfig dictionaryOfClassesByTemplateName:nil];
        VKeyboardInputAccessoryView *inputAccessoryView = [VKeyboardInputAccessoryView defaultInputAccessoryViewWithDependencyManager:commentBarDependencyManager];
        inputAccessoryView.translatesAutoresizingMaskIntoConstraints = NO;
        inputAccessoryView.delegate = self;
        inputAccessoryView.textStorageDelegate = self;
        inputAccessoryView.accessibilityIdentifier = VAutomationIdentifierContentViewCommentBar;
        self.textEntryView = inputAccessoryView;
        self.contentCollectionView.accessoryView = self.textEntryView;
    }
    
    self.contentCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    // Register nibs
    [self.contentCollectionView registerNib:[VContentCell nibForCell]
                 forCellWithReuseIdentifier:[VContentCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentTextCell nibForCell]
                 forCellWithReuseIdentifier:[VContentTextCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentVideoCell nibForCell]
                 forCellWithReuseIdentifier:[VContentVideoCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentImageCell nibForCell]
                 forCellWithReuseIdentifier:[VContentImageCell suggestedReuseIdentifier]];
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
    
    self.commentCellReuseIdentifiers = [NSMutableArray new];
    
    [self.viewModel reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self didUpdateCommentsWithPageType:VPageTypeFirst];
    [self.dependencyManager trackViewWillAppear:self];
    
    
    [self.navigationController setNavigationBarHidden:YES
                                             animated:YES];
    
    [self.contentCollectionView becomeFirstResponder];
    self.videoCell.delegate = self;

#ifdef V_ALLOW_VIDEO_DOWNLOADS
    // We could probably move this here anyway, but not going to for now to avoid bugs.
    self.videoCell.viewModel = self.viewModel.videoViewModel;
#endif
    
    if (self.viewModel.sequence.isImage)
    {
        [self.blurredBackgroundImageView applyTintAndBlurToImageWithURL:self.viewModel.imageURLRequest.URL
                                                          withTintColor:nil];
    }
    else
    {
        [self.blurredBackgroundImageView setBlurredImageWithClearImage:self.placeholderImage
                                                      placeholderImage:nil
                                                             tintColor:nil];
    }
    
    if ([self.viewModel.sequence isPoll])
    {
        if (self.viewModel.favoredAnswer != VPollAnswerInvalid)
        {
            VBallot favoredBallot = (self.viewModel.favoredAnswer == VPollAnswerA) ? VBallotA : VBallotB;
            [self.ballotCell setVotingDisabledWithFavoredBallot:favoredBallot animated:YES];
        }
    }
    
    if ( self.navigationController != nil )
    {
        [self.dependencyManager applyStyleToNavigationBar:self.navigationController.navigationBar];
        if ( !self.navigationController.navigationBarHidden )
        {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
    }
    
    [self updateOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateInsetsForKeyboardBarState];
    
    NSString *contextType = [self trackingValueForContentType] ?: @"";
    [[VTrackingManager sharedInstance] setValue:contextType forSessionParameterWithKey:VTrackingKeyContentType];
    [[VTrackingManager sharedInstance] setValue:VTrackingValueContentView forSessionParameterWithKey:VTrackingKeyContext];
    
    [[self.dependencyManager coachmarkManager] displayCoachmarkViewInViewController:self];
    
#if HANDOFFENABLED
    if ((self.viewModel.sequence.remoteId != nil) && (self.viewModel.shareURL != nil))
    {
        NSString *handoffIdentifier = [NSString stringWithFormat:@"com.victorious.handoff.%@", self.viewModel.sequence.remoteId];
        self.handoffObject = [[NSUserActivity alloc] initWithActivityType:handoffIdentifier];
        self.handoffObject.webpageURL = self.viewModel.shareURL;
        self.handoffObject.delegate = self;
        [self.handoffObject becomeCurrent];
    }
#endif
    
    if ( !self.hasBeenPresented && self.videoCell == nil )
    {
        self.hasBeenPresented = YES;
        
        NSDictionary *params = @{ VTrackingKeyTimeStamp : [NSDate date],
                                  VTrackingKeyStreamId : self.viewModel.streamId,
                                  VTrackingKeySequenceId : self.viewModel.sequence.remoteId,
                                  VTrackingKeyUrls : self.viewModel.sequence.tracking.viewStart ?: @[] };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventViewDidStart parameters:params];
    }
    
    [self.contentCollectionView flashScrollIndicators];
    
    // Update cell focus
    [self.focusHelper updateFocus];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
    
    [[self.dependencyManager coachmarkManager] hideCoachmarkViewInViewController:self animated:animated];
    
    if ( self.videoCell != nil && !self.videoCell.didFinishPlayingOnce  )
    {
        NSDictionary *params = @{ VTrackingKeyUrls : self.viewModel.sequence.tracking.viewStop ?: @[],
                                  VTrackingKeyStreamId : self.viewModel.streamId,
                                  VTrackingKeyTimeCurrent : @( self.videoCell.currentTimeMilliseconds ) };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventVideoDidStop parameters:params];
    }

    [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyContentType];
    
    if ( self.isBeingDismissed )
    {
        [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyContext];
    }
    
#if HANDOFFENABLED
    self.handoffObject.delegate = nil;
    [self.handoffObject invalidate];
#endif
    
    // We don't care about these notifications anymore but we still care about new user loggedin
    [self.contentCollectionView resignFirstResponder];
    self.videoCell.delegate = nil;
    
    [self.commentHighlighter stopAnimations];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Stop all video cells
    [self.focusHelper endFocusOnAllCells];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(void (^)(void))completion
{
    @try {
        
        [super presentViewController:viewControllerToPresent
                            animated:flag
                          completion:completion];
    }
    @catch (NSException *exception) {
        NSLog( @"%@", exception.description );
    }
    
    // Pause playback on presentation
    if ( ![self.videoCell playerControlsDisabled] )
    {
        [self.videoCell pause];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)v_prefersNavigationBarHidden
{
    return YES;
}

- (NSString *)trackingValueForContentType
{
    switch (self.viewModel.type)
    {
        case VContentViewTypePoll:
            return VTrackingValuePoll;
        case VContentViewTypeImage:
            return VTrackingValueImage;
        case VContentViewTypeGIFVideo:
            return VTrackingValueGIF;
        case VContentViewTypeVideo:
            return VTrackingValueVideo;
        default:
            return nil;
    }
}

#pragma mark - IBActions

- (IBAction)pressedClose:(id)sender
{
    [self removeCollectionViewFromContainer];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectedLikeButton:(UIButton *)likeButton
{
    likeButton.enabled = NO;
    [self.sequenceActionController likeSequence:self.viewModel.sequence fromViewController:self withActionView:likeButton completion:^(BOOL success)
     {
         likeButton.enabled = YES;
     }];
}

#pragma mark - Private Mehods

- (void)updateInsetsForKeyboardBarState
{
    // Adjust focus area for keyboard bar
    CGRect obscuredRectInWindow = [self.textEntryView obscuredRectInWindow:self.view.window];
    CGRect obscuredRectInOwnView = [self.view.window convertRect:obscuredRectInWindow toView:self.view];
    CGFloat bottomObscuredSize = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(obscuredRectInOwnView);
    self.contentCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(VShrinkingContentLayoutMinimumContentHeight, 0, bottomObscuredSize, 0);
    self.contentCollectionView.contentInset = UIEdgeInsetsMake(0, 0, bottomObscuredSize, 0);
    [self.focusHelper setFocusAreaInsets:UIEdgeInsetsMake(0, 0, bottomObscuredSize, 0)];
}

- (void)removeCollectionViewFromContainer
{
    self.snapshotView = [self.view snapshotViewAfterScreenUpdates:NO];
    [self.view addSubview:self.snapshotView];
    self.offsetBeforeRemoval = self.contentCollectionView.contentOffset;
    self.contentCollectionView.delegate = nil;
    self.contentCollectionView.dataSource = nil;
    [self.contentCollectionView resignFirstResponder];
    [self.textEntryView stopEditing];
    [self.videoCell prepareForRemoval];

    [self.contentCollectionView removeFromSuperview];
}

- (void)restoreCollectionView
{
    [self.snapshotView removeFromSuperview];
    self.contentCollectionView.delegate = self;
    self.contentCollectionView.dataSource = self;
    self.videoCell.delegate = self;
    self.contentCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentCollectionView.contentOffset = self.offsetBeforeRemoval;
    [self.view addSubview:self.contentCollectionView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[collectionView]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:@{@"collectionView":self.contentCollectionView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:@{@"collectionView":self.contentCollectionView}]];
    [self.view bringSubviewToFront:self.closeButton];
    [self.view bringSubviewToFront:self.moreButton];
}

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
    commentCell.dependencyManager = self.dependencyManager;
    commentCell.comment = self.viewModel.comments[index];
    commentCell.commentAndMediaView.textView.tagTapDelegate = self;
    commentCell.swipeViewController.controllerDelegate = self;
    commentCell.commentsUtilitiesDelegate = self;
    
    __weak typeof(commentCell) wCommentCell = commentCell;
    __weak typeof(self) welf = self;
    [commentCell.commentAndMediaView setOnMediaTapped:^(UIImage *previewImage)
     {
         [welf showLightBoxWithMediaURL:[wCommentCell.comment properMediaURLGivenContentType]
                           previewImage:previewImage
                                isVideo:wCommentCell.mediaIsVideo
                             sourceView:wCommentCell.commentAndMediaView];
     }];
    
    commentCell.onUserProfileTapped = ^(void)
    {
        VUserProfileViewController *profileViewController = [welf.dependencyManager userProfileViewControllerWithUser:wCommentCell.comment.user];
        [welf.navigationController pushViewController:profileViewController animated:YES];
    };
}

- (void)tagSensitiveTextView:(VTagSensitiveTextView *)tagSensitiveTextView tappedTag:(VTag *)tag
{
    if ( [tag isKindOfClass:[VUserTag class]] )
    {
        //Tapped a user tag, show a profile view controller
        VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithRemoteId:((VUserTag *)tag).remoteId];
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
    else
    {
        //Tapped a hashtag, show a hashtag view controller
        VHashtagStreamCollectionViewController *hashtagViewController = [self.dependencyManager hashtagStreamWithHashtag:[tag.displayString.string substringFromIndex:1]];
        [self.navigationController pushViewController:hashtagViewController animated:YES];
    }
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
            // sometimes the content dissapears withour reloading due to rotation 😱
            [welf.contentCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionContent]]];
            [welf.contentCollectionView.collectionViewLayout invalidateLayout];
            [welf dismissViewControllerAnimated:YES
                                     completion:^
             {
                 [[welf class] attemptRotationToDeviceOrientation];
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
        case VContentViewSectionPollQuestion:
        {
            if (self.viewModel.type == VContentViewTypePoll)
            {
                return 1;
            }
            return 0;
        }
            
        case VContentViewSectionExperienceEnhancers:
        {
            if (self.viewModel.type == VContentViewTypePoll)
            {
                return 1;
            }
            else
            {
                return (self.viewModel.experienceEnhancerController.numberOfExperienceEnhancers > 0) ? 1 : 0;
            }
        }
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
        {
            UICollectionViewCell *cell = [self contentCellForCollectionView:collectionView atIndexPath:indexPath];
            if ( [cell isKindOfClass:[VContentCell class]] )
            {
                [self configureLikeButtonWithContentCell:(VContentCell *)cell forSequence:self.viewModel.sequence];
            }
            return cell;
        }
        case VContentViewSectionPollQuestion:
        {
            VContentPollQuestionCell *questionCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentPollQuestionCell suggestedReuseIdentifier]
                                                                                               forIndexPath:indexPath];
            questionCell.question = [[NSAttributedString alloc] initWithString:self.viewModel.sequence.name
                                                                    attributes:@{NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading2FontKey]}];
            return questionCell;
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

                self.ballotCell.answerA = [[NSAttributedString alloc] initWithString:self.viewModel.answerALabelText attributes:@{NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey]}];
                self.ballotCell.answerB = [[NSAttributedString alloc] initWithString:self.viewModel.answerBLabelText attributes:@{NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey]}];
                self.ballotCell.orImageView.image = [self.dependencyManager imageForKey:kPollBallotIconKey];
                
                __weak typeof(self) welf = self;
                self.ballotCell.answerASelectionHandler = ^(void)
                {
                    [welf.authorizedAction performFromViewController:welf context:VAuthorizationContextVotePoll completion:^(BOOL authorized)
                    {
                        if (!authorized)
                        {
                            return;
                        }
                        
                        [welf.viewModel answerPollWithAnswer:VPollAnswerA
                                                  completion:^(BOOL succeeded, NSError *error)
                         {
                             [welf.pollCell setAnswerAPercentage:welf.viewModel.answerAPercentage
                                                        animated:YES];
                         }];
                    }];
                };
                self.ballotCell.answerBSelectionHandler = ^(void)
                {
                    [welf.authorizedAction performFromViewController:welf context:VAuthorizationContextVotePoll completion:^(BOOL authorized)
                     {
                         if (!authorized)
                         {
                             return;
                         }
                         
                         [welf.viewModel answerPollWithAnswer:VPollAnswerB
                                                   completion:^(BOOL succeeded, NSError *error)
                          {
                              [welf.pollCell setAnswerBPercentage:welf.viewModel.answerBPercentage
                                                         animated:YES];
                          }];
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
            self.experienceEnhancerCell.dependencyManager = self.dependencyManager;
            
            [self updateInitialExperienceEnhancerState];
            
            __weak typeof(self) welf = self;
            self.experienceEnhancerCell.experienceEnhancerBar.selectionBlock = ^(VExperienceEnhancer *selectedEnhancer, CGPoint selectionCenter)
            {
                if (selectedEnhancer.isBallistic)
                {
                    CGRect animationFrameSize = CGRectMake(0, 0, selectedEnhancer.flightImage.size.width, selectedEnhancer.flightImage.size.height);
                    UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:animationFrameSize];
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
                         CGFloat randomLocationX = arc4random_uniform(CGRectGetWidth(welf.contentCell.frame));
                         CGFloat randomLocationY = arc4random_uniform(CGRectGetHeight(welf.contentCell.frame));
                         animationImageView.center = CGPointMake(randomLocationX, randomLocationY);
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
                
                // Refresh comments 2 seconds after user throws an EB in case we need to show an EB comment
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                {
                    __strong typeof(welf) strongSelf = welf;
                    [strongSelf reloadComments];
                });
            };
            
            return self.experienceEnhancerCell;
        }
        case VContentViewSectionAllComments:
        {
            VComment *comment = self.viewModel.comments[indexPath.row];
            NSString *reuseIdentifier = [MediaAttachmentView reuseIdentifierForComment:comment];
            
            if (![self.commentCellReuseIdentifiers containsObject:reuseIdentifier])
            {
                [self.contentCollectionView registerNib:[VContentCommentsCell nibForCell] forCellWithReuseIdentifier:reuseIdentifier];
                [self.commentCellReuseIdentifiers addObject:reuseIdentifier];
            }
            
            VContentCommentsCell *commentCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                                          forIndexPath:indexPath];
            commentCell.accessibilityIdentifier = VAutomationIdentifierContentViewCommentCell;
            commentCell.sequencePermissions = self.viewModel.sequence.permissions;
            [self configureCommentCell:commentCell withIndex:indexPath.row];
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
            
        case VContentViewSectionPollQuestion:
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
                case VContentViewTypeGIFVideo:
                    return [VContentVideoCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
                case VContentViewTypePoll:
                    return [VContentPollCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
                case VContentViewTypeText:
                    return [VContentTextCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
            }
        }
        case VContentViewSectionPollQuestion:
            return  [VContentPollQuestionCell actualSizeWithQuestion:self.viewModel.sequence.name
                                                          attributes:@{NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading2FontKey]}
                                                         maximumSize:CGSizeMake(CGRectGetWidth(self.contentCollectionView.bounds), CGRectGetHeight(self.contentCollectionView.bounds)/2)];;
        case VContentViewSectionExperienceEnhancers:
        {
            if (self.viewModel.type == VContentViewTypePoll)
            {
                NSString *answerAtext = self.viewModel.answerALabelText ?: @"";
                NSString *answerBText = self.viewModel.answerBLabelText ?: @"";
                
                CGSize sizedBallot = [VContentPollBallotCell actualSizeWithAnswerA:[[NSAttributedString alloc] initWithString:answerAtext
                                                                                                                   attributes:@{NSFontAttributeName : [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey]}]
                                                                           answerB:[[NSAttributedString alloc] initWithString:answerBText
                                                                                                                   attributes:@{NSFontAttributeName : [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey]}]
                                                                       maximumSize:CGSizeMake(CGRectGetWidth(collectionView.bounds), 100.0)];
                return sizedBallot;
            }
            return [VExperienceEnhancerBarCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds
                                                                 dependencyManager:self.dependencyManager];
        }
        case VContentViewSectionAllComments:
        {
            const CGFloat minBound = MIN( CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) );
            VComment *comment = self.viewModel.comments[indexPath.row];
            CGSize size = [VContentCommentsCell sizeWithFullWidth:minBound
                                                          comment:comment
                                                         hasMedia:comment.commentMediaType != VCommentMediaTypeNoMedia
                                                dependencyManager:self.dependencyManager];
            return CGSizeMake( minBound, size.height );
        }
        case VContentViewSectionCount:
        {
            const CGFloat minBound = MIN( CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) );
            return CGSizeMake( minBound, minBound );
        }
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
        case VContentViewSectionPollQuestion:
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    const BOOL isContentSection = [indexPath compare:[self indexPathForContentView]] == NSOrderedSame;
    
    if ( !self.rotationHelper.isLandscape && isContentSection )
    {
        [self.contentCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (UICollectionViewCell *)contentCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    switch (self.viewModel.type)
    {
        case VContentViewTypeInvalid:
            return nil;
        case VContentViewTypeImage:
        {
            VContentImageCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentImageCell suggestedReuseIdentifier]
                                                                                     forIndexPath:indexPath];
            [imageCell.contentImageView sd_setImageWithURL:self.viewModel.imageURLRequest.URL
                                          placeholderImage:self.placeholderImage?:nil];
            self.contentCell = imageCell;
            self.contentCell.endCardDelegate = self;
            return imageCell;
        }
        case VContentViewTypeGIFVideo:
        case VContentViewTypeVideo:
        {
            if (self.videoCell)
            {
                return self.videoCell;
            }
            
            VContentVideoCell *videoCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentVideoCell suggestedReuseIdentifier]
                                                                                     forIndexPath:indexPath];
            videoCell.tracking = self.viewModel.sequence.tracking;
            videoCell.delegate = self;
            videoCell.speed = self.viewModel.speed;
            videoCell.loop = self.viewModel.loop;
            videoCell.playerControlsDisabled = self.viewModel.playerControlsDisabled;
            videoCell.audioMuted = self.viewModel.audioMuted;
            self.videoCell = videoCell;
            self.contentCell = videoCell;
            __weak typeof(self) welf = self;
            if ( !videoCell.playerControlsDisabled  )
            {
                [self.videoCell setAnimateAlongsizePlayControlsBlock:^(BOOL playControlsHidden)
                 {
                     const BOOL shouldHide = playControlsHidden && !welf.videoCell.isEndCardShowing;
                     welf.moreButton.alpha = shouldHide ? 0.0f : 1.0f;
                     welf.closeButton.alpha = shouldHide ? 0.0f : 1.0f;
                     welf.likeButton.transform = playControlsHidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, -CGRectGetHeight(welf.likeButton.bounds));
                 }];
            }
            videoCell.endCardDelegate = self;
            videoCell.minSize = CGSizeMake( self.contentCell.minSize.width, VShrinkingContentLayoutMinimumContentHeight );
            return videoCell;
        }
        case VContentViewTypeText:
        {
            VContentTextCell *textCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentTextCell suggestedReuseIdentifier]
                                                                                   forIndexPath:indexPath];
            textCell.dependencyManager = self.dependencyManager;
            [textCell setTextContent:self.viewModel.textContent
                     backgroundColor:self.viewModel.textBackgroundColor
                  backgroundImageURL:self.viewModel.textBackgroundImageURL];
            self.contentCell = textCell;
            return textCell;
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
                NSDictionary *params = @{ VTrackingKeyIndex : @0, VTrackingKeyMediaType : [mediaURL pathExtension] ?: @"" };
                [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectPollMedia parameters:params];
                
                [welf showLightBoxWithMediaURL:mediaURL
                                  previewImage:weakPollCell.answerAPreviewImage
                                       isVideo:isVideo
                                    sourceView:weakPollCell.answerAContainer];
            };
            pollCell.onAnswerBSelection = ^void(BOOL isVideo, NSURL *mediaURL)
            {
                NSDictionary *params = @{ VTrackingKeyIndex : @1, VTrackingKeyMediaType : [mediaURL pathExtension] ?: @"" };
                [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectPollMedia parameters:params];
                
                [welf showLightBoxWithMediaURL:mediaURL
                                  previewImage:weakPollCell.answerBPreviewImage
                                       isVideo:isVideo
                                    sourceView:weakPollCell.answerBContainer];
            };
            
            self.pollCell = pollCell;
            return pollCell;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // End focus on this cell to stop video if there is one
    [self.focusHelper endFocusOnCell:cell];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    const BOOL hasComments = self.viewModel.comments.count > 0;
    if ( hasComments )
    {
        if ( !self.commentHighlighter.isAnimatingCellHighlight )
        {
            [self.scrollPaginator scrollViewDidScroll:scrollView];
        }
    }

    if (self.viewModel.type == VContentViewTypeVideo)
    {
        VShrinkingContentLayout *layout = (VShrinkingContentLayout *)self.contentCollectionView.collectionViewLayout;
        self.likeButton.alpha = 1.0f - layout.percentCloseToLockPointFromCatchPoint;
    }
    
    // Update focus on cells
    [self.focusHelper updateFocus];
}

#pragma mark - VContentVideoCellDelegate

- (void)videoCell:(VContentVideoCell *)videoCell didPlayToTime:(CMTime)time totalTime:(CMTime)totalTime
{
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
        
        NSUInteger videoLoadTime = [[NSDate date] timeIntervalSinceDate:self.videoLoadedDate] * 1000;
        NSDictionary *params = @{ VTrackingKeyTimeStamp : [NSDate date],
                                  VTrackingKeyStreamId : self.viewModel.streamId,
                                  VTrackingKeySequenceId : self.viewModel.sequence.remoteId,
                                  VTrackingKeyUrls : self.viewModel.sequence.tracking.viewStart ?: @[],
                                  VTrackingKeyLoadTime : @(videoLoadTime),
                                  VTrackingKeyTimeCurrent : @( self.videoCell.currentTimeMilliseconds ) };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventViewDidStart parameters:params];
    }
    [UIView animateWithDuration:0.5f
                     animations:^
     {
         self.likeButton.alpha = 1.0f;
     }];
}

- (void)videoCellPlayedToEnd:(VContentVideoCell *)videoCell withTotalTime:(CMTime)totalTime
{
    if (self.viewModel.videoViewModel.endCardViewModel != nil)
    {
        [UIView animateWithDuration:0.5f
                         animations:^
         {
             self.likeButton.alpha = 0.0f;
         }];
    }
}

- (void)videoCellWillStartPlaying:(VContentVideoCell *)videoCell
{
    [self.videoCell play];
}

#pragma mark - VKeyboardInputAccessoryViewDelegate

- (void)pressedSendOnKeyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView
{
    __weak typeof(self) welf = self;
    [self.authorizedAction performFromViewController:self context:VAuthorizationContextAddComment completion:^(BOOL authorized)
     {
         __strong typeof(self) strongSelf = welf;
         if (!authorized)
         {
             return;
         }
         
         [strongSelf submitCommentWithText:inputAccessoryView.composedText];
         
         [inputAccessoryView clearTextAndResign];
         strongSelf.publishParameters.mediaToUploadURL = nil;
         
         NSNumber *experimentValue = [strongSelf.dependencyManager numberForKey:VDependencyManagerPauseVideoWhenCommentingKey];
         if (experimentValue != nil)
         {
             if ([experimentValue boolValue])
             {
                 [strongSelf.videoCell play];
             }
         }
     }];
}

- (void)keyboardInputAccessoryViewWantsToClearMedia:(VKeyboardInputAccessoryView *)inputAccessoryView
{
    BOOL shouldResumeEditing = [inputAccessoryView isEditing];
    [inputAccessoryView stopEditing];
    UIAlertController *alertController = [VCommentAlertHelper alertForConfirmDiscardMediaWithDelete:^
                                          {
                                              self.publishParameters.mediaToUploadURL = nil;
                                              [inputAccessoryView setSelectedThumbnail:nil];
                                              if (shouldResumeEditing)
                                              {
                                                  [inputAccessoryView startEditing];
                                              }
                                          }
                                                                                          cancel:^
                                          {
                                              if (shouldResumeEditing)
                                              {
                                                  [inputAccessoryView startEditing];
                                              }
                                          }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)keyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView
            selectedAttachmentType:(VKeyboardBarAttachmentType)attachmentType
{
    [inputAccessoryView stopEditing];
    __weak typeof(self) welf = self;
    [self.authorizedAction performFromViewController:self context:VAuthorizationContextAddComment completion:^(BOOL authorized)
     {
         if (!authorized)
         {
             return;
         }
         __strong typeof(welf) strongSelf = welf;
         [strongSelf addMediaToCommentWithAttachmentType:attachmentType];
     }];
}

- (void)keyboardInputAccessoryViewDidClearInput:(VKeyboardInputAccessoryView *)inpoutAccessoryView
{
    if (self.viewModel.type != VContentViewTypeVideo || self.viewModel.type == VContentViewTypeGIFVideo)
    {
        return;
    }
    [self clearEditingRealTimeComment];
}

- (void)keyboardInputAccessoryViewDidEndEditing:(VKeyboardInputAccessoryView *)inpoutAccessoryView
{
    [self updateInsetsForKeyboardBarState];
}

- (void)keyboardInputAccessoryViewDidBeginEditing:(VKeyboardInputAccessoryView *)inpoutAccessoryView
{
    [self updateInsetsForKeyboardBarState];
    
    if ( self.viewModel.type != VContentViewTypeVideo )
    {
        return;
    }
    
    NSNumber *experimentValue = [self.dependencyManager numberForKey:VDependencyManagerPauseVideoWhenCommentingKey];
    if (experimentValue != nil)
    {
        if ([experimentValue boolValue])
        {
            [self.videoCell pause];
        }
    }
    __weak typeof(self) welf = self;
    [self.authorizedAction performFromViewController:self context:VAuthorizationContextAddComment completion:^(BOOL authorized)
     {
         if (!authorized)
         {
             return;
         }
         welf.enteringRealTimeComment = YES;
         welf.realtimeCommentBeganTime = welf.videoCell.currentTime;
     }];
}

#pragma mark - VUserTaggingTextStorageDelegate

- (void)userTaggingTextStorage:(VUserTaggingTextStorage *)textStorage wantsToDismissViewController:(UITableViewController *)tableViewController
{
    [tableViewController.view removeFromSuperview];
    self.textEntryView.attachmentsBarHidden = NO;
}

- (void)userTaggingTextStorage:(VUserTaggingTextStorage *)textStorage wantsToShowViewController:(UIViewController *)viewController
{
    // Inline Search layout constraints
    UIView *searchTableView = viewController.view;
    [self.view addSubview:searchTableView];
    [searchTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    searchTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    UIWindow *ownWindow = self.view.window;
    CGRect obscuredRectInWindow = [self.textEntryView obscuredRectInWindow:ownWindow];
    CGRect obscuredRectInOwnView = [ownWindow convertRect:obscuredRectInWindow toView:self.view];
    [self.view v_addFitToParentConstraintsToSubview:searchTableView leading:0.0f trailing:0.0f top:0.0f bottom:CGRectGetMinY(obscuredRectInOwnView)];
    
    self.textEntryView.attachmentsBarHidden = YES;
}

#pragma mark - Comment Text Helpers

- (void)clearEditingRealTimeComment
{
    self.enteringRealTimeComment = NO;
    self.realtimeCommentBeganTime = kCMTimeZero;
}

- (void)submitCommentWithText:(NSString *)commentText
{
    __weak typeof(self) welf = self;
    [self.viewModel addCommentWithText:commentText
                              publishParameters:welf.publishParameters
                              realTime:welf.realtimeCommentBeganTime
                            completion:^(BOOL succeeded)
     {
         __strong typeof(welf) strongSelf = welf;
         [strongSelf reloadComments];
     }];
}

- (void)reloadComments
{
    [self.viewModel loadComments:VPageTypeFirst];
}

- (void)addMediaToCommentWithAttachmentType:(VKeyboardBarAttachmentType)attachmentType
{
    [self.textEntryView stopEditing];
    
    self.mediaAttachmentPresenter = [[VMediaAttachmentPresenter alloc] initWithDependencymanager:self.dependencyManager];
    __weak typeof(self) welf = self;
    VMediaAttachmentOptions attachmentOption;
    switch (attachmentType)
    {
        case VKeyboardBarAttachmentTypeVideo:
            attachmentOption = VMediaAttachmentOptionsVideo;
            break;
        case VKeyboardBarAttachmentTypeImage:
            attachmentOption = VMediaAttachmentOptionsImage;
            break;
        case VKeyboardBarAttachmentTypeGIF:
            attachmentOption = VMediaAttachmentOptionsGIF;
            break;
    }
    self.mediaAttachmentPresenter.attachmentTypes = attachmentOption;
    self.mediaAttachmentPresenter.resultHandler = ^void(BOOL success, VPublishParameters *publishParameters)
    {
        __strong typeof(self) strongSelf = welf;
        strongSelf.publishParameters = publishParameters;
        [strongSelf onMediaAttachedWithPreviewImage:publishParameters.previewImage
                                           mediaURL:publishParameters.mediaToUploadURL];
    };
    [self.mediaAttachmentPresenter presentOnViewController:self];
}

- (void)onMediaAttachedWithPreviewImage:(UIImage *)previewImage
                               mediaURL:(NSURL *)mediaURL
{
    [self.textEntryView setSelectedThumbnail:previewImage];
    
    [self dismissViewControllerAnimated:YES completion:^
     {
         self.mediaAttachmentPresenter = nil;
         [self.textEntryView startEditing];
     }];
}

- (void)configureLikeButtonWithContentCell:(VContentCell *)contentCell forSequence:(VSequence *)sequence
{
    if ( contentCell.likeButton == nil )
    {
        return;
    }
    
    if ( [self.dependencyManager numberForKey:VDependencyManagerLikeButtonEnabledKey].boolValue )
    {
        self.likeButton = contentCell.likeButton;
        self.likeButton.hidden = NO;
        
        [self.likeButton addTarget:self action:@selector(selectedLikeButton:) forControlEvents:UIControlEventTouchUpInside];
        
        self.expressionsObserver = [[VSequenceExpressionsObserver alloc] init];
        
        __weak typeof(self) welf = self;
        [self.expressionsObserver startObservingWithSequence:self.viewModel.sequence onUpdate:^
         {
             __strong typeof(self) strongSelf = welf;
             [strongSelf.likeButton setActive:sequence.isLikedByMainUser.boolValue];
             [strongSelf.likeButton setCount:sequence.likeCount.integerValue];
         }];
        if (self.viewModel.type == VContentViewTypeVideo)
        {
            self.likeButton.alpha = 0.0f;
        }
    }
    else
    {
        contentCell.likeButton.hidden = YES;
    }
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

#pragma mark - VSwipeViewControllerDelegate

- (UIColor *)backgroundColorForGutter
{
    return [UIColor colorWithWhite:0.96f alpha:1.0f];
}

- (void)cellWillShowUtilityButtons:(UIView *)cellView
{
    // Close any other cells showing utility buttons
    [self.contentCollectionView.visibleCells enumerateObjectsUsingBlock:^(VContentCommentsCell *cell, NSUInteger idx, BOOL *stop)
     {
         if ( [cell isKindOfClass:[VContentCommentsCell class]] && cellView != cell )
         {
             [cell.swipeViewController hideUtilityButtons];
         }
     }];
}

#pragma mark - VCommentCellUtilitiesDelegate

- (void)commentRemoved:(VComment *)comment
{
    [self.contentCollectionView performBatchUpdates:^void
     {
         NSUInteger row = [self.viewModel.comments indexOfObject:comment];
         [self.viewModel removeCommentAtIndex:row];
         NSArray *indexPaths = @[ [NSIndexPath indexPathForRow:row inSection:VContentViewSectionAllComments] ];
         [self.contentCollectionView deleteItemsAtIndexPaths:indexPaths];
     }
                                         completion:nil];
}

- (void)editComment:(VComment *)comment
{
    VEditCommentViewController *editViewController = [VEditCommentViewController instantiateFromStoryboardWithComment:comment];
    editViewController.transitioningDelegate = self.modalTransitionDelegate;
    editViewController.delegate = self;
    [self presentViewController:editViewController animated:YES completion:nil];
}

- (void)replyToComment:(VComment *)comment
{
    NSUInteger row = [self.viewModel.comments indexOfObject:comment];
    NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:VContentViewSectionAllComments] ;
    [self.contentCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    
    [self.textEntryView setReplyRecipient:comment.user];
    [self.textEntryView startEditing];
}

#pragma mark - VEditCommentViewControllerDelegate

- (void)didFinishEditingComment:(VComment *)comment
{
    [self dismissViewControllerAnimated:YES completion:^void
     {
         [self.contentCollectionView.visibleCells enumerateObjectsUsingBlock:^(VContentCommentsCell *cell, NSUInteger idx, BOOL *stop)
         {
             if ( [cell isKindOfClass:[VContentCommentsCell class]] && [cell.comment.remoteId isEqualToNumber:comment.remoteId] )
             {
                 // Update the cell's comment to show the new text
                 cell.comment = comment;
                 
                 // Try to reload the cell without reloading the whole section
                 NSIndexPath *indexPathToInvalidate = [self.contentCollectionView indexPathForCell:cell];
                 if ( indexPathToInvalidate != nil )
                 {
                     [self.contentCollectionView performBatchUpdates:^void
                      {
                          [self.contentCollectionView reloadItemsAtIndexPaths:@[ indexPathToInvalidate ]];
                      }
                                                          completion:nil];
                 }
                 else
                 {
                     [self.contentCollectionView reloadSections:[NSIndexSet indexSetWithIndex:VContentViewSectionAllComments] ];
                 }
                 
                 *stop = YES;
             }
         }];
     }];
}

#pragma mark VPurchaseViewControllerDelegate

- (void)purchaseDidFinish:(BOOL)didMakePurchase
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^void
     {
         if ( didMakePurchase )
         {
             [self.viewModel.experienceEnhancerController updateData];
         }
     }];
}

#pragma mark - VScrollPaginatorDelegate

- (void)shouldLoadNextPage
{
    [self.viewModel loadComments:VPageTypeNext];
}

- (void)shouldLoadPreviousPage
{
    [self.viewModel loadComments:VPageTypePrevious];
}

#pragma mark - VEndCardViewControllerDelegate

- (void)replaySelectedFromEndCard:(VEndCardViewController *)endCardViewController
{
    self.likeButton.alpha = 1.0f;
    [self.videoCell seekToStart];
    [endCardViewController transitionOutAllWithBackground:YES completion:^
     {
         [self.videoCell hideEndCard];
         [self.videoCell replay];
    }];
}

- (void)nextSelectedFromEndCard:(VEndCardViewController *)endCardViewController
{
    [endCardViewController transitionOutAllWithBackground:NO completion:nil];
    
    [self.viewModel loadNextSequenceSuccess:^(VSequence *sequence)
     {
         [self showNextSequence:sequence];
         
     }
                                    failure:^(NSError *error)
     {
         [self.videoCell hideEndCard];
         
         [self presentViewController:[VCommentAlertHelper alertForNextSequenceErrorWithDismiss:nil] animated:YES completion:nil];
     }];
}

- (void)actionCellSelected:(VEndCardActionCell *)actionCell atIndex:(NSUInteger)index
{
    [[VTrackingManager sharedInstance] setValue:VTrackingValueEndCard forSessionParameterWithKey:VTrackingKeyContext];
    
    if ( [actionCell.actionIdentifier isEqualToString:VEndCardActionIdentifierGIF] )
    {
        [self.sequenceActionController showRemixOnViewController:self.navigationController
                                                    withSequence:self.viewModel.sequence
                                            andDependencyManager:self.dependencyManager
                                                  preloadedImage:nil
                                                defaultVideoEdit:VDefaultVideoEditGIF
                                                      completion:^(BOOL finished)
         {
             [[VTrackingManager sharedInstance] setValue:VTrackingValueContentView
                              forSessionParameterWithKey:VTrackingKeyContext];
         }];
    }
    else if ( [actionCell.actionIdentifier isEqualToString:VEndCardActionIdentifierMeme] )
    {
        [self.sequenceActionController showRemixOnViewController:self.navigationController
                                                    withSequence:self.viewModel.sequence
                                            andDependencyManager:self.dependencyManager
                                                  preloadedImage:nil
                                                defaultVideoEdit:VDefaultVideoEditSnapshot
                                                      completion:^(BOOL finished)
         {
             [[VTrackingManager sharedInstance] setValue:VTrackingValueContentView
                              forSessionParameterWithKey:VTrackingKeyContext];
         }];
    }
    else if ( [actionCell.actionIdentifier isEqualToString:VEndCardActionIdentifierRepost] )
    {
        [self.sequenceActionController repostActionFromViewController:self.navigationController
                                                                 node:self.viewModel.currentNode
                                                           completion:^(BOOL finished)
         {
             [actionCell showSuccessState];
             actionCell.enabled = NO;
             [[VTrackingManager sharedInstance] setValue:VTrackingValueContentView
                              forSessionParameterWithKey:VTrackingKeyContext];
         }];
    }
    else if ( [actionCell.actionIdentifier isEqualToString:VEndCardActionIdentifierShare] )
    {
        [self.sequenceActionController shareFromViewController:self.navigationController
                                                      sequence:self.viewModel.sequence
                                                          node:self.viewModel.currentNode
                                                    completion:^
         {
             [[VTrackingManager sharedInstance] setValue:VTrackingValueContentView
                              forSessionParameterWithKey:VTrackingKeyContext];
         }];
    }
}

- (void)disableEndcardAutoplay
{
    [self.contentCell disableEndcardAutoplay];
}

- (void)showNextSequence:(VSequence *)nextSequence
{
    VContentViewViewModel *contentViewModel = [[VContentViewViewModel alloc] initWithSequence:nextSequence
                                                                                     streamID:self.viewModel.streamId
                                                                             depenencyManager:self.dependencyManager];
    VNewContentViewController *contentViewController = [VNewContentViewController contentViewControllerWithViewModel:contentViewModel
                                                                                                   dependencyManager:self.dependencyManager];
    
    self.navigationController.delegate = contentViewController;
    contentViewController.transitioningDelegate = self.repopulateTransitionDelegate;
    [self.navigationController pushViewController:contentViewController animated:YES];
}

#pragma mark - VSequenceActionsDelegate

- (void)willCommentOnSequence:(VSequence *)sequenceObject fromView:(UIView *)commentView
{
    [self.sequenceActionController showCommentsFromViewController:self sequence:sequenceObject withSelectedComment:nil];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ( [viewController isKindOfClass:[VNewContentViewController class]] )
    {
        navigationController.viewControllers = @[ navigationController.viewControllers.lastObject ];
    }
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    return [self.repopulateTransitionDelegate navigationController:navigationController
                                   animationControllerForOperation:operation
                                                fromViewController:fromVC
                                                  toViewController:toVC];
}

#pragma mark - NSUserActivityDelegate

- (void)userActivityWasContinued:(NSUserActivity *)userActivity
{
    [self.videoCell pause];
}

#pragma mark - VHashtagSelectionResponder

- (void)hashtagSelected:(NSString *)text
{
    //Tapped a hashtag, show a hashtag view controller
    VHashtagStreamCollectionViewController *hashtagViewController = [self.dependencyManager hashtagStreamWithHashtag:text];
    [self.navigationController pushViewController:hashtagViewController animated:YES];
}

#pragma mark - VURLSelectionResponder

- (void)URLSelected:(NSURL *)URL
{
    VContentViewFactory *contentViewFactory = [self.dependencyManager contentViewFactory];
    UIViewController *webContentView = [contentViewFactory webContentViewControllerWithURL:URL];
    if ( webContentView != nil )
    {
        [self presentViewController:webContentView animated:YES completion:nil];
    }
}

#pragma mark - VCoachmarkDisplayer

- (NSString *)screenIdentifier
{
    return [self.dependencyManager stringForKey:VDependencyManagerIDKey];
}

#pragma mark - VExperienceEnhancerResponder

- (void)showPurchaseViewController:(VVoteType *)voteType
{
    NSDictionary *params = @{ VTrackingKeyProductIdentifier : voteType.productIdentifier ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectLockedVoteType parameters:params];
    
    VPurchaseViewController *viewController = [VPurchaseViewController newWithDependencyManager:self.dependencyManager];
    viewController.voteType = voteType;
    viewController.transitioningDelegate = self.modalTransitionDelegate;
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)authorizeWithCompletion:(void(^)(BOOL))completion
{
    [self.authorizedAction performFromViewController:self context:VAuthorizationContextVoteBallistic completion:^(BOOL authorized)
     {
         if ( completion != nil )
         {
             completion( authorized );
         }
     }];
}

@end
