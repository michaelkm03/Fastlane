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

// iOS Frameworks
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>

// RestKit
#import "RKEntityMapping.h"
#import "RKObjectManager.h"
#import "RKManagedObjectStore.h"
#import "RKEntityMapping.h"
#import "RKManagedObjectCaching.h"
#import "RKManagedObjectRequestOperation.h"
#import "RKResponseDescriptor.h"
#import "RKHTTPUtilities.h"

// SDWebImage
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageDownloader.h>

// MBProgressHUD
#import <MBProgressHUD/MBProgressHUD.h>

// AFNetworking
#import <AFNetworking/AFNetworking.h>

// Victorious Models
#import "VAbstractFilter.h"
#import "VSEquence.h"
#import "VStream.h"
#import "VExperimentSettings.h"

// Everything else
#import "VAutomation.h"
#import "VTextPostTextView.h"
#import "VObjectManager.h"
#import "VObjectManager+Private.h"
#import "VPaginationManager.h"
#import "VPageType.h"
#import "VCaptureContainerViewController.h"
#import "VVideoView.h"
#import "UIImage+VTint.h"
#import "VDependencyManager.h"
#import "VScrollPaginator.h"
#import "NSCharacterSet+VURLParts.h"
#import "UIView+AutoLayout.h"
#import "VComment.h"
#import "VMessage.h"
#import "VComment+Fetcher.h"
#import "UIImage+ImageCreation.h"
#import "VVideoView.h"
#import "VMessage+Fetcher.h"
#import "VSettingsSwitchCell.h"
#import "UIImage+VTint.h"
#import "VDataCache.h"
#import "NSURL+VDataCacheID.h"
#import "VButton.h"
#import "VHasManagedDependencies.h"
#import "VSessionTimer.h"
#import "VAuthorizedAction.h"
#import "VObjectManager.h"
#import "VAuthorizationContext.h"
#import "VLightweightContentViewController.h"
#import "VFirstTimeInstallHelper.h"
#import "VSessionTimer.h"
#import "VTrackingManager.h"
#import "VDependencyManager+VTracking.h"
#import "VPushNotificationManager.h"

//Shelves
#import "VStreamCellFactory.h"
#import "VSleekStreamCellFactory.h"
#import "VMarqueeController.h"
#import "VAbstractMarqueeController.h"
#import "VAbstractMarqueeCollectionViewCell.h"
#import "VShelf.h"
#import "VStreamContentCellFactoryDelegate.h"
#import "VDirectoryCellFactory.h"
#import "VDirectoryCellUpdateableFactory.h"
#import "VDirectoryCollectionFlowLayout.h"
#import "VStreamItem+Fetcher.h"
#import "VBackgroundContainer.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VDefaultProfileButton.h"
#import "VUser+Fetcher.h"
#import "VFollowControl.h"
#import "VSequence+Fetcher.h"
#import "VListicleView.h"
#import "UIImageView+VLoadingAnimations.h"
#import "UIView+AutoLayout.h"
#import "VBaseCollectionViewCell.h"
#import "VImageAsset.h"
#import "VImageAssetFinder.h"
#import "NSString+VParseHelp.h"
#import "VStreamCellSpecialization.h"
#import "VStreamItemPreviewView.h"
#import "VLargeNumberFormatter.h"
#import "VShelf+RestKit.h"
#import "VUser+RestKit.h"
#import "VFollowResponder.h"
#import "VHashtagResponder.h"
#import "VHashTagTextView.h"
#import <CCHLinkTextView/CCHLinkTextViewDelegate.h>
#import "VDirectoryCollectionViewController.h"
#import "VStreamCollectionViewController.h"
#import "VHashtagSelectionResponder.h"
#import "VTagSensitiveTextView.h"
#import "VTagStringFormatter.h"
#import "VTag.h"
#import "VImageSequencePreviewView.h"
