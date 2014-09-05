//
//  VContentViewController.m
//  victorious
//
//  Created by Will Long on 2/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIViewController+ForceOrientationChange.h"

#import "VConstants.h"
#import "VAnalyticsRecorder.h"
#import "VContentViewController.h"
#import "VContentViewController+Images.h"
#import "VContentViewController+Private.h"
#import "VContentViewController+Polls.h"
#import "VContentViewController+Videos.h"

#import "VContentInfoViewController.h"

#import "VCommentsContainerViewController.h"
#import "VCameraPublishViewController.h"

#import "VHashTagContainerViewController.h"

#import "VHashTagStreamViewController.h"

#import "VRemixSelectViewController.h"
#import "VRemixTrimViewController.h"

#import "UIImageView+Blurring.h"

#import "VActionBarViewController.h"
#import "VEmotiveBallisticsBarViewController.h"
#import "VRealtimeCommentViewController.h"
#import "VLoginViewController.h"

#import "VObjectManager+Sequence.h"
#import "VObjectManager+Comment.h"
#import "VObjectManager+ContentCreation.h"

#import "VContentToStreamAnimator.h"
#import "VContentToCommentAnimator.h"
#import "VContentToInfoAnimator.h"

#import "UIActionSheet+VBlocks.h"

#import "VElapsedTimeFormatter.h"

#import "VUser+Fetcher.h"

#import "VFacebookActivity.h"
#import "VDeeplinkManager.h"
#import "VSettingManager.h"

#import "MBProgressHUD.h"

static const CGFloat kMaximumNoCaptionContentViewOffset     = 134.0f;
static const CGFloat kMaximumContentViewOffset              = 154.0f;
static const CGFloat kMediaViewHeight                       = 320.0f;
static const CGFloat kBarContainerViewHeight                =  60.0f;
static const CGFloat kDistanceBetweenTitleAndCollapseButton =  42.5f;
static const CGFloat kActionConstraintConstantCollapsed     =   0.0f;
static const CGFloat kActionConstraintConstantExpandedOffset= 420.0f;

NSTimeInterval kVContentPollAnimationDuration = 0.2;

@interface VContentViewController() <VContentInfoDelegate, VRealtimeCommentDelegate, VKeyboardBarDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, readonly) BOOL isViewingTitle;
@property (nonatomic) VElapsedTimeFormatter* timeFormatter;
@property (nonatomic) BOOL keyboardOverlapsMedia;
@property (nonatomic) BOOL isShowingKeyboard;

@property (nonatomic) BOOL willComment; ///<Set to true when the comment button was pressed in info vc;
@property (nonatomic) BOOL willClose; ///<Set to true when the close button was pressed in info vc;

@property (nonatomic) NSInteger commentTime;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareButtonBottomToContainerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remixButtonBottomToContainerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *repostButtonBottomToContainerConstraint;

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSURL *sourceURL;
@property (nonatomic, strong) NSURL *targetURL;
@property (nonatomic) NSInteger sequenceID;
@property (nonatomic) NSInteger nodeID;
@end

@implementation VContentViewController

-(id)init
{
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    self = (VContentViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kContentViewStoryboardID];

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.timeFormatter = [[VElapsedTimeFormatter alloc] init];
    
    self.mediaSuperview.translatesAutoresizingMaskIntoConstraints = YES; // these two views need to opt-out of Auto Layout.
    self.mediaView.translatesAutoresizingMaskIntoConstraints = YES;      // their frames are set in -layoutMediaSuperview.
    
    self.commentTime = -1;

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
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.keyboardBarContainer.hidden = YES;
    
    [self resetView];
    
    if (CGRectGetHeight(self.view.bounds) == 480.0f)
    {
        UIColor *currentBackgroundColor = self.realtimeCommentVC.commentBackgroundView.backgroundColor;
        self.realtimeCommentVC.commentBackgroundView.backgroundColor = [currentBackgroundColor colorWithAlphaComponent:1.0f];
        self.realtimeCommentVC.arrowImageView.image = [self.realtimeCommentVC.arrowImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.realtimeCommentVC.arrowImageView.tintColor = [currentBackgroundColor colorWithAlphaComponent:1.0f];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Content"];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.appearing = YES;
    
    if ([self.currentAsset isVideo]
        && [[VSettingManager sharedManager] settingEnabledForKey:kVRealtimeCommentsEnabled]
        && [self.realtimeCommentVC.comments count])
        [self showRTC];
    else
        [self hideRTC];
    
    if ([self isBeingPresented] || [self isMovingToParentViewController])
    {
        [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation action:@"Show Content" label:self.sequence.name value:nil];
        [self updateActionBar];
    }
    
    if (self.willComment)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                       ^{
                           self.willComment = NO;
                           [self goToCommentView];
                       });

    }
    else if (self.willClose)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                       ^{
                           self.willClose = NO;
                           [self.navigationController popViewControllerAnimated:YES];
                       });
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
        if (self.keyboardOverlapsMedia)
        {
            self.mediaSuperview.frame = CGRectMake(CGRectGetMinX(self.view.bounds),
                                                   CGRectGetMaxY(self.keyboardBarContainer.frame),
                                                   CGRectGetWidth(self.view.bounds),
                                                   kMediaViewHeight);
        }
        else
        {
            self.mediaSuperview.frame = CGRectMake(CGRectGetMinX(self.view.bounds),
                                                   [self contentMediaViewOffset],
                                                   CGRectGetWidth(self.view.bounds),
                                                   kMediaViewHeight);
        }
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

    [[VThemeManager sharedThemeManager] applyStyling];
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[VThemeManager sharedThemeManager] applyStyling];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)isViewingTitle
{
    return self.contentTitleView.alpha;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return ![self isTitleExpanded] && !self.isShowingKeyboard;
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
        
        self.shareButtonBottomToContainerConstraint.constant = kActionConstraintConstantExpandedOffset;
        self.remixButtonBottomToContainerConstraint.constant = kActionConstraintConstantExpandedOffset;
        self.repostButtonBottomToContainerConstraint.constant = kActionConstraintConstantExpandedOffset;
        
        self.topActionsViewHeightConstraint.constant = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.topActionsView.frame);
        [self.view layoutIfNeeded];
        [self updateConstraintsForTextSize:self.descriptionLabel.locationForLastLineOfText];
        [self.view layoutIfNeeded];
        
        for (UIButton* button in self.actionButtonCollection)
            button.alpha = 0.0f;
        
        self.descriptionLabel.alpha = 1.0f;
        temporaryTitleView.alpha = 0.0f;
        [self.view layoutIfNeeded];
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
                            options:UIViewAnimationOptionCurveEaseIn
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
        self.shareButtonBottomToContainerConstraint.constant = kActionConstraintConstantCollapsed;
        self.remixButtonBottomToContainerConstraint.constant = kActionConstraintConstantCollapsed;
        self.repostButtonBottomToContainerConstraint.constant = kActionConstraintConstantCollapsed;
        
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
                            options:UIViewAnimationOptionCurveEaseOut
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
    CGFloat currentContentViewOffset = self.sequence.nameEmbeddedInContent.boolValue ? kMaximumNoCaptionContentViewOffset : kMaximumContentViewOffset;
    return MIN(currentContentViewOffset, CGRectGetMinY(self.barContainerView.frame) - kMediaViewHeight);
}

+ (CGFloat)estimatedContentMediaViewOffsetForBounds:(CGRect)bounds sequence:(VSequence*)sequence
{
    CGFloat currentContentViewOffset = sequence.nameEmbeddedInContent.boolValue ? kMaximumNoCaptionContentViewOffset : kMaximumContentViewOffset;
    return MIN(currentContentViewOffset, CGRectGetHeight(bounds) - kBarContainerViewHeight - kMediaViewHeight);
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

    self.descriptionLabel.hidden = _sequence.nameEmbeddedInContent.boolValue;
    
    self.descriptionLabel.text = _sequence.name;
    self.currentNode = [sequence firstNode];
    
    [[VObjectManager sharedManager] fetchUserInteractionsForSequence:sequence.remoteId
                                                      withCompletion:^(VSequenceUserInteractions *userInteractions, NSError *error)
     {
         NSString *repostButtonTitle = userInteractions.hasReposted ? NSLocalizedString(@"REPOSTED", @"") : NSLocalizedString(@"RepostContentView", @"");
         if (userInteractions.hasReposted)
         {
             UIColor *primaryAccentColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
             [self.repostButton setBackgroundColor:[primaryAccentColor colorWithAlphaComponent:0.1f]];
             self.repostButton.adjustsImageWhenDisabled = NO;
             self.repostButton.enabled = NO;
             repostButtonTitle = [NSString stringWithFormat:@" %@", repostButtonTitle];
         }
         else
         {
             repostButtonTitle = [NSString stringWithFormat:@"  %@", repostButtonTitle];
         }
         

         [self.repostButton setTitle:repostButtonTitle
                            forState:UIControlStateNormal];
     }];
}

- (void)updateConstraintsForTextSize:(CGFloat)textSize
{
    self.collapseButtonVerticalSpacingConstraint.constant = textSize + kDistanceBetweenTitleAndCollapseButton;
}

- (void)setCurrentNode:(VNode *)currentNode
{
    //If you run out of nodes... go to the beginning.
    if (!currentNode)
    {
        _currentNode = [self.sequence firstNode];
    }
    else if (currentNode.sequence != self.sequence) //If this node is not for the sequence... Something is wrong, just use the first node and print a warning
    {
        VLog(@"Warning: node %@ does not belong in sequence %@", currentNode, self.sequence);
        _currentNode = [self.sequence firstNode];
    }
    else
    {
        _currentNode = currentNode;
    }
    
    _currentAsset = nil; //we changed nodes, so we're not on an asset
    
    if ([self.currentNode isPoll])
    {
        self.remixButton.enabled = NO;
        self.repostButton.enabled = NO;
        [self loadPoll];
    }
    else
    {
        [self loadNextAsset];
    }
    
    //This is a safety feature to disable sharing if we do not recieve a share URL from the server.
    self.shareButton.userInteractionEnabled = self.currentNode.shareUrlPath && self.currentNode.shareUrlPath.length;
    self.shareButton.tintColor =  self.shareButton.userInteractionEnabled ? [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor] : [UIColor grayColor];
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
             {
                 [self pollAnimation];
             }
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

- (void)showRemixButton
{
    if (!self.remixButton.hidden)
    {
        return;
    }
    
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
        
        [[VObjectManager sharedManager] fetchFiltedRealtimeCommentForAssetId:self.currentAsset.remoteId.integerValue
                                                                successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
        {
            self.realtimeCommentVC.comments = [self.currentAsset.comments allObjects];
            [self showRTC];
        }
                                                                 failBlock:nil];
    }
    else //Default case: we assume it's an image and hope it works out
    {
        [self loadImage];
    }
    
    [self showRemixButton];
}

#pragma mark - Button Actions
- (IBAction)pressedRemix:(id)sender
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        [self forceRotationBackToPortraitOnCompletion:^(void)
         {
             [self pressedRemix:sender];
         }];
        return;
    }
    
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    NSString* label = [self.sequence.remoteId.stringValue stringByAppendingPathComponent:self.sequence.name];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation action:@"Pressed Remix" label:label value:nil];
    
    if ([self.currentAsset isVideo])
    {
        
        self.sourceURL = [self.currentAsset.data mp4UrlFromM3U8];
        self.sequenceID = [self.sequence.remoteId integerValue];
        self.nodeID = [self.currentNode.remoteId integerValue];
        
        UIViewController* remixVC = [VRemixSelectViewController remixViewControllerWithURL:self.sourceURL sequenceID:self.sequenceID nodeID:self.nodeID];
        [self presentViewController:remixVC animated:YES completion:
         ^{
             [self.videoPlayer.player pause];
         }];
        
    }
    else
    {
        UINavigationController * __weak weakNav = self.navigationController;
        VCameraPublishViewController *publishViewController = [VCameraPublishViewController cameraPublishViewController];
        publishViewController.previewImage = self.previewImage.image;
        publishViewController.parentID = self.sequenceID;
        publishViewController.completion = ^(BOOL complete)
        {
            [weakNav popViewControllerAnimated:YES];
        };
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                           onCancelButton:nil
                                                   destructiveButtonTitle:nil
                                                      onDestructiveButton:nil
                                               otherButtonTitlesAndBlocks:NSLocalizedString(@"Meme", nil),  ^(void)
                                      {
                                          publishViewController.captionType = VCaptionTypeMeme;
                                          
                                          NSData *filteredImageData = UIImageJPEGRepresentation(self.previewImage.image, VConstantJPEGCompressionQuality);
                                          NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
                                          NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
                                          if ([filteredImageData writeToURL:tempFile atomically:NO])
                                          {
                                              publishViewController.mediaURL = tempFile;
                                              [weakNav pushViewController:publishViewController animated:YES];
                                          }
                                      },
                                      NSLocalizedString(@"Quote", nil),  ^(void)
                                      {
                                          publishViewController.captionType = VCaptionTypeQuote;
                                          
                                          NSData *filteredImageData = UIImageJPEGRepresentation(self.previewImage.image, VConstantJPEGCompressionQuality);
                                          NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
                                          NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
                                          if ([filteredImageData writeToURL:tempFile atomically:NO])
                                          {
                                              publishViewController.mediaURL = tempFile;
                                              [weakNav pushViewController:publishViewController animated:YES];
                                          }
                                      }, nil];
        [actionSheet showInView:self.view];
    }
}

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
    if ([self isTitleExpanded])
    {
        return;
    }
    if (![self.sequence isVideo] || ![[VSettingManager sharedManager] settingEnabledForKey:kVRealtimeCommentsEnabled])
    {
        [self goToCommentView];
    }
    else if(![self isVideoLoaded])
    {
        return;
    }
    else //We're trying to post a RTC
    {
        if (![VObjectManager sharedManager].mainUser)
        {
            [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
            return;
        }
        
        self.keyboardBarContainer.hidden = NO;
        self.keyboardBarContainer.alpha = 0;
        
        self.commentTime = CMTIME_IS_VALID(self.videoPlayer.currentTime) ? CMTimeGetSeconds(self.videoPlayer.currentTime) : -1;
        self.keyboardBarVC.promptLabel.text = [NSString stringWithFormat:NSLocalizedString(@"leaveACommentFormat", nil),
                                               [self.timeFormatter stringForCMTime:self.videoPlayer.currentTime]];
        [self showRTC];
   
        [UIView animateWithDuration:.25 animations:
         ^{
             self.keyboardBarContainer.alpha = 1;
             self.realtimeCommentsContainer.alpha = 0.0f;
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
    //Remove the styling for the mail view.
    [[VThemeManager sharedThemeManager] removeStyling];
    
    NSString* shareText;
    NSString* analyticsContentTypeText = @"";
    if ([self.sequence.user isOwner])
    {
        if ([self.sequence isPoll])
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"OwnerSharePollFormat", nil), self.sequence.user.name];
            analyticsContentTypeText = @"poll";
        }
        else if ([self.sequence isVideo])
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"OwnerShareVideoFormat", nil), self.sequence.name, self.sequence.user.name];
            analyticsContentTypeText = @"video";
        }
        else
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"OwnerShareImageFormat", nil), self.sequence.user.name];
            analyticsContentTypeText = @"image";
        }
    }
    else
    {
        if ([self.sequence isPoll])
        {
            shareText = NSLocalizedString(@"UGCSharePollFormat", nil);
        }
        else if ([self.sequence isVideo])
        {
            shareText = NSLocalizedString(@"UGCShareVideoFormat", nil);
        }
        else
        {
            shareText = NSLocalizedString(@"UGCShareImageFormat", nil);
        }
    }
    
    VFacebookActivity* fbActivity = [[VFacebookActivity alloc] init];
    UIActivityViewController *activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:@[self.sequence,
                                                                  shareText,
                                                                  [NSURL URLWithString:self.currentNode.shareUrlPath] ?: [NSNull null]]
                                          applicationActivities:@[fbActivity]];
    NSString* emailSubject = [NSString stringWithFormat:NSLocalizedString(@"EmailShareSubjectFormat", nil), [[VThemeManager sharedThemeManager] themedStringForKey:kVChannelName]];
    [activityViewController setValue:emailSubject forKey:@"subject"];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed)
    {

        [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:[NSString stringWithFormat:@"Shared %@, via %@", analyticsContentTypeText, activityType]
                                                                     action:nil
                                                                      label:nil
                                                                      value:nil];
    };
    
    [self.navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                         
                                     }];

}

- (IBAction)pressedRepost:(id)sender
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
                                      [[VObjectManager sharedManager] repostNode:self.currentNode
                                                                        withName:nil
                                                                    successBlock:^(NSOperation *repostOperation, id fullResponse, NSArray *allObjects)
                                      {
                                          NSString *repostedTitle = NSLocalizedString(@"REPOSTED", @"");
                                          repostedTitle = [NSString stringWithFormat:@" %@", repostedTitle];
                                          [self.repostButton setTitle:repostedTitle
                                                             forState:UIControlStateNormal];
                                          UIColor *primaryAccentColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
                                          [self.repostButton setBackgroundColor:[primaryAccentColor colorWithAlphaComponent:0.1f]];
                                          self.repostButton.enabled = NO;
                                      }
                                                                       failBlock:^(NSOperation *repostOperation, NSError *error)
                                      {

                                      }];
                                  }, nil];
    
    [actionSheet showInView:self.view];
}

- (IBAction)pressedMore:(id)sender
{
    VContentInfoViewController* contentInfo = [[VContentInfoViewController alloc] init];
    contentInfo.sequence = self.sequence;
    contentInfo.backgroundImage = self.backgroundImage.image;
    contentInfo.delegate = self;
    [self.navigationController pushViewController:contentInfo animated:YES];
}

#pragma mark - Remix Methods

- (void)downloadVideoSegmentForSequenceID:(NSInteger)sequenceID atTime:(CGFloat)selectedTime
{
    self.progressHUD =   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    self.progressHUD.labelText = NSLocalizedString(@"JustAMoment", @"");
    self.progressHUD.detailsLabelText = NSLocalizedString(@"LocatingVideo", @"");
    
    [[VObjectManager sharedManager] fetchRemixMP4UrlForSequenceID:@(sequenceID) atStartTime:selectedTime duration:VConstantsMaximumVideoDuration completionBlock:^(BOOL completion, NSURL *remixMp4Url, NSError* error)
     {
         if (completion)
         {
             [self downloadVideoSegmentAtURL:remixMp4Url];
         }
         else
         {
             [self.progressHUD hide:YES];
             self.progressHUD = nil;
             [self showSegmentDownloadFailureAlert];
             self.navigationItem.leftBarButtonItem.enabled = YES;
         }
     }];
}

- (void)downloadVideoSegmentAtURL:(NSURL *)segmentURL
{
    self.progressHUD.mode = MBProgressHUDModeDeterminate;
    self.progressHUD.detailsLabelText = NSLocalizedString(@"DownloadingVideo", @"");
    
    NSURLSessionConfiguration*  sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess = YES;
    
    NSURLSession*               session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                                        delegate:self
                                                                   delegateQueue:nil];
    NSURLSessionDownloadTask*   task = [session downloadTaskWithURL:segmentURL];
    [task resume];
}

- (void)showSegmentDownloadFailureAlert
{
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SegmentDownloadFail", @"")
                                                           message:NSLocalizedString(@"TryAgain", @"")
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
    [alert show];
}


#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    double percent = ((double)totalBytesWritten / (double)totalBytesExpectedToWrite);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressHUD.progress = (float)percent;
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    self.targetURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[self.sourceURL lastPathComponent]] isDirectory:NO];
    [[NSFileManager defaultManager] removeItemAtURL:self.targetURL error:nil];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:self.targetURL error:nil];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // Method is only here to satisfy the delegate warning
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressHUD hide:YES];
        self.progressHUD = nil;
        self.navigationItem.leftBarButtonItem.enabled = YES;
        
        if (error)
        {
            [self showSegmentDownloadFailureAlert];
        }
        else
        {
            VRemixTrimViewController *trimVC = [[VRemixTrimViewController alloc] init];
            trimVC.sourceURL = self.targetURL;
            trimVC.parentID = self.nodeID;
            [self presentViewController:trimVC animated:YES completion:nil];
        }
    });
}

#pragma mark - VContentInfoDelegate
- (void)didCloseFromInfo
{
    self.willClose = YES;
}

- (void)willCommentFromInfo
{
    self.willComment = YES;
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
    if ([toVC isKindOfClass:[VContentInfoViewController class]] || [fromVC isKindOfClass:[VContentInfoViewController class]])
    {
        VContentToInfoAnimator* animator = [[VContentToInfoAnimator alloc] init];
        animator.isPresenting = operation == UINavigationControllerOperationPush;
        animator.fromChildContainerView =  self.mediaView;
        animator.toChildContainerView = animator.isPresenting ? ((VContentInfoViewController*)toVC).mediaContainerView : self.mediaSuperview;
        
        if (animator.isPresenting)
        {
            animator.movingImage = self.previewImage.image;
        }
        
        return animator;
    }
    
    if (operation == UINavigationControllerOperationPop && [fromVC isKindOfClass:[self class]])
    {
        return [[VContentToStreamAnimator alloc] init];
    }
    else if (operation == UINavigationControllerOperationPush && [toVC isKindOfClass:[VCommentsContainerViewController class]])
    {
        return [[VContentToCommentAnimator alloc] init];
    }
    return nil;
}

#pragma mark - Animations

- (void)showRTC
{
    if (![[VSettingManager sharedManager] settingEnabledForKey:kVRealtimeCommentsEnabled] || !self.isViewingTitle)
    {
        return;
    }
    
    [self flipHeaderWithDuration:.25f completion:nil];
}

- (void)hideRTC
{
    if (self.isViewingTitle)
    {
        return;
    }
    
    [self flipHeaderWithDuration:.25f completion:nil];
}

- (void)flipHeaderWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    for (UIViewController *childViewController in self.childViewControllers)
    {
        if ([childViewController isKindOfClass:[VKeyboardBarViewController class]])
        {
            VKeyboardBarViewController *keyBoardVC = (VKeyboardBarViewController *)childViewController;
            if ([keyBoardVC.textView isFirstResponder])
            {
                return;
            }
        }
    }

    [UIView animateWithDuration:duration
                     animations:
     ^{
         self.realtimeCommentsContainer.alpha = !self.isViewingTitle ? 0 : 1;
         self.contentTitleView.alpha = self.isViewingTitle ? 0 : 1;
     }
                     completion:completion];
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
             {
                 continue;
             }
             
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
             {
                 continue;
             }
             
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
    [self didCancelKeyboardBar:keyboardBar];
    
    [[VObjectManager sharedManager] addRealtimeCommentWithText:text
                                                      mediaURL:mediaURL
                                                       toAsset:self.currentAsset
                                                        atTime:@(self.commentTime)
                                                  successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        VLog(@"Succeeded with objects: %@", resultObjects);
        self.realtimeCommentVC.comments = [self.currentAsset.comments allObjects];
    }
                                                     failBlock:^(NSOperation* operation, NSError* error)
    {
        VLog(@"Failed with error: %@", error);
    }];
    
    self.commentTime = -1;
}

- (void)didCancelKeyboardBar:(VKeyboardBarViewController *)keyboardBar
{
    [UIView animateWithDuration:.25 animations:
     ^{
         self.keyboardBarContainer.alpha = 0;
         self.realtimeCommentsContainer.alpha = 1.0f;
     }
                     completion:^(BOOL finished)
     {
         self.keyboardBarContainer.hidden = YES;
     }];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    CGRect keyboardEndFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardEndFrame = [self.view convertRect:keyboardEndFrame fromView:self.view.window];
    CGRect videoFrame = [self.view convertRect:self.videoPlayer.view.frame fromView:self.mediaView];
    
    if (CGRectIntersectsRect(keyboardEndFrame, videoFrame))
    {
        self.keyboardOverlapsMedia = YES;
    }
    else
    {
        self.keyboardOverlapsMedia = NO;
    }
    
    self.isShowingKeyboard = YES;
    
    [self.view setNeedsLayout];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    self.isShowingKeyboard = NO;
    self.keyboardOverlapsMedia = NO;
    [self.view setNeedsLayout];
    
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

- (void)hashTagButtonTappedInContentTitleTextView:(VContentTitleTextView *)contentTitleTextView withTag:(NSString *)tag
{
    VStreamContainerViewController* container =[VStreamContainerViewController modalContainerForStreamTable:[VStreamTableViewController hashtagStreamWithHashtag:tag]];
    container.shouldShowHeaderLogo = NO;
    [self.navigationController pushViewController:container animated:YES];
}

@end
