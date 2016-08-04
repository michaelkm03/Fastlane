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
#import "VCollectionViewStreamFocusHelper.h"
#import "VContentBackgroundSupplementaryView.h"
#import "VContentCell.h"
#import "VContentPollBallotCell.h"
#import "VContentPollQuestionCell.h"
#import "VDependencyManager+NavigationBar.h"
#import "VDependencyManager+VTracking.h"
#import "VElapsedTimeFormatter.h"
#import "VExperienceEnhancer.h"
#import "VExperienceEnhancerBar.h"
#import "VExperienceEnhancerBarCell.h"
#import "VExperienceEnhancerResponder.h"
#import "VHashtagSelectionResponder.h"
#import "VHashtagStreamCollectionViewController.h"
#import "VImageLightboxViewController.h"
#import "VLightboxTransitioningDelegate.h"
#import "VMediaAttachmentPresenter.h"
#import "VNewContentViewController.h"
#import "VNode+Fetcher.h"
#import "VPurchaseViewController.h"
#import "VSectionHandleReusableView.h"
#import "VSequence+Fetcher.h"
#import "VSequenceActionControllerDelegate.h"
#import "VSequencePreviewViewProtocols.h"
#import "VShrinkingContentLayout.h"
#import "VSimpleModalTransition.h"
#import "VTransitionDelegate.h"
#import "VURLSelectionResponder.h"
#import "VVideoLightboxViewController.h"
#import "VPurchaseManager.h"

@import KVOController;

#define HANDOFFENABLED 0

static NSString * const kPollBallotIconKey = @"orIcon";

@interface VNewContentViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, VExperienceEnhancerControllerDelegate, VPurchaseViewControllerDelegate, VContentViewViewModelDelegate, NSUserActivityDelegate, VHashtagSelectionResponder, VURLSelectionResponder, VExperienceEnhancerResponder, VSequencePreviewViewDetailDelegate, VContentPollBallotCellDelegate, AdLifecycleDelegate, VPaginatedDataSourceDelegate, VImageAnimationOperationDelegate, VSequenceActionControllerDelegate>

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
@property (nonatomic, weak) NSLayoutConstraint *bottomKeyboardToContainerBottomConstraint;
@property (nonatomic, weak) UIView *snapshotView;
@property (nonatomic, weak) VContentPollBallotCell *ballotCell;
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

#pragma mark - VContentViewViewModelDelegate

- (void)didUpdateCommentsWithDeepLink:(NSNumber *)commentId
{
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return VContentViewSectionCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
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
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // End focus on this cell to stop video if there is one
    [self.focusHelper endFocusOnCell:cell];
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

#pragma mark - CoachmarkDisplayer

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
}

- (void)enableCommentsAndExperienceEnhancers
{
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
}

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didReceiveError:(NSError *)error
{
    [self v_showErrorDefaultError];
}

@end