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

// Victorious Models
#import "VAbstractFilter.h"
#import "VSEquence.h"
#import "VStream.h"

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

// Shelves
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
