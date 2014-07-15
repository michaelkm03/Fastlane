//
//  VContentViewController+Private.h
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "AFImageRequestOperation.h"

#import "VConstants.h"

#import "VActivityIndicatorView.h"
#import "VCVideoPlayerViewController.h"
#import "VContentTitleTextView.h"
#import "VPollAnswerBarViewController.h"
#import "VResultView.h"

#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"
#import "VInteractionManager.h"
#import "VSequence+Fetcher.h"

#import "VThemeManager.h"

#import "NSString+VParseHelp.h"
#import "UIImage+ImageCreation.h"

@import MediaPlayer;

extern NSTimeInterval kVContentPollAnimationDuration;

@interface VContentViewController ()  <UIWebViewDelegate, VContentTitleTextViewDelegate, VInteractionManagerDelegate, UIDynamicAnimatorDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView* backgroundImage;
@property (weak, nonatomic) IBOutlet VContentTitleTextView* descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView* barContainerView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray* navButtonCollection;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray* actionButtonCollection;

/**
 These constraints are set on the preview image only while a video is being played
 */
@property (strong, nonatomic) NSArray* temporaryVideoPreviewConstraints;

@property (weak, nonatomic) IBOutlet UIImageView* firstSmallPreviewImage;
@property (weak, nonatomic) IBOutlet UIImageView* secondSmallPreviewImage;
@property (weak, nonatomic) IBOutlet VResultView* firstResultView;
@property (weak, nonatomic) IBOutlet VResultView* secondResultView;
@property (weak, nonatomic) IBOutlet UIView*      maskingView; ///< This view is normally hidden but unhides during landspace video playback
@property (weak, nonatomic) IBOutlet UIView*      expandedTitleMaskingView; ///< This view is normally hidden but unhides when the title label is expanded
@property (weak, nonatomic) IBOutlet UIView*      answeredPollMaskingView; ///< This view is normally hidden but unhides when a poll is answered
@property (weak, nonatomic) IBOutlet UIButton*    collapseButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* topActionsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* pollViewYConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* collapseButtonVerticalSpacingConstraint;
@property (nonatomic)                CGFloat             smallTextSize; ///< The size of the title text when collapsed into 3 lines
@property (nonatomic)                BOOL                collapsingOrExpanding; ///< YES during the animation block for a title expand/collapse operation
@property (nonatomic)                BOOL                titleExpanded; ///< YES if the title is expanded

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* leftImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* leftImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* rightImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* rightImageViewWidthConstraint;

@property (strong, nonatomic) UIDynamicAnimator* orAnimator;

@property (weak, nonatomic) VRealtimeCommentViewController* realtimeCommentVC;

@property (strong, nonatomic) VCVideoPlayerViewController* videoPlayer;
@property (strong, nonatomic) VNode* currentNode;
@property (strong, nonatomic) VAsset* currentAsset;
@property (strong, nonatomic) VInteractionManager* interactionManager;

@property (strong, nonatomic) VActivityIndicatorView*  activityIndicator;

@property (copy, nonatomic) void (^collapsePollMedia)(BOOL animated, void(^completion)()); ///< Execute this block to collapse the poll media. If poll media is not expanded, this block is nil.

@property (strong, nonatomic) id<UIViewControllerTransitioningDelegate> transitionDelegate;

@property (nonatomic) BOOL appearing; ///< YES if this view is the topmost view of the application window. NO if not.
@property (nonatomic) BOOL isRotating; ///< YES only if we are trying to force rotation, not if the rotation is natural

- (void)updateActionBar;
- (void)forceRotationBackToPortraitOnCompletion:(void(^)(void))completion; ///< Animate back to portrait mode.

/**
 Like -forceRotationBackToPortraitOnCompletion:, but allows the caller to specify more animations
 to go alongside the rotation animations.
 */
- (void)forceRotationBackToPortraitWithExtraAnimations:(void(^)(void))animations onCompletion:(void(^)(void))completion;

- (BOOL)isTitleExpanded; ///< Returns YES if the full title is being displayed with a white overlay view beneath

@end
