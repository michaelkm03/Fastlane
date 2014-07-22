//
//  VContentViewController.m
//  victorious
//
//  Created by Will Long on 2/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIViewController+ForceOrientationChange.h"

#import "VAnalyticsRecorder.h"
#import "VContentViewController.h"
#import "VContentViewController+Images.h"
#import "VContentViewController+Private.h"
#import "VContentViewController+Polls.h"
#import "VContentViewController+Videos.h"

#import "VContentInfoViewController.h"

#import "VCommentsContainerViewController.h"

#import "UIImageView+Blurring.h"

#import "VActionBarViewController.h"
#import "VEmotiveBallisticsBarViewController.h"
#import "VRealtimeCommentViewController.h"

#import "VObjectManager+Sequence.h"

#import "VContentToStreamAnimator.h"
#import "VContentToCommentAnimator.h"

#import "UIActionSheet+VBlocks.h"

#import "VElapsedTimeFormatter.h"

#import "VFacebookActivity.h"
#import "VDeeplinkManager.h"
#import "VSettingManager.h"

static const CGFloat kMaximumContentViewOffset              = 154.0f;
static const CGFloat kMediaViewHeight                       = 320.0f;
static const CGFloat kBarContainerViewHeight                =  60.0f;
static const CGFloat kDistanceBetweenTitleAndCollapseButton =  42.5f;

NSTimeInterval kVContentPollAnimationDuration = 0.2;

@import MediaPlayer;

@interface VContentViewController() <VContentInfoDelegate, VRealtimeCommentDelegate, VKeyboardBarDelegate>

@property (nonatomic) BOOL isViewingTitle;
@property (nonatomic) VElapsedTimeFormatter* timeFormatter;

@end

@implementation VContentViewController

+ (VContentViewController *)sharedInstance
{
    static  VContentViewController*   sharedInstance;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken,
    ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        sharedInstance = (VContentViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kContentViewStoryboardID];
    });
    
    return sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.timeFormatter = [[VElapsedTimeFormatter alloc] init];
    
    self.mediaSuperview.translatesAutoresizingMaskIntoConstraints = YES; // these two views need to opt-out of Auto Layout.
    self.mediaView.translatesAutoresizingMaskIntoConstraints = YES;      // their frames are set in -layoutMediaSuperview.

    UIView *maskingView = self.maskingView;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[maskingView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(maskingView)]];
    
    for (UIButton* button in [self.navButtonCollection arrayByAddingObjectsFromArray:self.actionButtonCollection])
    {
        [button setImage:[button.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        button.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    }
    
    for (UIButton* button in self.actionButtonCollection)
    {
        [button.layer setBorderWidth:1.0];
        [button.layer setBorderColor:[[UIColor colorWithWhite:.4 alpha:.2] CGColor]];
        button.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
    }
    
    for (UIViewController* vc in self.childViewControllers)
    {
        if ([vc isKindOfClass:[VRealtimeCommentViewController class]])
        {
            self.realtimeCommentVC = (VRealtimeCommentViewController*)vc;
            self.realtimeCommentVC.delegate = self;
        }
        else if ([vc isKindOfClass:[VKeyboardBarViewController class]])
        {
            self.keyboardBarVC = (VKeyboardBarViewController*)vc;
            self.keyboardBarVC.delegate = self;
            self.keyboardBarVC.hideAccessoryBar = YES;
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    self.isViewingTitle = YES;
    
    self.keyboardBarContainer.hidden = YES;
    
    [self resetView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Content"];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.appearing = YES;
    
    if ([self.currentAsset isVideo] && [[VSettingManager sharedManager] settingEnabledForKey:kVRealtimeCommentsEnabled])
        [self flipHeaderWithDuration:.25f completion:nil];
    
    if ([self isBeingPresented] || [self isMovingToParentViewController])
    {
        [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation action:@"Show Content" label:self.sequence.name value:nil];
        [self updateActionBar];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self layoutMediaSuperview];
}

- (void)layoutMediaSuperview
{
    if (CGAffineTransformIsIdentity(self.mediaSuperview.transform))
    {
        self.mediaSuperview.frame = CGRectMake(CGRectGetMinX(self.view.bounds),
                                               [self contentMediaViewOffset],
                                               CGRectGetWidth(self.view.bounds),
                                               kMediaViewHeight);
    }
    else
    {
        self.mediaSuperview.bounds = CGRectMake(0,
                                                0,
                                                CGRectGetHeight(self.view.bounds),
                                                CGRectGetWidth(self.view.bounds));
        self.mediaSuperview.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                                 CGRectGetMidY(self.view.bounds));
    }
    self.mediaView.frame = self.mediaSuperview.bounds;
    
    self.pollViewYConstraint.constant = [self contentMediaViewOffset];
    if (!self.titleExpanded)
    {
        self.topActionsViewHeightConstraint.constant = [self contentMediaViewOffset] - CGRectGetHeight(self.topActionsView.frame);
    }
    
    [self.view layoutIfNeeded]; // Let auto-layout run again due to changing the frames above
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if  ([self isBeingDismissed] || [self isMovingFromParentViewController])
    {
        [self resetView];
    }
    
    if ([self isTitleExpanded])
    {
        [self collapseTitleAnimated:NO];
    }
}

- (void)resetView
{
    self.previewImage.image = nil;
    
    self.realtimeCommentsContainer.alpha = 0;
    self.contentTitleView.alpha = 1;
    
    [self.firstResultView setProgress:0 animated:NO];
    self.firstResultView.isVertical = YES;
    self.firstResultView.hidden = YES;
    self.firstResultView.color = [[[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor] colorWithAlphaComponent:0.8f];
    
    [self.secondResultView setProgress:0 animated:NO];
    self.secondResultView.isVertical = YES;
    self.secondResultView.hidden = YES;
    self.secondResultView.color = [[[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor] colorWithAlphaComponent:0.8f];
    
    self.firstPollPlayIcon.hidden = YES;
    self.secondPollPlayIcon.hidden = YES;
    self.answeredPollMaskingView.alpha = 0;
    self.mediaSuperview.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
    self.appearing = NO;
    
    if ([self isBeingDismissed] || [self isMovingFromParentViewController])
    {
        self.orAnimator = nil;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return ![self isTitleExpanded];
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (!self.isRotating && [self isVideoLoaded])
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)forceRotationBackToPortraitOnCompletion:(void (^)(void))completion
{
    [self forceRotationBackToPortraitWithExtraAnimations:nil onCompletion:completion];
}

- (void)forceRotationBackToPortraitWithExtraAnimations:(void(^)(void))animations onCompletion:(void(^)(void))completion
{
    self.isRotating = YES;
    [self beforeRotationToInterfaceOrientation:UIInterfaceOrientationPortrait];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(void)
    {
        if (animations)
        {
            animations();
        }
        [self duringRotationToInterfaceOrientation:UIInterfaceOrientationPortrait];
    }
                     completion:^(BOOL finished)
    {
        [self afterRotationToNewInterfaceOrientation:UIInterfaceOrientationPortrait];
        [UIViewController v_forceOrientationChange];
        self.isRotating = NO;
        if (completion)
        {
            completion();
        }
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self beforeRotationToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (!self.isRotating) // if this is a "forced" rotation, the animations would have been completed by now.
    {
        [self duringRotationToInterfaceOrientation:toInterfaceOrientation];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self afterRotationToNewInterfaceOrientation:self.interfaceOrientation];
}

- (void)beforeRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        self.maskingView.alpha = 0;
        self.maskingView.hidden = NO;
        if ([self isVideoLoaded])
        {
            [self.view bringSubviewToFront:self.mediaSuperview];
        }
    }
}

- (void)duringRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    UIView *rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        CGAffineTransform rotationTransform = rootView.transform;
        rootView.transform = CGAffineTransformIdentity;
        rootView.bounds = CGRectMake(0, 0, CGRectGetHeight(rootView.bounds), CGRectGetWidth(rootView.bounds));
        self.mediaSuperview.transform = rotationTransform;
        self.maskingView.alpha = 1.0f;
    }
    else
    {
        self.mediaSuperview.transform = CGAffineTransformIdentity;
        self.maskingView.alpha = 0;
    }
    [self layoutMediaSuperview];
    [self.mediaView layoutIfNeeded];
}

- (void)afterRotationToNewInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        self.maskingView.hidden = YES;
        [self.view insertSubview:self.mediaSuperview aboveSubview:self.backgroundImage];
    }
}

#pragma mark - Title Expand/Collapse

- (void)expandTitleAnimated:(BOOL)animated
{
    UIView *temporaryTitleView = nil;
    if (animated)
    {
        temporaryTitleView = [self.descriptionLabel snapshotViewAfterScreenUpdates:NO];
        temporaryTitleView.frame = self.descriptionLabel.frame;
        [self.descriptionLabel.superview addSubview:temporaryTitleView];
        self.descriptionLabel.alpha = 0;
    }
    
    void (^animations)(void) = ^(void)
    {
        self.expandedTitleMaskingView.alpha = 1.0f;
        self.collapseButton.alpha = 1.0f;
        self.topActionsViewHeightConstraint.constant = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.topActionsView.frame);
        [self.view layoutIfNeeded];
        [self updateConstraintsForTextSize:self.descriptionLabel.locationForLastLineOfText];
        [self.view layoutIfNeeded];
        
        for (UIButton* button in self.actionButtonCollection)
            button.alpha = 0.0f;
        
        self.descriptionLabel.alpha = 1.0f;
        temporaryTitleView.alpha = 0.0f;
    };
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        self.collapsingOrExpanding = NO;
        [temporaryTitleView removeFromSuperview];
    };
    
    self.smallTextSize = self.descriptionLabel.locationForLastLineOfText;
    self.collapsingOrExpanding = YES;
    self.titleExpanded = YES;
    
    [self.videoPlayer.player pause];
    
    if (animated)
    {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:animations
                         completion:completion];
    }
    else
    {
        animations();
        completion(YES);
    }
}

- (void)collapseTitleAnimated:(BOOL)animated
{
    UIView *temporaryTitleView = nil;
    if (animated)
    {
        temporaryTitleView = [self.descriptionLabel snapshotViewAfterScreenUpdates:NO];
        temporaryTitleView.frame = self.descriptionLabel.frame;
        [self.descriptionLabel.superview addSubview:temporaryTitleView];
        self.descriptionLabel.alpha = 0;
    }
    
    void (^animations)(void) = ^(void)
    {
        self.expandedTitleMaskingView.alpha = 0;
        self.collapseButton.alpha = 0;
        self.topActionsViewHeightConstraint.constant = [self contentMediaViewOffset];
        [self updateConstraintsForTextSize:self.smallTextSize];
        [self.view layoutIfNeeded];
        
        for (UIButton* button in self.actionButtonCollection)
            button.alpha = 1.0f;
        
        self.descriptionLabel.alpha = 1.0f;
        temporaryTitleView.alpha = 0;
        
    };
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        self.collapsingOrExpanding = NO;
        [temporaryTitleView removeFromSuperview];
    };
    
    self.collapsingOrExpanding = YES;
    self.titleExpanded = NO;
    
    if (animated)
    {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:animations
                         completion:completion];
    }
    else
    {
        animations();
        completion(YES);
    }
}

- (BOOL)isTitleExpanded
{
    return self.topActionsViewHeightConstraint.constant > [self contentMediaViewOffset];
}

- (CGFloat)contentMediaViewOffset
{
    return MIN(kMaximumContentViewOffset, CGRectGetMinY(self.barContainerView.frame) - kMediaViewHeight);
}

+ (CGFloat)estimatedContentMediaViewOffsetForBounds:(CGRect)bounds
{
    return MIN(kMaximumContentViewOffset, CGRectGetHeight(bounds) - kBarContainerViewHeight - kMediaViewHeight);
}

#pragma mark -

-(VInteractionManager*)interactionManager
{
    if (!_interactionManager)
    {
        _interactionManager = [[VInteractionManager alloc] initWithNode:self.currentNode delegate:self];
    }
    return _interactionManager;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;

    UIImage* placeholderImage = [UIImage resizeableImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    [self.backgroundImage setBlurredImageWithURL:[[self.sequence initialImageURLs] firstObject]
                                placeholderImage:placeholderImage
                                       tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    self.descriptionLabel.text = _sequence.name;
    self.currentNode = [sequence firstNode];

    self.realtimeCommentVC.comments = [self.sequence.comments allObjects];
}

- (void)updateConstraintsForTextSize:(CGFloat)textSize
{
    self.collapseButtonVerticalSpacingConstraint.constant = textSize + kDistanceBetweenTitleAndCollapseButton;
}

- (void)setCurrentNode:(VNode *)currentNode
{
    //If you run out of nodes... go to the beginning.
    if (!currentNode)
        _currentNode = [self.sequence firstNode];
    
    //If this node is not for the sequence... Something is wrong, just use the first node and print a warning
    else if (currentNode.sequence != self.sequence)
    {
        VLog(@"Warning: node %@ does not belong in sequence %@", currentNode, self.sequence);
        _currentNode = [self.sequence firstNode];
    }
    else
        _currentNode = currentNode;
    
    _currentAsset = nil; //we changed nodes, so we're not on an asset
    if ([self.currentNode isQuiz])
        [self loadQuiz];
    
    else if ([self.currentNode isPoll])
        [self loadPoll];
    
    else
        [self loadNextAsset];
    
    self.interactionManager.node = currentNode;
}

- (void)setActionBarVC:(VActionBarViewController *)actionBarVC
{
    [_actionBarVC willMoveToParentViewController:nil];
    [_actionBarVC.view removeFromSuperview];
    [_actionBarVC removeFromParentViewController];
    _actionBarVC = actionBarVC;
    
    if (actionBarVC)
    {
        [self addChildViewController:actionBarVC];
        [self.barContainerView addSubview:actionBarVC.view];
        
        [_actionBarVC animateInWithDuration:.2f
                                 completion:^(BOOL finished)
         {
             [actionBarVC didMoveToParentViewController:self];
             if ([self.sequence isPoll])
                 [self pollAnimation];
         }];
    }
}

- (void)updateActionBar
{
    if (!self.isViewLoaded)
    {
        return;
    }
    
    VActionBarViewController* newActionBar;
    
    //Find the appropriate target based on what view is hidden
    
    if ([self.sequence isPoll] && ![self.actionBarVC isKindOfClass:[VPollAnswerBarViewController class]])
    {
        VPollAnswerBarViewController* pollAnswerBar = [VPollAnswerBarViewController sharedInstance];
        pollAnswerBar.delegate = self;
        newActionBar = pollAnswerBar;
    }
    else if (![self.sequence isPoll] && ![self.actionBarVC isKindOfClass:[VEmotiveBallisticsBarViewController class]])
    {
        VEmotiveBallisticsBarViewController* emotiveBallistics = [VEmotiveBallisticsBarViewController sharedInstance];
        emotiveBallistics.target = self.previewImage;
        newActionBar = emotiveBallistics;
    }
    
    newActionBar.sequence = self.sequence;
    
    if (self.actionBarVC && newActionBar)
    {
        [self.actionBarVC animateOutWithDuration:.2f
                                      completion:^(BOOL finished)
                                      {
                                          self.actionBarVC = newActionBar;
                                      }];
    }
    else if (newActionBar)
    {
        self.actionBarVC = newActionBar;
    }
}

- (void)hideRemixButton
{
    if (self.remixButton.hidden)
        return;
    
    self.remixButton.hidden = YES;
    [self.view removeConstraints:@[self.shareButtonTrailingConstraint, self.repostButtonLeadingConstraint]];
    self.shareButtonTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.shareButton
                                                                      attribute:NSLayoutAttributeTrailing
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.0f
                                                                       constant:0.0];
    
    self.repostButtonLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.repostButton
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.0f
                                                                       constant:-1.0f];
    [self.view addConstraints:@[self.shareButtonTrailingConstraint, self.repostButtonLeadingConstraint]];
    [self.view layoutIfNeeded];
}

- (void)showRemixButton
{
    if (!self.remixButton.hidden)
        return;
    
    self.remixButton.hidden = NO;

    [self.view removeConstraints:@[self.shareButtonTrailingConstraint, self.repostButtonLeadingConstraint]];
    self.shareButtonTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.shareButton
                                                                      attribute:NSLayoutAttributeTrailing
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.remixButton
                                                                      attribute:NSLayoutAttributeLeading
                                                                     multiplier:1.0f
                                                                       constant:1.0f];
    
    self.repostButtonLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.repostButton
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.remixButton
                                                                      attribute:NSLayoutAttributeTrailing
                                                                     multiplier:1.0f
                                                                       constant:-1.0f];
    [self.view addConstraints:@[self.shareButtonTrailingConstraint, self.repostButtonLeadingConstraint]];
    [self.view layoutIfNeeded];
}

#pragma mark - Sequence Logic
- (void)loadNextAsset
{
    if (!self.currentAsset)
    {
        self.currentAsset = [self.currentNode firstAsset];
    }
    
    if ([self.currentAsset isVideo])
    {
        [self loadImage]; // load the video thumbnail
        [self playVideoAtURL:[NSURL URLWithString:self.currentAsset.data] withPreviewView:self.previewImage];
        [self showRemixButton];
    }
    else //Default case: we assume it's an image and hope it works out
    {
        [self loadImage];
        [self hideRemixButton];
    }
}

#pragma mark - Quiz
- (void)loadQuiz
{
    //self.actionBar = [VActionBarViewController quizBar];
}

#pragma mark - Button Actions
- (IBAction)pressedBack:(id)sender
{
    void (^goBack)() = ^(void)
    {
        [self.navigationController popViewControllerAnimated:YES];
    };
    if (self.collapsePollMedia)
    {
        self.collapsePollMedia(YES, ^{ goBack(); });
    }
    else
    {
        goBack();
    }
}

- (IBAction)pressedComment:(id)sender
{
    if (![self.sequence isVideo] || ![[VSettingManager sharedManager] settingEnabledForKey:kVRealtimeCommentsEnabled])
    {
        [self goToCommentView];
    }
    else
    {
        self.keyboardBarContainer.hidden = NO;
        self.keyboardBarContainer.alpha = 0;
        self.keyboardBarVC.promptLabel.text = [NSString stringWithFormat:NSLocalizedString(@"leaveACommentFormat", nil),
                                               [self.timeFormatter stringForCMTime:self.videoPlayer.currentTime]];

        if (self.isViewingTitle)
            [self flipHeaderWithDuration:.25f completion:nil];
   
        [UIView animateWithDuration:.25 animations:
         ^{
             self.keyboardBarContainer.alpha = 1;
         }
         completion:^(BOOL finished)
        {
            [self.keyboardBarVC becomeFirstResponder];
        }];
    }
}

- (void)goToCommentView
{
    VCommentsContainerViewController* commentsTable = [VCommentsContainerViewController commentsContainerView];
    commentsTable.sequence = self.sequence;
    [self.navigationController pushViewController:commentsTable animated:YES];
}

- (IBAction)pressedCollapse:(id)sender
{
    [self collapseTitleAnimated:YES];
}

- (IBAction)pressedShare:(id)sender
{
    VFacebookActivity* fbActivity = [[VFacebookActivity alloc] init];

    NSURL* deeplinkURL = [[VDeeplinkManager sharedManager] contentDeeplinkForSequence:self.sequence];
    UIImage* previewImage = self.previewImage.image ?: self.leftPollThumbnail;
    
    UIActivityViewController *activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:@[self.sequence,
                                                                  NSLocalizedString(@"CheckOutContent", nil),
                                                                  previewImage, deeplinkURL]
                                          applicationActivities:@[fbActivity]];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
    
    [self.navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                         
                                     }];

}

- (IBAction)pressedRepost:(id)sender
{
//    [self collapseTitleAnimated:YES];
}

- (IBAction)pressedMore:(id)sender
{
    VContentInfoViewController* contentInfo = [VContentInfoViewController sharedInstance];
    contentInfo.sequence = self.sequence;
    contentInfo.backgroundImage = self.backgroundImage.image;
    contentInfo.delegate = self;
    contentInfo.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:contentInfo animated:YES completion:nil];
}

#pragma mark - VContentInfoDelegate
- (void)didCloseFromInfo
{
    [self dismissViewControllerAnimated:YES
                             completion:
     ^{
         [self.navigationController popViewControllerAnimated:YES];
     }];
}

- (void)willCommentFromInfo
{
    [self dismissViewControllerAnimated:YES
                             completion:
     ^{
         [self goToCommentView];
     }];
}
#pragma mark - VInteractionManagerDelegate
- (void)firedInteraction:(VInteraction*)interaction
{
    VLog(@"Interaction fired:%@", interaction);
}

#pragma mark - Navigation
- (id<UIViewControllerAnimatedTransitioning>) navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController*)fromVC
                                                  toViewController:(UIViewController*)toVC
{
    if (operation == UINavigationControllerOperationPop)
    {
        return [[VContentToStreamAnimator alloc] init];
    }
    else if (operation == UINavigationControllerOperationPush)
    {
        return [[VContentToCommentAnimator alloc] init];
    }
    return nil;
}

#pragma mark - Animations

- (void)flipHeaderWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    if (![[VSettingManager sharedManager] settingEnabledForKey:kVRealtimeCommentsEnabled])
        return;
    
    [UIView animateWithDuration:duration
                     animations:
     ^{
         self.realtimeCommentsContainer.alpha = !self.isViewingTitle ? 0 : 1;
         self.contentTitleView.alpha = self.isViewingTitle ? 0 : 1;
     }
                     completion:completion];
    
    self.isViewingTitle = !self.isViewingTitle;
}

- (void)animateInWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    
    CGRect topActionsFrame = self.topActionsView.frame;
    self.topActionsView.frame = CGRectMake(CGRectGetMinX(topActionsFrame), CGRectGetMinY(self.mediaView.frame),
                                                CGRectGetWidth(topActionsFrame), CGRectGetHeight(topActionsFrame));
    
    self.orImageView.hidden = ![self.sequence isPoll];
    self.orImageView.center = CGPointMake(CGRectGetMidX(self.orContainerView.bounds), 107.0f);
    
    self.firstPollButton.alpha = 0;
    self.secondPollButton.alpha = 0;
    
    self.topActionsView.alpha = 0;
    [UIView animateWithDuration:duration
                     animations:^
     {
         self.topActionsView.frame = CGRectMake(CGRectGetMinX(topActionsFrame), 0, CGRectGetWidth(topActionsFrame), CGRectGetHeight(topActionsFrame));
         self.topActionsView.alpha = 1;
         self.firstPollButton.alpha = 1;
         self.secondPollButton.alpha = 1;
         
         for (UIView* view in self.view.subviews)
         {
             if (CGRectIntersectsRect(self.view.frame, view.frame) || [view isKindOfClass:[UIImageView class]])
                 continue;
             
             if (view.center.y > self.view.center.y)
             {
                 view.center = CGPointMake(view.center.x, view.center.y - self.view.frame.size.height);
             }
             else
             {
                 view.center = CGPointMake(view.center.x, view.center.y + self.view.frame.size.height);
             }
         }
     }
                     completion:^(BOOL finished)
     {
         self.view.userInteractionEnabled = YES;
         if (completion)
         {
             completion(finished);
         }
     }];
}

- (void)animateOutWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration
                     animations:^
     {
         for (UIView* view in self.view.subviews)
         {
             if (!CGRectIntersectsRect(self.view.frame, view.frame) || [view isKindOfClass:[UIImageView class]])
                 continue;
             
             if (view.center.y > self.view.center.y)
             {
                 view.center = CGPointMake(view.center.x, view.center.y + self.view.frame.size.height);
             }
             else
             {
                 view.center = CGPointMake(view.center.x, view.center.y - self.view.frame.size.height);
             }
         }
     }
                     completion:^(BOOL finished)
     {
         if (completion)
         {
             completion(finished);
         }
     }];
}

#pragma mark - VKeyboardBarDelegate Methods
- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text mediaURL:(NSURL *)mediaURL
{
    VLog(@"A thing");
    [self didCancelKeyboardBar:keyboardBar];
#warning this should probably post to server
}
- (void)didCancelKeyboardBar:(VKeyboardBarViewController *)keyboardBar
{
    [UIView animateWithDuration:.25 animations:
     ^{
         self.keyboardBarContainer.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         self.keyboardBarContainer.hidden = YES;
     }];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    CGRect keyboardEndFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect videoFrame = [self.view convertRect:self.videoPlayer.view.frame fromView:self.mediaSuperview];

    [self.view removeConstraint:self.mediaSuperviewTopConstraint];
    
    if (CGRectGetMaxY(videoFrame) > CGRectGetMinY(keyboardEndFrame))
    {
        self.mediaSuperviewTopConstraint = [NSLayoutConstraint constraintWithItem:self.mediaSuperview
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.keyboardBarContainer
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:0];
    }
    else
    {
        self.mediaSuperviewTopConstraint = [NSLayoutConstraint constraintWithItem:self.mediaSuperview
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.realtimeCommentsContainer
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:0];
    }
    
    
    [self.view addConstraint:self.mediaSuperviewTopConstraint];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    
    [self.view removeConstraint:self.mediaSuperviewTopConstraint];
    self.mediaSuperviewTopConstraint = [NSLayoutConstraint constraintWithItem:self.mediaSuperview
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.realtimeCommentsContainer
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0f
                                                                     constant:0];
    [self.view addConstraint:self.mediaSuperviewTopConstraint];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}
#pragma mark - VRealtimeCommentDelegate methods

-(void)willShowRTCMedia
{
    [self pauseVideo];
}

- (void)didFinishedRTCMedia
{
    [self resumeVideo];
}

#pragma mark - VContentTitleTextViewDelegate methods

- (void)textLayoutHappenedInContentTitleTextView:(VContentTitleTextView *)contentTitleTextView
{
    if (!self.collapsingOrExpanding)
    {
        [self updateConstraintsForTextSize:contentTitleTextView.locationForLastLineOfText];
    }
}

- (void)seeMoreButtonTappedInContentTitleTextView:(VContentTitleTextView *)contentTitleTextView
{
    [self expandTitleAnimated:YES];
}

@end
