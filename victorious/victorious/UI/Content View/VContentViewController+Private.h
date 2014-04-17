//
//  VContentViewController+Private.h
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConstants.h"

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
@property (weak, nonatomic) IBOutlet UIButton* remixButton;

@property (weak, nonatomic) IBOutlet UIView* mpPlayerContainmentView;

@property (weak, nonatomic) IBOutlet UIView* pollPreviewView;
@property (weak, nonatomic) IBOutlet UIImageView* firstSmallPreviewImage;
@property (weak, nonatomic) IBOutlet UIImageView* secondSmallPreviewImage;
@property (weak, nonatomic) IBOutlet VResultView* firstResultView;
@property (weak, nonatomic) IBOutlet VResultView* secondResultView;
@property (weak, nonatomic) IBOutlet UIButton* firstPollButton;
@property (weak, nonatomic) IBOutlet UIButton* secondPollButton;

@property (weak, nonatomic) IBOutlet UIView* orContainerView;
@property (strong, nonatomic) UIDynamicAnimator* orAnimator;

@property (strong, nonatomic) MPMoviePlayerController* mpController;
@property (strong, nonatomic) VNode* currentNode;
@property (strong, nonatomic) VAsset* currentAsset;
@property (strong, nonatomic) VInteractionManager* interactionManager;

@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;

@property (strong, nonatomic) id<UIViewControllerTransitioningDelegate> transitionDelegate;

- (void)updateActionBar;

@end