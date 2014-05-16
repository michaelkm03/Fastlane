//
//  VContentViewController+Private.h
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConstants.h"

#import "VActivityIndicatorView.h"
#import "VCVideoPlayerView.h"
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

@interface VContentViewController ()  <UIWebViewDelegate, VInteractionManagerDelegate, UIDynamicAnimatorDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView* backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel* descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView* barContainerView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray* buttonCollection;

/**
 These constraints are set on the preview image only while a video is being played
 */
@property (strong, nonatomic) NSArray* temporaryVideoPreviewConstraints;

@property (weak, nonatomic) IBOutlet UIImageView* firstSmallPreviewImage;
@property (weak, nonatomic) IBOutlet UIImageView* secondSmallPreviewImage;
@property (weak, nonatomic) IBOutlet VResultView* firstResultView;
@property (weak, nonatomic) IBOutlet VResultView* secondResultView;
@property (weak, nonatomic) IBOutlet UIView*      maskingView; ///< This view is normally hidden but unhides during landspace video playback

@property (strong, nonatomic) UIDynamicAnimator* orAnimator;

@property (strong, nonatomic) VCVideoPlayerView* videoPlayer;
@property (strong, nonatomic) VNode* currentNode;
@property (strong, nonatomic) VAsset* currentAsset;
@property (strong, nonatomic) VInteractionManager* interactionManager;

@property (strong, nonatomic) VActivityIndicatorView* activityIndicator;

@property (strong, nonatomic) id<UIViewControllerTransitioningDelegate> transitionDelegate;

@property (nonatomic) BOOL appearing; ///< YES if this view is the topmost view of the application window. NO if not.

- (void)updateActionBar;

@end