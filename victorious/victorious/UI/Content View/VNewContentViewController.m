//
//  VNewContentViewController.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "victorious-Swift.h"

#import "NSNumber+VBitmask.h"
#import "UIImage+ImageCreation.h"
#import "UIImageView+Blurring.h"
#import "UIView+AutoLayout.h"
#import "VAbstractCommentHighlighter.h"
#import "VCoachmarkDisplayer.h"
#import "VCoachmarkManager.h"
#import "VCollectionViewCommentHighlighter.h"
#import "VCollectionViewStreamFocusHelper.h"
#import "VComment+Fetcher.h"
#import "VCommentAlertHelper.h"
#import "VCommentTextAndMediaView.h"
#import "VContentBackgroundSupplementaryView.h"
#import "VContentCell.h"
#import "VContentPollBallotCell.h"
#import "VContentPollQuestionCell.h"
#import "VDependencyManager+NavigationBar.h"
#import "VDependencyManager+VTracking.h"
#import "VEditCommentViewController.h"
#import "VElapsedTimeFormatter.h"
#import "VExperienceEnhancer.h"
#import "VExperienceEnhancerBar.h"
#import "VExperienceEnhancerBarCell.h"
#import "VExperienceEnhancerResponder.h"
#import "VHashtagSelectionResponder.h"
#import "VHashtagStreamCollectionViewController.h"
#import "VImageLightboxViewController.h"
#import "VKeyboardInputAccessoryView.h"
#import "VLightboxTransitioningDelegate.h"
#import "VMediaAttachmentPresenter.h"
#import "VNavigationController.h"
#import "VNewContentViewController.h"
#import "VNode+Fetcher.h"
#import "VPurchaseViewController.h"
#import "VScrollPaginator.h"
#import "VSectionHandleReusableView.h"
#import "VSequence+Fetcher.h"
#import "VSequenceActionControllerDelegate.h"
#import "VSequencePreviewViewProtocols.h"
#import "VShrinkingContentLayout.h"
#import "VSimpleModalTransition.h"
#import "VTag.h"
#import "VTagSensitiveTextView.h"
#import "VTextAndMediaView.h"
#import "VTransitionDelegate.h"
#import "VURLSelectionResponder.h"
#import "VUserProfileViewController.h"
#import "VUserTag.h"
#import "VVideoLightboxViewController.h"
#import "VPurchaseManager.h"

@import KVOController;

#define HANDOFFENABLED 0

static NSString * const kPollBallotIconKey = @"orIcon";

@interface VNewContentViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, VKeyboardInputAccessoryViewDelegate, VExperienceEnhancerControllerDelegate, VSwipeViewControllerDelegate, VCommentCellUtilitiesDelegate, VEditCommentViewControllerDelegate, VPurchaseViewControllerDelegate, VContentViewViewModelDelegate, VScrollPaginatorDelegate, NSUserActivityDelegate, VTagSensitiveTextViewDelegate, VHashtagSelectionResponder, VURLSelectionResponder, VCoachmarkDisplayer, VExperienceEnhancerResponder, VUserTaggingTextStorageDelegate, VSequencePreviewViewDetailDelegate, VContentPollBallotCellDelegate, AdLifecycleDelegate, VPaginatedDataSourceDelegate, VImageAnimationOperationDelegate, VSequenceActionControllerDelegate>

@property (nonatomic, assign) BOOL hasAutoPlayed;
@property (nonatomic, assign) BOOL hasBeenPresented;
@property (nonatomic, assign) BOOL shouldResumeEditingAfterClearActionSheet;
@property (nonatomic, assign) BOOL videoPlayerDidFinishPlayingOnce;
@property (nonatomic, assign) BOOL isTransitionComplete;
@property (nonatomic, assign) BOOL videoPlayerWasPlayingOnViewWillDisappear;
@property (nonatomic, assign) CGPoint offsetBeforeLandscape;
@property (nonatomic, assign) CGPoint offsetBeforeRemoval;
@property (nonatomic, strong) NSNumber *realtimeCommentBeganTime;
@property (nonatomic, readwrite, weak) VContentCell *contentCell;
@property (nonatomic, readwrite, weak) VExperienceEnhancerBarCell *experienceEnhancerCell;
@property (nonatomic, strong) NSMutableArray *commentCellReuseIdentifiers;
@property (nonatomic, strong) NSUserActivity *handoffObject;
@property (nonatomic, strong) VCollectionViewCommentHighlighter *commentHighlighter;
@property (nonatomic, strong) VCollectionViewStreamFocusHelper *focusHelper;
@property (nonatomic, strong) VElapsedTimeFormatter *elapsedTimeFormatter;
@property (nonatomic, strong) VMediaAttachmentPresenter *mediaAttachmentPresenter;
@property (nonatomic, strong) VPublishParameters *publishParameters;
@property (nonatomic, strong) VTransitionDelegate *modalTransitionDelegate;
@property (nonatomic, strong, readwrite) VContentViewViewModel *viewModel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingCollectionViewToContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *trailingCollectionViewToContainer;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIButton *moreButton;
@property (nonatomic, weak) IBOutlet UIImageView *blurredBackgroundImageView;
@property (nonatomic, weak) IBOutlet VInputAccessoryCollectionView *contentCollectionView;
@property (nonatomic, weak) IBOutlet VScrollPaginator *scrollPaginator;
@property (nonatomic, weak) NSLayoutConstraint *bottomKeyboardToContainerBottomConstraint;
@property (nonatomic, weak) UIView *snapshotView;
@property (nonatomic, weak) VContentPollBallotCell *ballotCell;
@property (nonatomic, weak) VKeyboardInputAccessoryView *textEntryView;
@property (nonatomic, weak) VSectionHandleReusableView *handleView;
@property (nonatomic, weak) VSequencePreviewView *sequencePreviewView;
@property (nonatomic, strong) VDismissButton *userTaggingDismissButton;
@property (nonatomic, strong) NSOperationQueue *experienceEnhancerCompletionQueue;
@property (nonatomic, strong) VSequenceActionController *sequenceActionController;

@end

@implementation VNewContentViewController

#pragma mark - VSequenceActionControllerDelegate

- (void)sequenceActionControllerDidDeleteSequence:(VSequence *)sequence
{
    [self dismissViewControllerAnimated:true completion:^
    {
        [self.delegate sequenceActionControllerDidDeleteSequence:sequence];
    }];
}

- (void)sequenceActionControllerDidFlagSequence:(VSequence *)sequence
{
    [self dismissViewControllerAnimated:true completion:^
     {
         [self.delegate sequenceActionControllerDidFlagSequence:sequence];
     }];
}

- (void)sequenceActionControllerDidBlockUser:(VUser *)user
{
    [self dismissViewControllerAnimated:true completion:^
     {
         [self.delegate sequenceActionControllerDidBlockUser:user];
     }];
}

#pragma mark - Factory Methods

+ (VNewContentViewController *)contentViewControllerWithViewModel:(VContentViewViewModel *)viewModel
                                                dependencyManager:(VDependencyManager *)dependencyManager
                                                         delegate:(id <VSequenceActionControllerDelegate>)delegate
{
    VNewContentViewController *contentViewController = [[UIStoryboard storyboardWithName:@"ContentView" bundle:nil] instantiateInitialViewController];
    contentViewController.viewModel = viewModel;
    contentViewController.hasAutoPlayed = NO;
    contentViewController.dependencyManager = dependencyManager;
    contentViewController.delegate = delegate;
    contentViewController.sequenceActionController = [[VSequenceActionController alloc] initWithDependencyManager:dependencyManager originViewController:contentViewController delegate:contentViewController];
    
    VSimpleModalTransition *modalTransition = [[VSimpleModalTransition alloc] init];
    contentViewController.modalTransitionDelegate = [[VTransitionDelegate alloc] initWithTransition:modalTransition];
    
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

- (void)didUpdateCommentsWithDeepLink:(NSNumber *)commentId
{
    for ( NSUInteger i = 0; i < self.viewModel.sequence.comments.count; i++ )
    {
        VComment *comment = self.viewModel.sequence.comments[ i ];
        if ( [comment.remoteId isEqualToNumber:commentId] )
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:VContentViewSectionAllComments];
            [self.commentHighlighter scrollToAndHighlightIndexPath:indexPath delay:0.3f completion:^
            {
                // Trigger the paginator to load any more pages based on the scroll
                // position to which VCommentHighlighter animated to
                [self.scrollPaginator scrollViewDidScroll:self.contentCollectionView];
            }];
            break;
        }
    }
}

- (void)didUpdateSequence
{
    [self.sequencePreviewView showLikeButton:YES];
}

- (void)didUpdatePoll
{
    BOOL shouldShowPollResults = !self.viewModel.votingEnabled || [AgeGate isAnonymousUser];
    if ( shouldShowPollResults && !self.isBeingDismissed )
    {
        [self.pollAnswerReceiver setAnswerAPercentage:self.viewModel.answerAPercentage animated:YES];
        [self.pollAnswerReceiver setAnswerBPercentage:self.viewModel.answerBPercentage animated:YES];
        
        VBallot favoredBallot = (self.viewModel.favoredAnswer == VPollAnswerA) ? VBallotA : VBallotB;
        [self.ballotCell setVotingDisabledWithFavoredBallot:favoredBallot animated:YES];
        
        [self.pollAnswerReceiver setAnswerAIsFavored:(self.viewModel.favoredAnswer == VPollAnswerA)];
        [self.pollAnswerReceiver setAnswerBIsFavored:(self.viewModel.favoredAnswer == VPollAnswerB)];
        
        [self.pollAnswerReceiver showResults];
        
        if ( self.viewModel.sequence.permissions.canShowVoteCount )
        {
            [self.pollAnswerReceiver setVoterCountText:self.viewModel.numberOfVotersText];
        }
    }
}

#pragma mark Accessory buttons

- (BOOL)shouldShowAccessoryButtons
{
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
}

- (void)setAccessoryButtonsHidden:(BOOL)hidden
{
    [UIView animateWithDuration:0.25f animations:^
     {
         self.moreButton.alpha = hidden ? 0.0f : 1.0f;
         self.closeButton.alpha = hidden ? 0.0f : 1.0f;
     }];
}

#pragma mark Rotation

- (BOOL)shouldAutorotate
{
    return self.isTransitionComplete;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    BOOL isVideoContent = self.viewModel.type == VContentViewTypeVideo || self.viewModel.type == VContentViewTypeGIFVideo;
    BOOL shouldShowLandscape = isVideoContent && !self.presentedViewController && [self shouldAutorotate];
    return shouldShowLandscape ? UIInterfaceOrientationMaskAllButUpsideDown : UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    __weak typeof(self) welf = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         __strong typeof(welf) strongSelf = welf;
         [strongSelf handleRotationToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
     } completion:nil];
}

- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        [self.textEntryView stopEditing];
        [self.contentCollectionView resignFirstResponder];
        self.offsetBeforeLandscape = self.contentCollectionView.contentOffset;
        
        CGSize cellSize = [VExperienceEnhancerBarCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds
                                                                           dependencyManager:self.dependencyManager];
        CGPoint fixedLandscapeOffset = CGPointMake( 0.0f, cellSize.height );
        self.contentCollectionView.contentOffset = fixedLandscapeOffset;
        self.contentCollectionView.scrollEnabled = NO;
        
        [self setAccessoryButtonsHidden:YES];
    }
    else
    {
        self.contentCollectionView.contentOffset = self.offsetBeforeLandscape;
        [self.contentCollectionView becomeFirstResponder];
        [self setAccessoryButtonsHidden:NO];
        self.contentCollectionView.scrollEnabled = YES;
    }
    
    [self.contentCell handleRotationToInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.closeButton.accessibilityIdentifier = VAutomationIdentifierContentViewCloseButton;
    
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
    
    if (self.viewModel.sequence.permissions.canComment)
    {
        NSDictionary *commentBarConfig = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:@"commentBar"];
        VDependencyManager *commentBarDependencyManager = [[VDependencyManager alloc] initWithParentManager:self.dependencyManager configuration:commentBarConfig dictionaryOfClassesByTemplateName:nil];
        VKeyboardInputAccessoryView *inputAccessoryView = [VKeyboardInputAccessoryView defaultInputAccessoryViewWithDependencyManager:commentBarDependencyManager];
        inputAccessoryView.translatesAutoresizingMaskIntoConstraints = NO;
        inputAccessoryView.delegate = self;
        inputAccessoryView.textStorageDelegate = self;
        inputAccessoryView.accessibilityIdentifier = VAutomationIdentifierContentViewCommentBar;
        inputAccessoryView.sequencePermissions = self.viewModel.sequence.permissions;
        
        self.textEntryView = inputAccessoryView;
        self.contentCollectionView.accessoryView = self.textEntryView;
    }
    
    if ([AgeGate isAnonymousUser])
    {
        self.textEntryView.hidden = YES;
    }
    
    self.contentCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    // Register cells
    [self.contentCollectionView registerClass:[VContentCell class]
                   forCellWithReuseIdentifier:[VContentCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VExperienceEnhancerBarCell nibForCell]
                 forCellWithReuseIdentifier:[VExperienceEnhancerBarCell suggestedReuseIdentifier]];
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
    self.viewModel.commentsDataSource.delegate = self;
    
    self.commentCellReuseIdentifiers = [NSMutableArray new];
    
    [self.viewModel loadNetworkData];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.videoPlayerDidFinishPlayingOnce = NO;
    
    self.experienceEnhancerCompletionQueue = [NSOperationQueue new];
    
    self.experienceEnhancerCompletionQueue.maxConcurrentOperationCount = [[UIDevice currentDevice] v_numberOfConcurrentAnimationsSupported];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager trackViewWillAppear:self];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.contentCollectionView becomeFirstResponder];
    
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
    
    if ( self.navigationController != nil )
    {
        [self.dependencyManager applyStyleToNavigationBar:self.navigationController.navigationBar];
        if ( !self.navigationController.navigationBarHidden )
        {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Calculate content inset on next run loop, otherwise we get a wildly inaccurate frame for our input accessory view
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [self updateInsetsForKeyboardBarState];
    });
    
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
    
    if ( !self.hasBeenPresented )
    {
        self.hasBeenPresented = YES;
        [self trackViewDidStart];
    }
    
    if ( self.isVideoContent && self.videoPlayerWasPlayingOnViewWillDisappear && !self.isBeingPresented )
    {
        [self.videoPlayer play];
    }
    
    [self.contentCollectionView flashScrollIndicators];
    
    // Update cell focus
    [self.focusHelper updateFocus];
    
    // By this point the collectionView should have already queried its dataSource, thus it is safe to calculate
    // its catchPoint and lockPoint.
    VShrinkingContentLayout *layout = (VShrinkingContentLayout *)self.contentCollectionView.collectionViewLayout;
    [layout calculateCatchAndLockPoints];
    
    self.isTransitionComplete = YES;
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //Cancels all animations
    [self.experienceEnhancerCompletionQueue cancelAllOperations];
    
    [self.dependencyManager trackViewWillDisappear:self];
    
    [[self.dependencyManager coachmarkManager] hideCoachmarkViewInViewController:self animated:animated];
    
    if (self.isVideoContent && self.videoPlayer != nil)
    {
        self.videoPlayerWasPlayingOnViewWillDisappear = [self.videoPlayer isPlaying];
        [self.videoPlayer pause];
        if ( self.isBeingDismissed )
        {
            [self.videoPlayer reset];
        }
        
        if ( !self.videoPlayerDidFinishPlayingOnce )
        {
            if ( self.viewModel.trackingData == nil )
            {
                VLog( @"Cannot track events without a valid `trackingData` on sequence: %@", self.viewModel.sequence.remoteId );
                return;
            }
            NSDictionary *params = @{ VTrackingKeyUrls : self.viewModel.trackingData.viewStop ?: @[],
                                      VTrackingKeyStreamId : self.viewModel.streamId,
                                      VTrackingKeyTimeCurrent : @( self.videoPlayer.currentTimeMilliseconds ) };
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventVideoDidStop parameters:params];
        }
    }

    [[VTrackingManager sharedInstance] clearValueForSessionParameterWithKey:VTrackingKeyContentType];
    
    if ( self.isBeingDismissed )
    {
        [[VTrackingManager sharedInstance] clearValueForSessionParameterWithKey:VTrackingKeyContext];
    }
    
#if HANDOFFENABLED
    self.handoffObject.delegate = nil;
    [self.handoffObject invalidate];
#endif
    
    // We don't care about these notifications anymore but we still care about new user loggedin
    [self.contentCollectionView resignFirstResponder];
    
    [self.commentHighlighter stopAnimations];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Stop all video comment cells
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

#pragma mark - Tracking

- (void)trackViewDidStart
{
    if ( self.viewModel.trackingData == nil )
    {
        VLog( @"Cannot track `viewStart` events without a valid `trackingData` on sequence: %@", self.viewModel.sequence.remoteId );
        return;
    }
    NSDictionary *params = @{ VTrackingKeyTimeStamp : [NSDate date],
                              VTrackingKeyStreamId : self.viewModel.streamId,
                              VTrackingKeySequenceId : self.viewModel.sequence.remoteId,
                              VTrackingKeyUrls : self.viewModel.trackingData.viewStart ?: @[],
                              VTrackingKeyTimeCurrent : @( self.videoPlayer.currentTimeMilliseconds ) };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventViewDidStart parameters:params];
}

#pragma mark - IBActions

- (IBAction)pressedClose:(id)sender
{
    [self.contentCollectionView setContentOffset:CGPointZero animated:NO];
    [self.contentCollectionView.collectionViewLayout invalidateLayout];
    [self.contentCell prepareForDismissal];
    [self setAccessoryButtonsHidden:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.sequencePreviewView showLikeButton:NO];
}

- (IBAction)pressedMore:(id)sender
{
    // Pause video when presenting action sheet
    if (self.viewModel.type == VContentViewTypeVideo)
    {
        [self.videoPlayer pause];
    }
    [self.sequenceActionController showMoreWithSequence:self.viewModel.sequence
                                               streamId:self.viewModel.streamId
                                             completion:nil];
}

#pragma mark - Private Mehods

- (NSDictionary *)attributesForPollQuestion
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    return @{
             NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading2FontKey],
             NSForegroundColorAttributeName: [UIColor whiteColor],
             NSParagraphStyleAttributeName: paragraphStyle
             };
}

- (void)updateInsetsForKeyboardBarState
{
    // Adjust focus area for keyboard bar
    CGRect obscuredRectInWindow = [self.textEntryView obscuredRectInWindow:self.view.window];
    CGRect obscuredRectInOwnView = [self.view.window convertRect:obscuredRectInWindow toView:self.view];
    CGFloat bottomObscuredSize = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(obscuredRectInOwnView);
    if ([AgeGate isAnonymousUser])
    {
        bottomObscuredSize = 0.0f;
    }
    self.contentCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(VShrinkingContentLayoutMinimumContentHeight, 0, bottomObscuredSize, 0);
    self.contentCollectionView.contentInset = UIEdgeInsetsMake(0, 0, bottomObscuredSize, 0);
    [self.focusHelper setFocusAreaInsets:UIEdgeInsetsMake(0, 0, bottomObscuredSize, 0)];
}

- (NSIndexPath *)indexPathForContentView
{
    return [NSIndexPath indexPathForRow:0
                              inSection:VContentViewSectionContent];
}

- (void)configureCommentCell:(VContentCommentsCell *)commentCell withIndex:(NSInteger)index
{
    commentCell.dependencyManager = self.dependencyManager;
    commentCell.comment = self.viewModel.commentsDataSource.visibleItems[ index ];
    commentCell.commentAndMediaView.textView.tagTapDelegate = self;
    commentCell.swipeViewController.controllerDelegate = self;
    commentCell.commentsUtilitiesDelegate = self;
    
    __weak typeof(commentCell) wCommentCell = commentCell;
    __weak typeof(self) welf = self;
    [commentCell.commentAndMediaView setOnMediaTapped:^(UIImage *previewImage)
     {
         // Preview image hasn't loaded yet, do not try and show lightbox
         if (previewImage == nil)
         {
             return;
         }
         
         [welf showLightBoxWithMediaURL:[wCommentCell.comment properMediaURLGivenContentType]
                           previewImage:previewImage
                                isVideo:wCommentCell.mediaIsVideo
                             sourceView:wCommentCell.commentAndMediaView];
     }];
    
    commentCell.onUserProfileTapped = ^(void)
    {
        UIViewController *profileViewController = [welf.dependencyManager userProfileViewControllerFor:wCommentCell.comment.user];
        [welf.navigationController pushViewController:profileViewController animated:YES];
    };
}

- (void)tagSensitiveTextView:(VTagSensitiveTextView *)tagSensitiveTextView tappedTag:(VTag *)tag
{
    if ( [tag isKindOfClass:[VUserTag class]] )
    {
        //Tapped a user tag, show a profile view controller
        UIViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithRemoteID:((VUserTag *)tag).remoteId];
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
    if ( isVideo )
    {
        lightbox = [[VVideoLightboxViewController alloc] initWithPreviewImage:previewImage videoURL:mediaURL];
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
            [welf.contentCollectionView.collectionViewLayout invalidateLayout];
            [welf dismissViewControllerAnimated:YES completion:^
             {
                 [[welf class] attemptRotationToDeviceOrientation];
             }];
        }
    };
    if ([lightbox isKindOfClass:[VVideoLightboxViewController class]])
    {
        ((VVideoLightboxViewController *) lightbox).onVideoFinished = lightbox.onCloseButtonTapped;
    }
    [VLightboxTransitioningDelegate addNewTransitioningDelegateToLightboxController:lightbox referenceView:sourceView];
    
    [welf presentViewController:lightbox  animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    VContentViewSection vSection = section;
    
    if ([AgeGate isAnonymousUser])
    {
        switch (vSection)
        {
            case VContentViewSectionContent:
                return 1;
                break;
            case VContentViewSectionPollQuestion:
            case VContentViewSectionExperienceEnhancers:
                return 0;
                break;
            case VContentViewSectionAllComments:
                return (NSInteger)self.viewModel.commentsDataSource.visibleItems.count;
                break;
            case VContentViewSectionCount:
                return 0;
                break;
        }
    }
    
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
            return (NSInteger)self.viewModel.commentsDataSource.visibleItems.count;
        case VContentViewSectionCount:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return VContentViewSectionCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VContentViewSection vSection = indexPath.section;
    switch (vSection)
    {
        case VContentViewSectionContent:
        {
            self.contentCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentCell suggestedReuseIdentifier]
                                                                         forIndexPath:indexPath];

            ContentCellSetupHelper *setupHelper = [[ContentCellSetupHelper alloc] init];
            ContentCellSetupResult *result;
            id<VContentPreviewViewProvider> provider = (id<VContentPreviewViewProvider>)self.viewModel.context.contentPreviewProvider;
            if (provider != nil)
            {
                result = [setupHelper setupWithContentCell:self.contentCell
                                       previewViewProvider:provider
                                                adDelegate:self
                                            detailDelegate:self
                                  videoPreviewViewDelegate:self
                                                   adBreak:self.viewModel.sequence.adBreak];
            }
            else
            {
                result = [setupHelper setupWithContentCell:self.contentCell
                                                adDelegate:self
                                            detailDelegate:self
                                  videoPreviewViewDelegate:self
                                                   adBreak:self.viewModel.sequence.adBreak
                                                  sequence:self.viewModel.context.sequence
                                         dependencyManager:self.dependencyManager];
            }
            self.sequencePreviewView = result.previewView;
            self.videoPlayer = result.videoPlayer;
            if ( [self.sequencePreviewView conformsToProtocol:@protocol(VPollResultReceiver)] )
            {
                self.pollAnswerReceiver = (id<VPollResultReceiver>)self.sequencePreviewView;
            }
            return self.contentCell;
        }
        case VContentViewSectionPollQuestion:
        {
            VContentPollQuestionCell *questionCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentPollQuestionCell suggestedReuseIdentifier] forIndexPath:indexPath];
            questionCell.question = [[NSAttributedString alloc] initWithString:self.viewModel.sequence.name ?: @"" attributes:[self attributesForPollQuestion]];
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

                self.ballotCell.answerA = [[NSAttributedString alloc] initWithString:self.viewModel.answerALabelText
                                                                          attributes:@{NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey]}];
                self.ballotCell.answerB = [[NSAttributedString alloc] initWithString:self.viewModel.answerBLabelText
                                                                          attributes:@{NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey]}];
                self.ballotCell.delegate = self;
                self.ballotCell.orImageView.image = [self.dependencyManager imageForKey:kPollBallotIconKey];
                
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
            
            __weak typeof(self) welf = self;
            self.experienceEnhancerCell.experienceEnhancerBar.selectionBlock = ^(VExperienceEnhancer *selectedEnhancer, CGPoint selectionCenter)
            {
                [welf showExperienceEnhancer:selectedEnhancer atPosition:selectionCenter];
            };
            
            return self.experienceEnhancerCell;
        }
        case VContentViewSectionAllComments:
        {
            VComment *comment = self.viewModel.commentsDataSource.visibleItems[indexPath.row];
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
            
            return self.handleView;
        }
        case VContentViewSectionCount:
            return nil;
    }
}

- (void)setHandleView:(VSectionHandleReusableView *)handleView
{
    VSectionHandleReusableView *oldValue = _handleView;
    _handleView = handleView;
    
    if ( oldValue != nil )
    {
        [self.KVOController unobserve:self.viewModel.sequence
                              keyPath:@"commentCount"];
    }
    if ( _handleView != nil )
    {
        [self.KVOController observe:self.viewModel.sequence
                            keyPath:@"commentCount"
                            options:NSKeyValueObservingOptionInitial
                             action:@selector(commentCountUpdated:)];
    }
}

- (void)commentCountUpdated:(NSDictionary *)change
{
    self.handleView.numberOfComments = self.viewModel.sequence.commentCount.integerValue;
}

- (void)showExperienceEnhancer:(VExperienceEnhancer *)enhancer atPosition:(CGPoint)position
{
    VImageAnimationOperation *animationOp = [[VImageAnimationOperation alloc] init];
    animationOp.animationDuration = enhancer.animationDuration;
    animationOp.delegate = self;
    UIImageView *animationImageView;
    
    if (enhancer.isBallistic)
    {
        animationImageView = [[UIImageView alloc] init];
        
        CGRect animationBounds = self.contentCell.bounds;
        CGPoint convertedCenterForAnimation = [self.experienceEnhancerCell.experienceEnhancerBar convertPoint:position toView:self.view];

        animationImageView.image = enhancer.voteType.iconImage;
        animationImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        /// Animate to here
        CGFloat randomLocationX = arc4random_uniform(CGRectGetWidth(animationBounds));
        CGFloat randomLocationY = arc4random_uniform(CGRectGetHeight(animationBounds));
        CGPoint newCenter = CGPointMake(randomLocationX, randomLocationY);
        CGFloat flightDuration = enhancer.flightDuration;
        
        __weak typeof(animationOp) weakAnimationOp = animationOp;
        
        typedef void (^CompletionBlock)();
        animationOp.ballisticAnimationBlock = ^void(CompletionBlock completion)
        {
            
            UIImage *iconImage = [weakAnimationOp.animationSequence firstObject];
            CGRect animationFrameSize = CGRectMake(0, 0, iconImage.size.width, iconImage.size.height);
            
            animationImageView.frame = animationFrameSize;
            animationImageView.center = convertedCenterForAnimation;

            
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [UIView animateWithDuration:flightDuration
                                                animations:^
                                {
                                    animationImageView.center = newCenter;
                                }
                                                completion:^(BOOL finished)
                                {
                                    completion();
                                }];
                           });
        };
    }
    else
    {
        animationImageView = [[UIImageView alloc] initWithFrame:self.contentCell.bounds];
        animationImageView.contentMode = enhancer.voteType.contentMode;
    }
    animationOp.animationImageView = animationImageView;
    
    __weak typeof(self) welf = self;
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *images = enhancer.voteType.images;
        dispatch_async(dispatch_get_main_queue(), ^{
            animationOp.animationSequence = images;
            [welf animationOperationDidFinishLoadingDependencies:animationOp];
        });
    });
}

- (void)animationOperationDidFinishLoadingDependencies:(VImageAnimationOperation *)animationOp
{
    [self.contentCell.contentView addSubview:animationOp.animationImageView];
    [self.experienceEnhancerCompletionQueue addOperation:animationOp];
}

#pragma mark - VImageAnimationOperationDelegate

- (void)animation:(VImageAnimationOperation *)animation didFinishAnimating:(BOOL)completed
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [animation.animationImageView removeFromSuperview];
                   });
}

- (void)animation:(VImageAnimationOperation *)animation updatedToImage:(UIImage *)image
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       animation.animationImageView.image = image;
                   });
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    const BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    VContentViewSection vSection = indexPath.section;
    
    switch (vSection)
    {
        case VContentViewSectionContent:
        {
            if ( isLandscape )
            {
                // Match width and height for full screen
                return self.view.bounds.size;
            }
            else
            {
                // Match width and keep 1:1 aspect
                return CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds));
            }
        }
        case VContentViewSectionPollQuestion:
            return  [VContentPollQuestionCell actualSizeWithQuestion:self.viewModel.sequence.name
                                                          attributes:[self attributesForPollQuestion]
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
            else
            {
                CGSize experienceEnhancerSize = [VExperienceEnhancerBarCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds
                                                                                              dependencyManager:self.dependencyManager];
                return experienceEnhancerSize;
            }
        }
        case VContentViewSectionAllComments:
        {
            const CGFloat minBound = MIN( CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) );
            VComment *comment = self.viewModel.commentsDataSource.visibleItems[indexPath.row];
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
            CGSize sizeWithComments = [VSectionHandleReusableView desiredSizeWithCollectionViewBounds:collectionView.bounds];
            return self.viewModel.commentsDataSource.visibleItems.count > 0 ? sizeWithComments : CGSizeZero;
        }
        case VContentViewSectionCount:
            return CGSizeZero;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    const BOOL isContentSection = [indexPath compare:[self indexPathForContentView]] == NSOrderedSame;
    const BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    if ( !isLandscape && isContentSection )
    {
        [self.contentCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
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
    const BOOL hasComments = self.viewModel.commentsDataSource.visibleItems.count > 0;
    if ( hasComments )
    {
        if ( !self.commentHighlighter.isAnimatingCellHighlight )
        {
            [self.scrollPaginator scrollViewDidScroll:scrollView];
        }
    }
    
    // Update focus on cells
    [self.focusHelper updateFocus];
}

#pragma mark - VKeyboardInputAccessoryViewDelegate

- (void)pressedSendOnKeyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView
{
    [self.viewModel addCommentWithText:inputAccessoryView.composedText
                     publishParameters:self.publishParameters
                           currentTime:self.realtimeCommentBeganTime];
    
    [inputAccessoryView clearTextAndResign];
    self.publishParameters.mediaToUploadURL = nil;
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
    [self addMediaToCommentWithAttachmentType:attachmentType];
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
    
    if ( self.viewModel.type == VContentViewTypeVideo )
    {
        self.realtimeCommentBeganTime = [NSNumber numberWithFloat:[self currentVideoTime]];
    }
}

#pragma mark - VUserTaggingTextStorageDelegate

- (void)userTaggingTextStorage:(VUserTaggingTextStorage *)textStorage wantsToDismissViewController:(UITableViewController *)tableViewController
{
    [self.userTaggingDismissButton removeFromSuperview];
    [tableViewController.view removeFromSuperview];
    self.textEntryView.attachmentsBarHidden = NO;
}

- (void)userTaggingTextStorage:(VUserTaggingTextStorage *)textStorage wantsToShowViewController:(UIViewController *)viewController
{
    self.textEntryView.attachmentsBarHidden = YES;

    // Inline Search layout constraints
    UIView *searchTableView = viewController.view;
    [searchTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:searchTableView];
    
    UIWindow *ownWindow = self.view.window;
    CGRect obscuredRectInWindow = [self.textEntryView obscuredRectInWindow:ownWindow];
    CGRect obscuredRectInOwnView = [ownWindow convertRect:obscuredRectInWindow toView:self.view];
    CGFloat obscuredBottom = CGRectGetHeight(self.view.bounds) - CGRectGetMinY( obscuredRectInOwnView);
    [self.view v_addFitToParentConstraintsToSubview:searchTableView leading:0.0f trailing:0.0f top:0.0f bottom:obscuredBottom];
    
    [self.view addSubview:self.userTaggingDismissButton];
    CGFloat dismissButtonMarginToBorder = 8.0f;
    [self.view v_addPinToTopToSubview:self.userTaggingDismissButton topMargin:dismissButtonMarginToBorder];
    [self.view v_addPinToTrailingEdgeToSubview:self.userTaggingDismissButton trailingMargin:dismissButtonMarginToBorder];
    [self.userTaggingDismissButton addTarget:self.textEntryView action:@selector(stopEditing) forControlEvents:UIControlEventTouchUpInside];
}

- (VDismissButton *)userTaggingDismissButton
{
    if (_userTaggingDismissButton != nil)
    {
        return _userTaggingDismissButton;
    }
    
    _userTaggingDismissButton = [[VDismissButton alloc] init];
    
    return _userTaggingDismissButton;
}

#pragma mark - Comment Text Helpers

- (void)clearEditingRealTimeComment
{
    self.realtimeCommentBeganTime = nil;
}

- (void)reloadComments
{
    [self.viewModel.commentsDataSource loadComments:VPageTypeFirst completion:nil];
}

- (void)addMediaToCommentWithAttachmentType:(VKeyboardBarAttachmentType)attachmentType
{
    [self.textEntryView stopEditing];
    
    self.mediaAttachmentPresenter = [[VMediaAttachmentPresenter alloc] initWithDependencyManager:self.dependencyManager];
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

#pragma mark - VExperienceEnhancerControllerDelegate

- (void)experienceEnhancersDidUpdate
{
    NSInteger section = VContentViewSectionExperienceEnhancers;
    if ( section < [self.contentCollectionView numberOfSections] )
    {
        [self.contentCollectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
    }
}

- (BOOL)isVideoContent
{
    return self.viewModel.type == VContentViewTypeGIFVideo || self.viewModel.type == VContentViewTypeVideo;
}

- (Float64)currentVideoTime
{
    id<VVideoPlayer> videoPlayer = self.videoPlayer;
    
    if (videoPlayer != nil)
    {
        if (videoPlayer.currentTimeSeconds > 0.0f)
        {
            return videoPlayer.currentTimeSeconds;
        }
        else if (self.videoPlayerDidFinishPlayingOnce)
        {
            return videoPlayer.durationSeconds;
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

- (void)editComment:(VComment *)comment
{
    VEditCommentViewController *editViewController = [VEditCommentViewController newWithComment:comment dependencyManager:self.dependencyManager];
    editViewController.transitioningDelegate = self.modalTransitionDelegate;
    editViewController.delegate = self;
    [self presentViewController:editViewController animated:YES completion:nil];
}

- (void)replyToComment:(VComment *)comment
{
    NSUInteger row = [self.viewModel.commentsDataSource.visibleItems indexOfObject:comment];
    NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:VContentViewSectionAllComments] ;
    [self.contentCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    
    [self.textEntryView setReplyRecipient:comment.user];
    [self.textEntryView startEditing];
}

- (void)deleteComment:(VComment *)comment
{
    NSInteger commentID = comment.remoteId.integerValue;
    CommentDeleteOperation *operation = [[CommentDeleteOperation alloc] initWithCommentID: commentID removalReason:nil];
    [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
     {
         [self.viewModel.commentsDataSource removeDeletedItems];
     }];
}

- (void)flagComment:(VComment *)comment
{
    NSInteger commentID = comment.remoteId.integerValue;
    CommentFlagOperation *operation = [[CommentFlagOperation alloc] initWithCommentID: commentID];
    [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
     {
         [self.viewModel.commentsDataSource removeDeletedItems];
         [self v_showFlaggedCommentAlertWithCompletion:nil];
     }];
}

#pragma mark - VEditCommentViewControllerDelegate

- (void)didFinishEditingComment:(VComment *)comment
{
    [self dismissViewControllerAnimated:YES completion:^void
     {
         for ( VContentCommentsCell *cell in self.contentCollectionView.visibleCells)
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
                 break;
             }
         }
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
    [self.viewModel.commentsDataSource loadComments:VPageTypeNext completion:nil];
}

- (void)shouldLoadPreviousPage
{
}

#pragma mark - VSequenceActionsDelegate

- (void)willCommentOnSequence:(VSequence *)sequenceObject fromView:(UIView *)commentView
{
    [self.sequenceActionController showCommentsWithSequence:sequenceObject];
}

#pragma mark - NSUserActivityDelegate

- (void)userActivityWasContinued:(NSUserActivity *)userActivity
{
    if ( self.isVideoContent )
    {
        [self.videoPlayer pause];
    }
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

#pragma mark - VSequencePreviewViewDetailDelegate

- (void)previewView:(VSequencePreviewView *)previewView didSelectMediaURL:(NSURL *)mediaURL previewImage:(UIImage *)previewImage isVideo:(BOOL)isVideo sourceView:(UIView *)sourceView
{
    [self showLightBoxWithMediaURL:mediaURL previewImage:previewImage isVideo:isVideo sourceView:sourceView];
}

- (void)previewView:(VSequencePreviewView *)previewView didLikeSequence:(VSequence *)sequence completion:(void(^)(BOOL))completion
{
    [self.sequenceActionController likeSequence:self.viewModel.sequence
                                 triggeringView:previewView.likeButton
                                     completion:^(BOOL success)
     {
         if ( completion != nil )
         {
             completion(success);
         }
     }];
}

#pragma mark - VContentPollBallotCellDelegate

- (void)answerASelected
{
    [self.viewModel answerPoll:VPollAnswerA completion:^(NSError *_Nullable error)
    {
        if ( error == nil )
        {
            [self didUpdatePoll];
        }
    }];
}

- (void)answerBSelected
{
    [self.viewModel answerPoll:VPollAnswerB completion:^(NSError *_Nullable error)
     {
         if ( error == nil )
         {
             [self didUpdatePoll];
         }
     }];
}

#pragma mark - VVideoPreviewViewDelegate

- (void)animateAlongsideVideoToolbarWillAppear
{
    if ( [self shouldShowAccessoryButtons] )
    {
        self.closeButton.alpha = 1.0f;
        self.moreButton.alpha = 1.0f;
    }
}

- (void)animateAlongsideVideoToolbarWillDisappear
{
    if ( !self.contentCell.isPlayingAd)
    {
        self.closeButton.alpha = 0.0f;
        self.moreButton.alpha = 0.0f;
    }
}

- (void)videoPlaybackDidFinish
{
    self.videoPlayerDidFinishPlayingOnce = YES;
}

#pragma mark - AdLifecycleDelegate

- (void)adDidLoad
{
}

- (void)adHadError:(NSError *)error
{
    VLog(@"Failed had an error, recovering to the normal state");
    [self enableCommentsAndExperienceEnhancers];
}

- (void)adDidFinish
{
    [self enableCommentsAndExperienceEnhancers];
}

- (void)adDidStart
{
    self.closeButton.alpha = 1.0f;
    self.textEntryView.userInteractionEnabled = NO;
    [UIView animateWithDuration:kExperienceEnhancerFadeAnimationDuration animations:^{
        self.experienceEnhancerCell.experienceEnhancerBar.enabled = NO;
    }];
}

- (void)enableCommentsAndExperienceEnhancers
{
    self.textEntryView.userInteractionEnabled = true;
    [UIView animateWithDuration:kExperienceEnhancerFadeAnimationDuration animations:^{
        self.experienceEnhancerCell.experienceEnhancerBar.enabled = YES;
    }];
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    /// Cancels all animations/setup
    [self.experienceEnhancerCompletionQueue cancelAllOperations];
    
}

#pragma mark - VPaginatedDataSourceDelegate

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didUpdateVisibleItemsFrom:(NSOrderedSet *)oldValue to:(NSOrderedSet *)newValue
{
    if ( paginatedDataSource != self.viewModel.commentsDataSource )
    {
        return;
    }
    [self.contentCollectionView v_applyChangeInSection:VContentViewSectionAllComments from:oldValue to:newValue];
}

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didReceiveError:(NSError *)error
{
    [self v_showErrorDefaultError];
}

@end
