//
//  VNewContentViewController.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VContentViewViewModel.h"
#import "VDependencyManager.h"
#import "VHasManagedDependencies.h"
#import "VVideoPlayerDelegate.h"
#import "VPollResultReceiver.h"
#import "VRenderablePreviewView.h"
#import "VVideoPreviewView.h"

@class VDependencyManager, VSequenceActionController, VContentCell, VExperienceEnhancerBarCell, VNewContentViewController;

@protocol VNewContentViewControllerDelegate <NSObject>
@optional

- (void)contnetViewDidDeleteContent:(VNewContentViewController *)contentViewController;

@end


/**
 *  The content view controller.
 */
@interface VNewContentViewController : UIViewController <VHasManagedDependencies, VVideoPreviewViewDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 *  Designated factory method for the content viewcontroller.
 *
 *  @param viewModel The viewmodel to use for representation fo the contentViewController.
 *
 *  @return An initialized content view controller.
 */
+ (VNewContentViewController *)contentViewControllerWithViewModel:(VContentViewViewModel *)viewModel
                                                dependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  The viewModel that was passed in to the content viewController's factory method.
 */
@property (nonatomic, strong, readonly) VContentViewViewModel *viewModel;

@property (nonatomic, strong) UIImage *placeholderImage;

@property (nonatomic, weak, readonly) IBOutlet VSequenceActionController *sequenceActionController;

@property (nonatomic, weak, readonly) VContentCell *contentCell;

@property (nonatomic, weak, nullable) id<VNewContentViewControllerDelegate> delegate;

/*
 Provides playback controls and other interactions
 with a visible video UI.
 */
@property (nonatomic, weak) id<VVideoPlayer> videoPlayer;

/*
 Object that responds to interaction with a poll view.
 */
@property (nonatomic, weak) id<VPollResultReceiver> pollAnswerReceiver;

@end
