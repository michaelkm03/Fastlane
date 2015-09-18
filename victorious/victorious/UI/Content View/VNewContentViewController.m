//
//  VNewContentViewController.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "victorious-Swift.h"

#import "UIActionSheet+VBlocks.h"
#import "UIImage+ImageCreation.h"
#import "UIImageView+Blurring.h"
#import "UIView+AutoLayout.h"
#import "VAbstractCommentHighlighter.h"
#import "VAuthorizedAction.h"
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
#import "VContentViewFactory.h"
#import "VDependencyManager+VCoachmarkManager.h"
#import "VDependencyManager+VTabScaffoldViewController.h"
#import "VDependencyManager+VTracking.h"
#import "VDependencyManager+VUserProfile.h"
#import "VEditCommentViewController.h"
#import "VElapsedTimeFormatter.h"
#import "VEndCard.h"
#import "VEndCardActionModel.h"
#import "VExperienceEnhancer.h"
#import "VExperienceEnhancerBar.h"
#import "VExperienceEnhancerBarCell.h"
#import "VExperienceEnhancerResponder.h"
#import "VHashtagSelectionResponder.h"
#import "VHashtagStreamCollectionViewController.h"
#import "VImageLightboxViewController.h"
#import "VInlineSearchTableViewController.h"
#import "VKeyboardInputAccessoryView.h"
#import "VLightboxTransitioningDelegate.h"
#import "VMediaAttachmentPresenter.h"
#import "VNavigationController.h"
#import "VNewContentViewController.h"
#import "VNode+Fetcher.h"
#import "VObjectManager+ContentCreation.h"
#import "VObjectManager+Login.h"
#import "VPurchaseViewController.h"
#import "VScrollPaginator.h"
#import "VSectionHandleReusableView.h"
#import "VSequence+Fetcher.h"
#import "VSequenceActionController.h"
#import "VSequencePreviewViewProtocols.h"
#import "VShrinkingContentLayout.h"
#import "VSimpleModalTransition.h"
#import "VTag.h"
#import "VTagSensitiveTextView.h"
#import "VTextAndMediaView.h"
#import "VTracking.h"
#import "VTransitionDelegate.h"
#import "VURLSelectionResponder.h"
#import "VUserProfileViewController.h"
#import "VUserTag.h"
#import "VVideoLightboxViewController.h"

#define HANDOFFENABLED 0

static NSString * const kPollBallotIconKey = @"orIcon";

@interface VNewContentViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UINavigationControllerDelegate, VKeyboardInputAccessoryViewDelegate, VExperienceEnhancerControllerDelegate, VSwipeViewControllerDelegate, VCommentCellUtilitiesDelegate, VEditCommentViewControllerDelegate, VPurchaseViewControllerDelegate, VContentViewViewModelDelegate, VScrollPaginatorDelegate, VEndCardViewControllerDelegate, NSUserActivityDelegate, VTagSensitiveTextViewDelegate, VHashtagSelectionResponder, VURLSelectionResponder, VCoachmarkDisplayer, VExperienceEnhancerResponder, VUserTaggingTextStorageDelegate, VSequencePreviewViewDetailDelegate, VContentPollBallotCellDelegate, VVideoSequenceDelegate>

@property (nonatomic, assign) BOOL enteringRealTimeComment;
@property (nonatomic, assign) BOOL hasAutoPlayed;
@property (nonatomic, assign) BOOL hasBeenPresented;
@property (nonatomic, assign) BOOL shouldResumeEditingAfterClearActionSheet;
@property (nonatomic, assign) BOOL videoPlayerDidFinishPlayingOnce;
@property (nonatomic, assign) CGPoint offsetBeforeLandscape;
@property (nonatomic, assign) CGPoint offsetBeforeRemoval;
@property (nonatomic, assign) Float64 realtimeCommentBeganTime;
@property (nonatomic, readwrite, weak) VContentCell *contentCell;
@property (nonatomic, readwrite, weak) VExperienceEnhancerBarCell *experienceEnhancerCell;
@property (nonatomic, strong) NSMutableArray *commentCellReuseIdentifiers;
@property (nonatomic, strong) NSUserActivity *handoffObject;
@property (nonatomic, strong) VAuthorizedAction *authorizedAction;
@property (nonatomic, strong) VCollectionViewCommentHighlighter *commentHighlighter;
@property (nonatomic, strong) VCollectionViewStreamFocusHelper *focusHelper;
@property (nonatomic, strong) VElapsedTimeFormatter *elapsedTimeFormatter;
@property (nonatomic, strong) VMediaAttachmentPresenter *mediaAttachmentPresenter;
@property (nonatomic, strong) VPublishParameters *publishParameters;
@property (nonatomic, strong) VStreamItemPreviewView *nextSequencePreviewView;
@property (nonatomic, strong) VTransitionDelegate *endcardNextTransitionDelegate;
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
@property (nonatomic, weak, readwrite) IBOutlet VSequenceActionController *sequenceActionController;

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
    ContentViewNextTransition *endcardNextTransition = [[ContentViewNextTransition alloc] init];
    contentViewController.endcardNextTransitionDelegate = [[VTransitionDelegate alloc] initWithTransition:endcardNextTransition];
    
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
    if ( self.viewModel.monetizationPartner != VMonetizationPartnerNone )
    {
        [self.contentCell playAd:self.viewModel.monetizationPartner
                         details:self.viewModel.monetizationDetails];
    }
}

- (void)didUpdatePollsData
{
    if ( !self.viewModel.votingEnabled && !self.isBeingDismissed )
    {
        [self.pollAnswerReceiver setAnswerAPercentage:self.viewModel.answerAPercentage animated:YES];
        [self.pollAnswerReceiver setAnswerBPercentage:self.viewModel.answerBPercentage animated:YES];
        
        VBallot favoredBallot = (self.viewModel.favoredAnswer == VPollAnswerA) ? VBallotA : VBallotB;
        [self.ballotCell setVotingDisabledWithFavoredBallot:favoredBallot animated:YES];
        
        [self.pollAnswerReceiver setAnswerAIsFavored:(self.viewModel.favoredAnswer == VPollAnswerA)];
        [self.pollAnswerReceiver setAnswerBIsFavored:(self.viewModel.favoredAnswer == VPollAnswerB)];
        
        [self.pollAnswerReceiver showResultsAnimated:YES];
    }
}

#pragma mark Rotation

- (BOOL)shouldAutorotate
{
    return self.viewModel.type == VContentViewTypeVideo || self.viewModel.type == VContentViewTypeGIFVideo;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self shouldAutorotate] ? UIInterfaceOrientationMaskAllButUpsideDown : UIInterfaceOrientationMaskPortrait;
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
        
        
        if ( !self.contentCell.isEndCardShowing )
        {
            [self setAccessoryButtonsHidden:YES];
        }
        self.contentCollectionView.scrollEnabled = NO;
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
        inputAccessoryView.sequencePermissions = self.viewModel.sequence.permissions;
        
        self.textEntryView = inputAccessoryView;
        self.contentCollectionView.accessoryView = self.textEntryView;
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
    
    self.commentCellReuseIdentifiers = [NSMutableArray new];
    
    [self.viewModel reloadData];
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self didUpdateCommentsWithPageType:VPageTypeFirst];
    [self.dependencyManager trackViewWillAppear:self];
    
    
    [self.navigationController setNavigationBarHidden:YES
                                             animated:YES];
    
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
    
    [self trackVideoViewStart];
    
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
    
    if ( !self.hasBeenPresented && self.isVideoContent )
    {
        self.hasBeenPresented = YES;
        [self trackNonVideoViewStart];
    }
    
    [self.contentCollectionView flashScrollIndicators];
    
    // Update cell focus
    [self.focusHelper updateFocus];
    
    // By this point the collectionView should have already queried its dataSource, thus it is safe to calculate
    // its catchPoint and lockPoint.
    VShrinkingContentLayout *layout = (VShrinkingContentLayout *)self.contentCollectionView.collectionViewLayout;
    [layout calculateCatchAndLockPoints];
    
    self.experienceEnhancerCell.experienceEnhancerBar.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
    
    [[self.dependencyManager coachmarkManager] hideCoachmarkViewInViewController:self animated:animated];
    
    if ( self.isVideoContent && self.videoPlayer != nil)
    {
        NSDictionary *params = @{ VTrackingKeyUrls : self.viewModel.sequence.tracking.viewStop ?: @[],
                                  VTrackingKeyStreamId : self.viewModel.streamId,
                                  VTrackingKeyTimeCurrent : @( self.videoPlayer.currentTimeMilliseconds ) };
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

- (void)trackNonVideoViewStart
{
    NSDictionary *params = @{ VTrackingKeyTimeStamp : [NSDate date],
                              VTrackingKeyStreamId : self.viewModel.streamId,
                              VTrackingKeySequenceId : self.viewModel.sequence.remoteId,
                              VTrackingKeyUrls : self.viewModel.sequence.tracking.viewStart ?: @[],
                              VTrackingKeyTimeCurrent : @( self.videoPlayer.currentTimeMilliseconds ) };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventViewDidStart parameters:params];
}

- (void)trackVideoViewStart
{
    NSDictionary *params = @{ VTrackingKeyTimeStamp : [NSDate date],
                              VTrackingKeyStreamId : self.viewModel.streamId,
                              VTrackingKeySequenceId : self.viewModel.sequence.remoteId,
                              VTrackingKeyUrls : self.viewModel.sequence.tracking.viewStart ?: @[],
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
}

- (void)setAccessoryButtonsHidden:(BOOL)hidden
{
    [UIView animateWithDuration:0.25f animations:^
     {
         self.moreButton.alpha = hidden ? 0.0f : 1.0f;
         self.closeButton.alpha = hidden ? 0.0f : 1.0f;
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

- (void)updateInitialExperienceEnhancerState
{
    VExperienceEnhancerBar *enhancerBar = self.viewModel.experienceEnhancerController.enhancerBar;
    if ( enhancerBar != nil )
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VContentViewSection vSection = indexPath.section;
    switch (vSection)
    {
        case VContentViewSectionContent:
        {
            self.contentCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentCell suggestedReuseIdentifier]
                                                                         forIndexPath:indexPath];
            self.contentCell.minSize = CGSizeMake( self.contentCell.minSize.width, VShrinkingContentLayoutMinimumContentHeight );
            self.contentCell.endCardDelegate = self;
            
            if ( self.nextSequencePreviewView != nil )
            {
                id<VContentPreviewViewReceiver> receiver = (id<VContentPreviewViewReceiver>)self.contentCell;
                UIView *superview = [receiver getTargetSuperview];
                self.nextSequencePreviewView.frame = superview.bounds;
                [superview addSubview:self.nextSequencePreviewView];
                [superview v_addFitToParentConstraintsToSubview:self.nextSequencePreviewView];
                if ( [self.nextSequencePreviewView conformsToProtocol:@protocol(VVideoPreviewView)] )
                {
                    id<VVideoPlayer> videoPlayer = ((id<VVideoPreviewView>)self.nextSequencePreviewView).videoPlayer;
                    [receiver setVideoPlayer:videoPlayer];
                }
            }
            
            return self.contentCell;
        }
        case VContentViewSectionPollQuestion:
        {
            VContentPollQuestionCell *questionCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentPollQuestionCell suggestedReuseIdentifier] forIndexPath:indexPath];
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
            
            [self updateInitialExperienceEnhancerState];
            
            self.experienceEnhancerCell.experienceEnhancerBar.selectionBlock = ^(VExperienceEnhancer *selectedEnhancer, CGPoint selectionCenter)
            {
                [self showExperienceEnhancer:selectedEnhancer atPosition:selectionCenter];
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

- (void)showExperienceEnhancer:(VExperienceEnhancer *)enhancer atPosition:(CGPoint)position
{
    if ( enhancer.isBallistic )
    {
        CGRect animationFrameSize = CGRectMake(0, 0, enhancer.flightImage.size.width, enhancer.flightImage.size.height);
        UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:animationFrameSize];
        animationImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CGPoint convertedCenterForAnimation = [self.experienceEnhancerCell.experienceEnhancerBar convertPoint:position toView:self.view];
        animationImageView.center = convertedCenterForAnimation;
        animationImageView.image = enhancer.flightImage;
        [self.view addSubview:animationImageView];
        
        [UIView animateWithDuration:enhancer.flightDuration
                              delay:0.0f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^
         {
             CGFloat randomLocationX = arc4random_uniform(CGRectGetWidth(self.contentCell.frame));
             CGFloat randomLocationY = arc4random_uniform(CGRectGetHeight(self.contentCell.frame));
             animationImageView.center = CGPointMake(randomLocationX, randomLocationY);
         }
                         completion:^(BOOL finished)
         {
             animationImageView.animationDuration = enhancer.animationDuration;
             animationImageView.animationImages = enhancer.animationSequence;
             animationImageView.animationRepeatCount = 1;
             animationImageView.image = nil;
             [animationImageView startAnimating];
             
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(enhancer.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                            {
                                [animationImageView removeFromSuperview];
                            });
         }];
    }
    else // full overlay
    {
        UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:self.contentCell.bounds];
        animationImageView.animationDuration = enhancer.animationDuration;
        animationImageView.animationImages = enhancer.animationSequence;
        animationImageView.animationRepeatCount = 1;
        animationImageView.contentMode = enhancer.contentMode;
        
        [self.contentCell.contentView addSubview:animationImageView];
        [animationImageView startAnimating];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(enhancer.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                       {
                           [animationImageView removeFromSuperview];
                       });
    }
    
    // Refresh comments 2 seconds after user throws an EB in case we need to show an EB comment
    __weak typeof(self) welf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       [welf reloadComments];
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
    const BOOL hasComments = self.viewModel.comments.count > 0;
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
    
    if ( self.isVideoContent )
    {
        NSAssert( self.videoPlayer != nil, @"Expecting to have `videoPlayer` set if content is video/GIF." );
        
        [self.videoPlayer pause];
        __weak typeof(self) welf = self;
        [self.authorizedAction performFromViewController:self context:VAuthorizationContextAddComment completion:^(BOOL authorized)
         {
             if (!authorized)
             {
                 return;
             }
             welf.enteringRealTimeComment = YES;
             welf.realtimeCommentBeganTime = welf.videoPlayer.currentTimeSeconds;
         }];
    }
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
    self.realtimeCommentBeganTime = 0.0f;
}

- (void)submitCommentWithText:(NSString *)commentText
{
    __weak typeof(self) welf = self;
    [self.viewModel addCommentWithText:commentText
                     publishParameters:welf.publishParameters
                           currentTime:welf.realtimeCommentBeganTime
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

#pragma mark - VExperienceEnhancerControllerDelegate

- (void)experienceEnhancersDidUpdate
{
    // Do nothing, eventually a nice animation to reveal experience enhancers
}

- (BOOL)isVideoContent
{
    return self.viewModel.type == VContentViewTypeGIFVideo || self.viewModel.type == VContentViewTypeVideo;
}

- (Float64)currentVideoTime
{
    return self.videoPlayer == nil ? 0.0 : self.videoPlayer.currentTimeSeconds;
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
    [self.viewModel loadComments:VPageTypeNext];
}

- (void)shouldLoadPreviousPage
{
    [self.viewModel loadComments:VPageTypePrevious];
}

#pragma mark - VEndCardViewControllerDelegate

- (void)replaySelectedFromEndCard:(VEndCardViewController *)endCardViewController
{
    [self.videoPlayer seekToTimeSeconds:0.0f];
    [endCardViewController transitionOutAllWithBackground:YES completion:^
     {
         [self.contentCell hideEndCard];
         [self.videoPlayer play];
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
         [self.contentCell hideEndCard];
         
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
    self.experienceEnhancerCell.experienceEnhancerBar.enabled = NO;
    
    ContentViewContext *context = [[ContentViewContext alloc] init];
    context.sequence = nextSequence;
    context.streamId = self.viewModel.streamId;
    context.dependencyManager = self.dependencyManager;
    VContentViewViewModel *contentViewModel = [[VContentViewViewModel alloc] initWithContext:context];
    VNewContentViewController *contentViewController = [VNewContentViewController contentViewControllerWithViewModel:contentViewModel
                                                                                                   dependencyManager:self.dependencyManager];
    
    // Create a new sequence preview for the next view controller
    VStreamItemPreviewView *previewView = [VStreamItemPreviewView streamItemPreviewViewWithStreamItem:nextSequence];
    [previewView setDependencyManager:self.dependencyManager];
    [previewView setStreamItem:nextSequence];
    contentViewController.nextSequencePreviewView = previewView;
    
    // Put back our current sequence preview
    [self.viewModel.context.contentPreviewProvider restorePreviewView:self.contentCell.sequencePreviewView];
    
    self.navigationController.delegate = contentViewController;
    contentViewController.transitioningDelegate = self.endcardNextTransitionDelegate;
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
    return [self.endcardNextTransitionDelegate navigationController:navigationController
                                   animationControllerForOperation:operation
                                                fromViewController:fromVC
                                                  toViewController:toVC];
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

#pragma mark - VSequencePreviewViewDetailDelegate

- (void)previewView:(VSequencePreviewView *)previewView didSelectMediaURL:(NSURL *)mediaURL previewImage:(UIImage *)previewImage isVideo:(BOOL)isVideo sourceView:(UIView *)sourceView
{
    [self showLightBoxWithMediaURL:mediaURL previewImage:previewImage isVideo:isVideo sourceView:sourceView];
}

- (void)previewView:(VSequencePreviewView *)previewView didLikeSequence:(VSequence *)sequence completion:(void(^)(BOOL))completion
{
    [self.sequenceActionController likeSequence:self.viewModel.sequence
                             fromViewController:self
                                 withActionView:previewView.likeButton
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
    [self.authorizedAction performFromViewController:self context:VAuthorizationContextVotePoll completion:^(BOOL authorized)
     {
         if (authorized)
         {
             [self.viewModel answerPollWithAnswer:VPollAnswerA completion:^(BOOL succeeded, NSError *error)
              {
                  [self.pollAnswerReceiver setAnswerAPercentage:self.viewModel.answerAPercentage animated:YES];
              }];
         }
     }];
}

- (void)answerBSelected
{
    [self.authorizedAction performFromViewController:self context:VAuthorizationContextVotePoll completion:^(BOOL authorized)
     {
         if (authorized)
         {
             [self.viewModel answerPollWithAnswer:VPollAnswerB completion:^(BOOL succeeded, NSError *error)
              {
                  [self.pollAnswerReceiver setAnswerBPercentage:self.viewModel.answerBPercentage animated:YES];
              }];
         }
     }];
}

#pragma mark - VVideoSequenceDelegate

- (void)animateAlongsideVideoToolbarWillAppear
{
    if ( !self.contentCell.isEndCardShowing )
    {
        self.closeButton.alpha = 1.0f;
        self.moreButton.alpha = 1.0f;
    }
}

- (void)animateAlongsideVideoToolbarWillDisappear
{
    if ( !self.contentCell.isEndCardShowing )
    {
        self.closeButton.alpha = 0.0f;
        self.moreButton.alpha = 0.0f;
    }
}

- (void)videoPlaybackDidFinish
{
    if (self.viewModel.endCardViewModel != nil)
    {
        [self setAccessoryButtonsHidden:NO];
        [self.contentCell showEndCardWithViewModel:self.viewModel.endCardViewModel];
    }
}

#pragma mark - VContentCellDelegate

- (void)contentCellDidEndPlayingAd:(VContentCell *)cell
{
    self.experienceEnhancerCell.experienceEnhancerBar.enabled = YES;
}

- (void)contentCellDidStartPlayingAd:(VContentCell *)cell
{
    self.experienceEnhancerCell.experienceEnhancerBar.enabled = NO;
}

@end
