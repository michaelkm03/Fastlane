//
//  SwiftBridging.h
//  victorious
//
//  Created by Patrick Lynch on 4/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

/**
 Use this file to import Objective-C headers that need to be exposed to any Swift code.
 */

#import "NSString+VCrypto.h"
#import "NSString+VParseHelp.h"
#import "NSURL+MediaType.h"
#import "NSURL+VDataCacheID.h"
#import "NSURL+VTemporaryFiles.h"
#import "UIColor+VBrightness.h"
#import "UIImage+ImageCreation.h"
#import "UIImage+Resize.h"
#import "UIImage+Round.h"
#import "UIImage+VTint.h"
#import "UIImageView+Blurring.h"
#import "UIImageView+VLoadingAnimations.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "UIView+AutoLayout.h"
#import "UIViewController+VAccessoryScreens.h"
#import "UIViewController+VLayoutInsets.h"
#import "VAbstractImageVideoCreationFlowController.h"
#import "VAbstractMarqueeCollectionViewCell.h"
#import "VAbstractMarqueeController.h"
#import "VAbstractStreamCollectionViewController.h"
#import "VActionBarFixedWidthItem.h"
#import "VActionItem.h"
#import "VActionSheetTransitioningDelegate.h"
#import "VActionSheetViewController.h"
#import "VAlternateCaptureOption.h"
#import "VAnswer+Fetcher.h"
#import "VAnswer.h"
#import "VAppDelegate.h"
#import "VAppInfo.h"
#import "VAppTimingEventType.h"
#import "VApplicationTracking.h"
#import "VAsset+Fetcher.h"
#import "VAssetDownloader.h"
#import "VAuthorizationContext.h"
#import "VAutomation.h"
#import "VBackgroundContainer.h"
#import "VBadgeImageType.h"
#import "VBaseCollectionViewCell.h"
#import "VBaseVideoSequencePreviewView.h"
#import "VBaseWorkspaceViewController.h"
#import "VButton.h"
#import "VCameraCaptureController.h"
#import "VCameraCoachMarkAnimator.h"
#import "VCameraControl.h"
#import "VCameraPermissionsController.h"
#import "VCameraVideoEncoder.h"
#import "VCaptureContainerViewController.h"
#import "VCaptureVideoPreviewView.h"
#import "VCellWithProfileDelegate.h"
#import "VChangePasswordViewController.h"
#import "VCollectionViewStreamFocusHelper.h"
#import "VColorType.h"
#import "VComment.h"
#import "VCompatibility.h"
#import "VContentCell.h"
#import "VContentViewFactory.h"
#import "VContentViewOriginViewController.h"
#import "VConversation.h"
#import "VCreatePollViewController.h"
#import "VCreateSheetViewController.h"
#import "VCreationFlowPresenter.h"
#import "VDataCache.h"
#import "VDependencyManager+NavigationBar.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VDefaultTemplate.h"
#import "VDependencyManager+VKeyboardStyle.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VDependencyManager+VTracking.h"
#import "VDependencyManager.h"
#import "VDirectoryCellFactory.h"
#import "VDirectoryCellUpdateableFactory.h"
#import "VDirectoryCollectionFlowLayout.h"
#import "VDirectoryCollectionViewController.h"
#import "VDiscoverSuggestedPersonCell.h"
#import "VEditableTextPostViewController.h"
#import "VElapsedTimeFormatter.h"
#import "VEnvironment.h"
#import "VEnvironmentManager.h"
#import "VExperienceEnhancer.h"
#import "VExploreMarqueeCollectionViewFlowLayout.h"
#import "VFacebookActivity.h"
#import "VFindContactsTableViewController.h"
#import "VFlaggedContent.h"
#import "VFlexBar.h"
#import "VFocusable.h"
#import "VFollowControl.h"
#import "VFollowSource.h"
#import "VFollowedUser.h"
#import "VFooterActivityIndicatorView.h"
#import "VGifCreationFlowController.h"
#import "VHasManagedDependencies.h"
#import "VHashTagTextView.h"
#import "VHashTags.h"
#import "VHashtagCell.h"
#import "VHashtagSelectionResponder.h"
#import "VHashtagStreamCollectionViewController.h"
#import "VImageAssetDownloader.h"
#import "VImageAssetFinder+PollAssets.h"
#import "VImageAssetFinder.h"
#import "VImageLightboxViewController.h"
#import "VImageSequencePreviewView.h"
#import "VImageToolController.h"
#import "VInsetMarqueeCollectionViewCell.h"
#import "VInsetMarqueeController.h"
#import "VInsetMarqueeStreamItemCell.h"
#import "VInteraction.h"
#import "VInviteFriendTableViewCell.h"
#import "VKeyboardNotificationManager.h"
#import "VLargeNumberFormatter.h"
#import "VLaunchScreenProvider.h"
#import "VLightboxTransitioningDelegate.h"
#import "VLinearGradientView.h"
#import "VListicleView.h"
#import "VLoadingViewController.h"
#import "VLoginFlowAPIHelper.h"
#import "VLoginFlowControllerDelegate.h"
#import "VLoginRegistrationFlow.h"
#import "VLoginType.h"
#import "VMarqueeController.h"
#import "VMediaAttachment.h"
#import "VMediaAttachmentPresenter.h"
#import "VMessage+Fetcher.h"
#import "VMessage.h"
#import "VModernLoginAndRegistrationFlowViewController.h"
#import "VNavigationController.h"
#import "VNavigationDestinationContainerViewController.h"
#import "VNavigationMenuItem.h"
#import "VNewContentViewController.h"
#import "VNoContentCollectionViewCellFactory.h"
#import "VNoContentTableViewCell.h"
#import "VNoContentView.h"
#import "VNode+Fetcher.h"
#import "VNotification.h"
#import "VNotificationSettings.h"
#import "VNotificationSettingsStateManager.h"
#import "VNotificationsViewController.h"
#import "VPageType.h"
#import "VPaginatedDataSourceDelegate.h"
#import "VPassthroughContainerView.h"
#import "VPermission.h"
#import "VPermissionCamera.h"
#import "VPermissionMicrophone.h"
#import "VPhotoFilter.h"
#import "VPlaceholderTextView.h"
#import "VPollResult.h"
#import "VPseudoProduct.h"
#import "VPublishParameters.h"
#import "VPurchaseManager.h"
#import "VPurchaseManagerType.h"
#import "VPurchaseRecord.h"
#import "VPurchaseSettingsViewController.h"
#import "VPurchaseViewController.h"
#import "VPushNotificationManager.h"
#import "VRadialGradientView.h"
#import "VReachability.h"
#import "VRemixPresenter.h"
#import "VReposterTableViewController.h"
#import "VRootViewController.h"
#import "VSDKURLMacroReplacement.h"
#import "VSequence+Fetcher.h"
#import "VSequence.h"
#import "VSequenceActionControllerDelegate.h"
#import "VSequenceLiker.h"
#import "VSequencePermissions.h"
#import "VSequencePreviewView.h"
#import "VSessionTimer.h"
#import "VSettingsSwitchCell.h"
#import "VSettingsViewController.h"
#import "VShrinkingContentLayout.h"
#import "VSimpleModalTransition.h"
#import "VSleekStreamCellFactory.h"
#import "VSolidColorBackground.h"
#import "VStoredLogin.h"
#import "VStoredPassword.h"
#import "VStream.h"
#import "VStreamCellFactory.h"
#import "VStreamCellSpecialization.h"
#import "VStreamCollectionViewController.h"
#import "VStreamCollectionViewDataSource.h"
#import "VStreamContentCellFactoryDelegate.h"
#import "VStreamItem+Fetcher.h"
#import "VStreamItemPreviewView.h"
#import "VSuggestedUsersDataSource.h"
#import "VSwipeView.h"
#import "VTFLog.h"
#import "VTabMenuShim.h"
#import "VTabScaffoldHidingHelper.h"
#import "VTemplateDecorator.h"
#import "VTextColorTool.h"
#import "VTextPostTextView.h"
#import "VTextSequencePreviewView.h"
#import "VTextToolController.h"
#import "VThemeManager.h"
#import "VTickerPickerViewController.h"
#import "VTimerManager.h"
#import "VTrackingManager.h"
#import "VTransitionDelegate.h"
#import "VTwitterManager.h"
#import "VUploadManager.h"
#import "VUploadProgressViewController.h"
#import "VUploadTaskCreator.h"
#import "VUploadTaskInformation.h"
#import "VUserCell.h"
#import "VUsersViewController.h"
#import "VUtilityButtonCell.h"
#import "VVideoAssetDownloader.h"
#import "VVideoLightboxViewController.h"
#import "VVideoSequencePreviewView.h"
#import "VVideoToolController.h"
#import "VVideoView.h"
#import "VVoteResult.h"
#import "VVoteType.h"
#import "VWebContentViewController.h"
#import "VWorkspaceShimDestination.h"
#import "VWorkspaceViewController.h"
#import "YTPlayerView.h"
