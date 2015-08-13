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

// AVFoundation
#import <AVFoundation/AVFoundation.h>

// Victorious Models
#import "VAbstractFilter.h"
#import "VSEquence.h"
#import "VStream.h"
#import "VExperimentSettings.h"
#import "VSequence.h"
#import "VSequence+Fetcher.h"

// Everything else
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
#import "VTracking.h"
#import "VTrackingManager.h"
#import "VReachability.h"

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
#import "VSessionTimer.h"
#import "VSequencePreviewView.h"
#import "VBaseVideoSequencePreviewView.h"
#import "VAsset+Fetcher.h"